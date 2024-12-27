use rand::thread_rng;
use rand::Rng;
use std::hash::Hash;
use std::time::Duration;
use std::{collections::HashMap, usize};

// from_stop_I;to_stop_I;dep_time_ut;arr_time_ut;route_type;trip_I;seq;route_I
type EdgeRecord = (String, String, usize, usize, usize, String, usize, usize);

// departure;arrival;starting_time;n_people
type RequestRecord = (String, String, usize, usize);

#[derive(Debug, PartialEq, Eq, Hash)]
struct Edge {
    from_id: usize,
    to_id: usize,
    departure_time: usize,
    arrival_time: usize,
    duration: usize,
    route_type: usize,
    trip_id: usize,
    seq: usize,
    route_id: usize,
}

#[derive(Debug)]
struct Request {
    from_id: usize,
    to_id: usize,
    departure_time: usize,
    multiplicity: usize,
}

fn parse_edges(vertices: &mut HashMap<String, usize>, edges: &mut Vec<Edge>) -> usize {
    let mut trips = HashMap::new();
    let mut vertices_count = 0usize;
    let mut trips_count = 0usize;
    let mut max_time = 0usize;

    let rdr = csv::ReaderBuilder::new()
        .has_headers(true)
        .delimiter(b';')
        .from_path("../data/transport/florence/edges.csv")
        .unwrap();

    for result in rdr.into_deserialize() {
        let record: EdgeRecord = result.unwrap();

        let from_id = match vertices.get(&record.0) {
            None => {
                let v = vertices_count;
                vertices.insert(record.0, v);
                vertices_count += 1;
                v
            }
            Some(i) => *i,
        };

        let to_id = match vertices.get(&record.1) {
            None => {
                let v = vertices_count;
                vertices.insert(record.1, v);
                vertices_count += 1;
                v
            }
            Some(i) => *i,
        };

        let trip_id = match trips.get(&record.5) {
            None => {
                let v = trips_count;
                trips.insert(record.5, v);
                trips_count += 1;
                v
            }
            Some(i) => *i,
        };

        let edge = Edge {
            from_id,
            to_id,
            departure_time: record.2,
            arrival_time: record.3,
            route_type: record.4,
            trip_id,
            seq: record.6,
            route_id: record.7,
            duration: record.3 - record.2,
        };

        max_time = max_time.max(edge.arrival_time);
        edges.push(edge);
    }

    edges.sort_by(|a, b| a.departure_time.cmp(&b.departure_time));

    assert_eq!(vertices.len(), vertices_count);
    assert_eq!(trips.len(), trips_count);

    max_time
}

fn parse_requests(vertices: &HashMap<String, usize>, requests: &mut Vec<Request>) {
    let rdr = csv::ReaderBuilder::new()
        .has_headers(true)
        .delimiter(b';')
        .from_path("../data/transport/florence/requests_K10747_N30965.csv")
        .unwrap();

    for result in rdr.into_deserialize() {
        let record: RequestRecord = result.unwrap();

        if let Some(v) = vertices.get(&record.0) {
            if let Some(w) = vertices.get(&record.1) {
                let req = Request {
                    from_id: *v,
                    to_id: *w,
                    departure_time: record.2,
                    multiplicity: record.3,
                };
                requests.push(req);
            } else {
                continue;
            };
        } else {
            continue;
        };
    }
}

fn reify_path<'a>(to: usize, paths: &Vec<Option<&'a Edge>>) -> Vec<&'a Edge> {
    let mut path = Vec::new();
    let mut w = to;

    while let Some(p) = paths[w] {
        path.push(p);

        w = p.from_id;
    }

    path.reverse();

    path
}

fn earliest_arrival_paths(
    v: usize,
    start_t: usize,
    stop_t: usize,
    num_nodes: usize,
    edges: &Vec<Edge>,
) -> Vec<Option<&Edge>> {
    let mut paths = vec![None; num_nodes];
    let mut t = vec![None; num_nodes];

    t[v] = Some(start_t);

    for edge in edges.iter() {
        let td = edge.departure_time;
        let ta = edge.arrival_time;
        if ta <= stop_t {
            match t[edge.from_id] {
                None => continue,
                Some(t0) => {
                    if td >= t0 {
                        t[edge.to_id] = match t[edge.to_id] {
                            None => {
                                paths[edge.to_id] = Some(edge);
                                Some(ta)
                            }
                            Some(t1) => {
                                if ta < t1 {
                                    paths[edge.to_id] = Some(edge);
                                    Some(ta)
                                } else {
                                    Some(t1)
                                }
                            }
                        }
                    }
                }
            };
        } else if td >= stop_t {
            break;
        }
    }

    paths
}

fn sample(k: usize, requests: &Vec<Request>) -> Vec<Request> {
    let mut rng = thread_rng();
    let mut multiplicities = Vec::new();
    let mut total = 0usize;

    let mut sample = Vec::new();

    for req in requests.iter() {
        total += req.multiplicity;
        multiplicities.push(total);
    }

    let sup = multiplicities.len() - 1; // exclusive upper bounds

    for _ in 0..k {
        let m = rng.gen_range(0..=total);

        let (mut lo, mut hi) = (0, sup);

        // Binary search: find the first index lo such that multiplicities[lo] >= m.
        while lo < hi {
            let mid = (lo + hi) >> 1;
            if multiplicities[mid] < m {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }

        let unary_request = Request {
            multiplicity: 1,
            ..requests[lo]
        };

        sample.push(unary_request);
    }

    sample
}

fn estimate<'a>(
    sample: &Vec<Request>,
    stop_t: usize,
    time_step: usize,
    num_nodes: usize,
    edges: &'a Vec<Edge>,
) -> (
    HashMap<(usize, usize), f64>,
    HashMap<&'a Edge, f64>,
    f64,
    f64,
) {
    let mut crowding_vector = HashMap::new();
    let mut occupancy = HashMap::new();

    let mut at = 0;
    let mut aw = 0;

    let total = sample.iter().fold(0, |acc, req| acc + req.multiplicity) as f64;

    for req in sample.iter() {
        let m = req.multiplicity;
        let fmul = (m as f64) / total;
        let paths =
            earliest_arrival_paths(req.from_id, req.departure_time, stop_t, num_nodes, edges);
        let path = reify_path(req.to_id, &paths);
        // println!("* {:?} in {} steps.", req, path.len());
        if path.is_empty() {
            continue;
        }
        for e in 0..path.len() - 1 {
            let edge = path[e];
            // println!("*** {:?}", edge);
            crowding_vector
                .entry(edge)
                .and_modify(|e| *e += fmul)
                .or_insert(fmul);

            at += m * edge.duration;

            let next_edge = path[e + 1];
            if edge.trip_id != next_edge.trip_id {
                for t in (edge.arrival_time + time_step..=next_edge.departure_time - time_step)
                    .step_by(time_step)
                {
                    occupancy
                        .entry((edge.to_id, t))
                        .and_modify(|e| *e += fmul)
                        .or_insert(fmul);
                    aw += m;
                }
            }
        }
    }

    (
        occupancy,
        crowding_vector,
        (at as f64) / total,
        ((aw * time_step) as f64) / total,
    )
}

fn main() {
    let repetitions = 10;
    let time_step = 60; //  1 minute

    let mut vertices = HashMap::new();
    let mut edges: Vec<Edge> = Vec::new();
    let mut requests: Vec<Request> = Vec::new();

    let max_time = parse_edges(&mut vertices, &mut edges);
    parse_requests(&mut vertices, &mut requests);

    println!(
        "|V| = {}, |E| = {}, |Q| = {}.",
        vertices.len(),
        edges.len(),
        requests.len()
    );

    let at_true = 0.0;
    let aw_true = 0.0;

    // let (_occupancy, _crowding_vector_true, at_true, aw_true) =
    //     estimate(&requests, max_time, time_step, vertices.len(), &edges);

    let mut at = 0.0;
    let mut aw = 0.0;

    let mut cw = HashMap::new();
    let mut om = HashMap::new();

    for _ in 0..repetitions {
        let sampled = sample(381, &requests);
        let (occupancy, crowding_vector, at_each, aw_each) =
            estimate(&sampled, max_time, time_step, vertices.len(), &edges);
        at += at_each;
        aw += aw_each;

        for (edge, fmul) in crowding_vector {
            cw.entry(edge)
                .and_modify(|e| *e = *e + fmul / 2.0)
                .or_insert(fmul);
        }

        for (key, fmul) in occupancy {
            om.entry(key)
                .and_modify(|e| *e = *e + fmul / 2.0)
                .or_insert(fmul);
        }
    }

    println!(
        "Average travelling time: true {:?}, estimated {:?} over {} repetitions.",
        Duration::from_secs_f64(at_true),
        Duration::from_secs_f64(at / (repetitions as f64)),
        repetitions
    );

    println!(
        "Average waiting time: true {:?}, estimated {:?} over {} repetitions.",
        Duration::from_secs_f64(aw_true),
        Duration::from_secs_f64(aw / (repetitions as f64)),
        repetitions
    );

    let mut vertices_rev = HashMap::new();
    for (k, v) in vertices.iter() {
        vertices_rev.insert(v, k);
    }

    let mut cw_named = Vec::new();
    for (edge, fmul) in cw.iter() {
        let from_name = vertices_rev.get(&edge.from_id).unwrap();
        let to_name = vertices_rev.get(&edge.to_id).unwrap();
        cw_named.push((*from_name, *to_name, edge.departure_time, fmul));
    }

    cw_named.sort_by(|a, b| b.3.total_cmp(a.3));

    println!("Top 50 crowded edges:");
    for (from, to, d, fmul) in cw_named.iter().take(50) {
        println!(
            "\t{} -> {}: {:.3}% people at {:?}.",
            from,
            to,
            fmul,
            Duration::from_secs(*d as u64)
        );
    }

    let mut om_named = HashMap::new();

    for ((v, t), fmul) in om.iter() {
        let v_name = vertices_rev.get(v).unwrap();

        match om_named.get_mut(t) {
            None => {
                let mut m = HashMap::new();
                m.insert(*v_name, *fmul);
                om_named.insert(t, m);
            }
            Some(m) => {
                m.entry(*v_name)
                    .and_modify(|e| *e += *fmul)
                    .or_insert(*fmul);
            }
        }
    }

    let mut om_named_vec = Vec::new();
    for (t, m) in om_named.iter() {
        let mut m_vec = Vec::new();
        for (v, fmul) in m.iter() {
            m_vec.push((*v, *fmul));
        }
        m_vec.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());
        om_named_vec.push((*t, m_vec));
    }

    om_named_vec.sort_by(|a, b| a.0.cmp(b.0));

    println!("Top 50 crowded stops:");
    for (t, m) in om_named_vec {
        println!("\tAt {:?}:", Duration::from_secs(*t as u64));
        for (v, fmul) in m.iter() {
            println!("\t\t{}: {:.3}% people.", v, fmul);
        }
    }
}
