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

struct RequestSample {
    requests: Vec<Request>,
    total: usize,
}

struct Estimation<'a> {
    occupancy_matrix: HashMap<(usize, usize), usize>,
    crowding_vector: HashMap<&'a Edge, usize>,
    average_travelling_time: f64,
    average_waiting_time: f64,
    time_step: usize,
}

fn parse_edges(
    filename: &str,
    vertices: &mut HashMap<String, usize>,
    edges: &mut Vec<Edge>,
) -> usize {
    let mut trips = HashMap::new();
    let mut vertices_count = 0usize;
    let mut trips_count = 0usize;
    let mut max_time = 0usize;

    let rdr = csv::ReaderBuilder::new()
        .has_headers(true)
        .delimiter(b';')
        .from_path(filename)
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

impl Request {
    fn new(from_id: usize, to_id: usize, departure_time: usize, multiplicity: usize) -> Request {
        Request {
            from_id,
            to_id,
            departure_time,
            multiplicity,
        }
    }
}

impl RequestSample {
    fn parse(filename: &str, vertices: &HashMap<String, usize>) -> RequestSample {
        let rdr = csv::ReaderBuilder::new()
            .has_headers(true)
            .delimiter(b';')
            .from_path(filename)
            .unwrap();

        let mut requests = Vec::new();
        let mut total = 0usize;

        for result in rdr.into_deserialize() {
            let record: RequestRecord = result.unwrap();

            if let Some(v) = vertices.get(&record.0) {
                if let Some(w) = vertices.get(&record.1) {
                    let req = Request::new(*v, *w, record.2, record.3);
                    total += req.multiplicity;
                    requests.push(req);
                }
            }
        }

        RequestSample { requests, total }
    }

    fn sample(self: &RequestSample, k: usize) -> RequestSample {
        let mut rng = thread_rng();
        let mut multiplicities = Vec::new();
        let mut total = 0usize;
        let mut new_total = 0usize;
        let mut sample = Vec::new();

        for req in self.requests.iter() {
            total += req.multiplicity;
            multiplicities.push(total);
        }

        assert_eq!(total, self.total);

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
                ..self.requests[lo]
            };

            new_total += unary_request.multiplicity;

            sample.push(unary_request);
        }

        assert_eq!(new_total, k);

        RequestSample {
            requests: sample,
            total: new_total,
        }
    }

    fn estimate<'a>(
        self: &RequestSample,
        stop_t: usize,
        time_step: usize,
        num_nodes: usize,
        edges: &'a Vec<Edge>,
    ) -> Estimation<'a> {
        let mut crowding_vector = HashMap::new();
        let mut occupancy = HashMap::new();

        let mut at = 0;
        let mut aw = 0;

        for req in self.requests.iter() {
            let mul = req.multiplicity;
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
                    .and_modify(|e| *e += mul)
                    .or_insert(mul);

                at += mul * edge.duration;

                let next_edge = path[e + 1];
                if edge.trip_id != next_edge.trip_id {
                    let time_window = (edge.arrival_time + time_step
                        ..=next_edge.departure_time - time_step)
                        .step_by(time_step);

                    for t in time_window {
                        occupancy
                            .entry((edge.to_id, t))
                            .and_modify(|e| *e += mul)
                            .or_insert(mul);
                        aw += mul;
                    }
                }
            }
        }

        let total = self.total as f64;

        Estimation {
            occupancy_matrix: occupancy,
            crowding_vector,
            average_travelling_time: (at as f64) / total,
            average_waiting_time: ((aw * time_step) as f64) / total,
            time_step,
        }
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
            if let Some(td0) = t[edge.from_id] {
                if td >= td0 {
                    t[edge.to_id] = if let Some(ta0) = t[edge.to_id] {
                        if ta < ta0 {
                            paths[edge.to_id] = Some(edge);
                            Some(ta)
                        } else {
                            Some(ta0)
                        }
                    } else {
                        paths[edge.to_id] = Some(edge);
                        Some(ta)
                    }
                }
            };
        } else if td >= stop_t {
            break;
        }
    }

    paths
}

fn main() {
    let repetitions = 10;
    let time_step = 300; //  1 minute

    let mut vertices = HashMap::new();
    let mut edges: Vec<Edge> = Vec::new();

    let max_time = parse_edges(
        "../data/transport/florence/edges.csv",
        &mut vertices,
        &mut edges,
    );

    let requests = RequestSample::parse(
        "../data/transport/florence/requests_K10747_N30965.csv",
        &vertices,
    );

    println!(
        "|V| = {}, |E| = {}, |Q| = {}, |P| = {}.",
        vertices.len(),
        edges.len(),
        requests.requests.len(),
        requests.total
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
        let sampled = requests.sample(381);
        let estimation = sampled.estimate(max_time, time_step, vertices.len(), &edges);

        at += estimation.average_travelling_time;
        aw += estimation.average_waiting_time;

        for (edge, fmul) in estimation.crowding_vector {
            cw.entry(edge)
                .and_modify(|e| *e = *e + fmul)
                .or_insert(fmul);
        }

        for (key, fmul) in estimation.occupancy_matrix {
            om.entry(key).and_modify(|e| *e = *e + fmul).or_insert(fmul);
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

    cw_named.sort_by(|a, b| b.3.cmp(a.3));

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

    let mut om_named_grouped = HashMap::new();

    for (t, m) in om_named {
        let grouped_t = t / time_step * time_step;
        let entry = om_named_grouped
            .entry(grouped_t)
            .or_insert_with(HashMap::new);
        for (v, fmul) in m.iter() {
            entry.entry(*v).and_modify(|e| *e += *fmul).or_insert(*fmul);
        }
    }

    let mut om_named_grouped_vec = Vec::new();
    for (t, m) in om_named_grouped.iter() {
        let mut m_vec = Vec::new();
        for (v, fmul) in m.iter() {
            m_vec.push((*v, *fmul));
        }
        m_vec.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());
        om_named_grouped_vec.push((*t, m_vec));
    }

    om_named_grouped_vec.sort_by(|a, b| a.0.cmp(&b.0));

    println!("Top 50 crowded stops grouped by time step:");
    for (t, m) in om_named_grouped_vec {
        println!("\tAt {:?}:", Duration::from_secs(t as u64));
        for (v, fmul) in m.iter() {
            println!("\t\t{}: {:.3}% people.", v, fmul);
        }
    }

    // let mut om_named_vec = Vec::new();
    // for (t, m) in om_named.iter() {
    //     let mut m_vec = Vec::new();
    //     for (v, fmul) in m.iter() {
    //         m_vec.push((*v, *fmul));
    //     }
    //     m_vec.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap());
    //     om_named_vec.push((*t, m_vec));
    // }

    // om_named_vec.sort_by(|a, b| a.0.cmp(b.0));

    // println!("Top 50 crowded stops:");
    // for (t, m) in om_named_vec {
    //     println!("\tAt {:?}:", Duration::from_secs(*t as u64));
    //     for (v, fmul) in m.iter() {
    //         println!("\t\t{}: {:.3}% people.", v, fmul);
    //     }
    // }
}
