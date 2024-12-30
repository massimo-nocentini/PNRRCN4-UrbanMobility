use rand::thread_rng;
use rand::Rng;
use std::hash::Hash;
use std::path;
use std::time::Duration;
use std::{collections::HashMap, usize};

// from_stop_I;to_stop_I;dep_time_ut;arr_time_ut;route_type;trip_I;seq;route_I
type EdgeRecord = (String, String, usize, usize, usize, String, usize, usize);

// departure;arrival;starting_time;n_people
type RequestRecord = (String, String, usize, usize);

type TemporalPaths<'a> = HashMap<usize, Vec<Option<&'a Edge>>>;

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

struct TemporalGraph {
    vertices: HashMap<String, usize>,
    vertices_rev: HashMap<usize, String>,
    edges: Vec<Edge>,
    max_time: usize,
}

impl TemporalGraph {
    fn parse(filename: &str) -> TemporalGraph {
        let mut vertices = HashMap::new();
        let mut vertices_rev = HashMap::new();
        let mut edges = Vec::new();

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

            let k_from = record.0;
            let from_id = match vertices.get(&k_from) {
                None => {
                    let v = vertices_count;
                    vertices_rev.insert(v, k_from.clone());
                    vertices.insert(k_from, v);
                    vertices_count += 1;
                    v
                }
                Some(i) => *i,
            };

            let k_to = record.1;
            let to_id = match vertices.get(&k_to) {
                None => {
                    let v = vertices_count;
                    vertices_rev.insert(v, k_to.clone());
                    vertices.insert(k_to, v);
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

        TemporalGraph {
            vertices,
            vertices_rev,
            edges,
            max_time,
        }
    }

    fn earliest_arrival_paths(
        self: &TemporalGraph,
        v: usize,
        start_t: usize,
        stop_t: usize,
    ) -> Vec<Option<&Edge>> {
        let num_nodes = self.vertices.len();
        let mut paths = vec![None; num_nodes];
        let mut t = vec![None; num_nodes];

        t[v] = Some(start_t);

        for edge in self.edges.iter() {
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

    fn earliest_arrival_path<'a>(
        self: &'a TemporalGraph,
        from: usize,
        to: usize,
        start_t: usize,
        stop_t: usize,
        temporal_paths: &mut TemporalPaths<'a>,
    ) -> Vec<&'a Edge> {
        match temporal_paths.get(&from) {
            None => {
                let paths = self.earliest_arrival_paths(from, start_t, stop_t);
                let path = Self::reify_path(to, &paths);

                temporal_paths.insert(from, paths);

                path
            }
            Some(p) => Self::reify_path(to, p),
        }
    }
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
    fn parse(filename: &str, graph: &TemporalGraph) -> RequestSample {
        let rdr = csv::ReaderBuilder::new()
            .has_headers(true)
            .delimiter(b';')
            .from_path(filename)
            .unwrap();

        let mut requests = Vec::new();
        let mut total = 0usize;

        for result in rdr.into_deserialize() {
            let record: RequestRecord = result.unwrap();

            if let Some(v) = graph.vertices.get(&record.0) {
                if let Some(w) = graph.vertices.get(&record.1) {
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
        time_step: usize,
        graph: &'a TemporalGraph,
        temporal_paths: &mut TemporalPaths<'a>,
    ) -> Estimation<'a> {
        let mut crowding_vector = HashMap::new();
        let mut occupancy = HashMap::new();

        let mut at = 0;
        let mut aw = 0;

        for req in self.requests.iter() {
            let mul = req.multiplicity;

            let path = graph.earliest_arrival_path(
                req.from_id,
                req.to_id,
                req.departure_time,
                graph.max_time,
                temporal_paths,
            );

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

                if let Some(next_edge) = path.get(e + 1) {
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
                };
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

fn main() {
    let repetitions = 10;
    let time_step = 300; //  1 minute

    let graph = TemporalGraph::parse("../data/transport/florence/edges.csv");
    let mut temporal_paths = HashMap::new();

    let requests = RequestSample::parse(
        "../data/transport/florence/requests_K10747_N30965.csv",
        &graph,
    );

    println!(
        "|V| = {}, |E| = {}, |Q| = {}, |P| = {}.",
        graph.vertices.len(),
        graph.edges.len(),
        requests.requests.len(),
        requests.total
    );

    // let at_true = 0.0;
    // let aw_true = 0.0;

    let exact = requests.estimate(time_step, &graph, &mut temporal_paths);

    let at_true = exact.average_travelling_time;
    let aw_true = exact.average_waiting_time;

    let mut at = 0.0;
    let mut aw = 0.0;

    let mut cw = HashMap::new();
    let mut om = HashMap::new();

    for _ in 0..repetitions {
        let sampled = requests.sample(381);
        let estimation = sampled.estimate(time_step, &graph, &mut temporal_paths);

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

    let mut cw_named = Vec::new();
    for (edge, fmul) in cw.iter() {
        let from_name = graph.vertices_rev.get(&edge.from_id).unwrap();
        let to_name = graph.vertices_rev.get(&edge.to_id).unwrap();
        cw_named.push((from_name, to_name, edge.departure_time, fmul));
    }

    cw_named.sort_by(|a, b| b.3.cmp(a.3));

    println!("Top 50 crowded edges:");
    for (from, to, d, fmul) in cw_named.iter().take(50) {
        println!(
            "\t{} -> {}: {:.3} people at {:?}.",
            from,
            to,
            (**fmul as f64) / (repetitions as f64),
            Duration::from_secs(*d as u64)
        );
    }

    let mut om_named = HashMap::new();

    for ((v, t), fmul) in om.iter() {
        let v_name = graph.vertices_rev.get(v).unwrap();

        match om_named.get_mut(t) {
            None => {
                let mut m = HashMap::new();
                m.insert(v_name, *fmul);
                om_named.insert(t, m);
            }
            Some(m) => {
                m.entry(v_name).and_modify(|e| *e += *fmul).or_insert(*fmul);
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

    println!("Ordered crowded stops grouped by time step:");
    for (t, m) in om_named_grouped_vec {
        println!("\tAfter {:?}:", Duration::from_secs(t as u64));
        for (v, fmul) in m.iter() {
            println!(
                "\t\t{}: {:.3} people.",
                v,
                (*fmul as f64) / (repetitions as f64)
            );
        }
    }
}
