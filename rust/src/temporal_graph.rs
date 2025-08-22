use rand::thread_rng;
use rand::Rng;
use std::collections::HashMap;
use std::hash::Hash;
use std::time::Duration;
use std::time::Instant;



use std::{usize};


// from_stop_I;to_stop_I;dep_time_ut;arr_time_ut;route_type;trip_I;seq;route_I
type EdgeRecord = (String, String, usize, usize, usize, String, usize, usize);

// departure;arrival;starting_time;n_people
type RequestRecord = (String, String, usize, usize);

type TemporalPaths<'a> = HashMap<(usize, usize), Vec<&'a Edge>>;

#[derive(Debug, PartialEq, Eq, Hash)]
pub struct Edge {
    pub from_id: usize,
    pub to_id: usize,
    pub departure_time: usize,
    arrival_time: usize,
    duration: usize,
    route_type: usize,
    trip_id: usize,
    seq: usize,
    route_id: usize,
}

#[derive(Debug)]
pub struct Request {
    from_id: usize,
    to_id: usize,
    departure_time: usize,
    multiplicity: usize,
}

pub struct RequestSample {
    pub requests: Vec<Request>,
    pub total: usize,
}

pub struct Estimation<'a> {
    pub occupancy_matrix: HashMap<(usize, usize), usize>,
    pub crowding_vector: HashMap<&'a Edge, usize>,
    pub average_travelling_time: usize,
    pub average_waiting_time: usize,
    pub total: usize,
    pub elapsed: Duration,
}

impl Estimation<'_> {
    pub fn average_travelling_time_as_f64(&self) -> f64 {
        self.average_travelling_time as f64 / self.total as f64
    }

    pub fn average_waiting_time_as_f64(&self) -> f64 {
        self.average_waiting_time as f64 / self.total as f64
    }
}

pub struct TemporalGraph {
    pub vertices: HashMap<String, usize>,
    pub vertices_rev: HashMap<usize, String>,
    pub edges: Vec<Edge>,
    max_time: usize,
}

impl TemporalGraph {
    pub fn parse(filename: &str) -> TemporalGraph {
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
                Some(&i) => i,
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
                Some(&i) => i,
            };

            let trip_id = match trips.get(&record.5) {
                None => {
                    let v = trips_count;
                    trips.insert(record.5, v);
                    trips_count += 1;
                    v
                }
                Some(&i) => i,
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
        let mut t = vec![usize::MAX; num_nodes];

        t[v] = start_t;

        for edge in self.edges.iter() {
            let td = edge.departure_time;
            let ta = edge.arrival_time;

            if ta <= stop_t && td >= t[edge.from_id] {
                if ta < t[edge.to_id] {
                    paths[edge.to_id] = Some(edge);
                    t[edge.to_id] = ta;
                }
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
    ) -> Vec<&'a Edge> {
        let paths = self.earliest_arrival_paths(from, start_t, stop_t);
        let path = Self::reify_path(to, &paths);
        path
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
    pub fn parse(filename: &str, graph: &TemporalGraph) -> RequestSample {
        let rdr = csv::ReaderBuilder::new()
            .has_headers(true)
            .delimiter(b';')
            .from_path(filename)
            .unwrap();

        let mut requests = Vec::new();
        let mut total = 0usize;

        for result in rdr.into_deserialize() {
            let record: RequestRecord = result.unwrap();

            if let Some(&v) = graph.vertices.get(&record.0) {
                if let Some(&w) = graph.vertices.get(&record.1) {
                    let req = Request::new(v, w, record.2, record.3);
                    total += req.multiplicity;
                    requests.push(req);
                }
            }
        }

        RequestSample { requests, total }
    }

    pub fn sample(self: &RequestSample, k: usize) -> RequestSample {
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

    pub fn estimate<'a>(
        self: &RequestSample,
        graph: &'a TemporalGraph,
        temporal_paths: &mut TemporalPaths<'a>,
    ) -> Estimation<'a> {
        let mut crowding_vector = HashMap::new();
        let mut occupancy = HashMap::new();

        let mut at = 0;
        let mut aw = 0;

        let start_timestamp = Instant::now();

        for req in self.requests.iter() {
            let mul = req.multiplicity;

            let path = temporal_paths
                .entry((req.from_id, req.departure_time))
                .or_insert_with(|| {
                    graph.earliest_arrival_path(
                        req.from_id,
                        req.to_id,
                        req.departure_time,
                        graph.max_time,
                    )
                });

            if path.is_empty() {
                continue;
            }

            for e in 0..path.len() - 1 {
                let edge = path[e];

                *crowding_vector.entry(edge).or_insert(0) += mul;

                let mut at_each = edge.duration - 1;

                if let Some(&next_edge) = path.get(e + 1) {
                    if edge.trip_id != next_edge.trip_id {
                        for t in edge.arrival_time..=next_edge.departure_time {
                            *occupancy.entry((edge.to_id, t)).or_insert(0) += mul;
                            aw += mul;
                        }
                    } else {
                        at_each += next_edge.departure_time - edge.arrival_time + 1;
                    }
                }

                at += mul * at_each;
            }
        }

        Estimation {
            occupancy_matrix: occupancy,
            crowding_vector,
            average_travelling_time: at,
            average_waiting_time: aw,
            total: self.total,
            elapsed: start_timestamp.elapsed(),
        }
    }
}



pub fn single(k: usize, epsilon: f64, repetitions: usize, city: &str, graph: &TemporalGraph, requests: &RequestSample) {
    

    let mut temporal_paths = HashMap::new();
    let exact = requests.estimate( &graph, &mut temporal_paths);

    let mut at = Vec::new();
    let mut aw = Vec::new();

    let elapsed = std::time::Instant::now();
    for _ in 0..repetitions {
        let sampled = requests.sample(k);
        let estimation = sampled.estimate( &graph, &mut temporal_paths);

        at.push(estimation.average_travelling_time_as_f64());
        aw.push(estimation.average_waiting_time_as_f64());
    }

    let freps = repetitions as f64;

    let at_mean = at.iter().sum::<f64>() / freps;
    let aw_mean = aw.iter().sum::<f64>() / freps;

    let at_var = at.iter().map(|x| (x - at_mean).powi(2)).sum::<f64>() / freps;
    let aw_var = aw.iter().map(|x| (x - aw_mean).powi(2)).sum::<f64>() / freps;

    let at_coeff_var = at_var.sqrt() / at_mean;
    let aw_coeff_var = aw_var.sqrt() / aw_mean;

    println!(
        "{} & {} & {} & {} & {} & {:.3} & {} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:?} & {:?} & {:.3} & {:.3} \\\\",
        city,
        graph.vertices.len(),
        graph.edges.len(),
        requests.requests.len(),
        requests.total,
        epsilon,
        k,
        exact.average_travelling_time_as_f64(), 
        at_mean,
        (at_mean - exact.average_travelling_time_as_f64()).abs(),
        at_var.sqrt(),
        at_coeff_var,
        exact.average_waiting_time_as_f64(),
        aw_mean,
        (aw_mean - exact.average_waiting_time_as_f64()).abs(),
        aw_var.sqrt(),
        aw_coeff_var,
        exact.elapsed,
        elapsed.elapsed(),
        elapsed.elapsed().as_secs_f64() * 1000.0,
        exact.elapsed.as_secs_f64() / elapsed.elapsed().as_secs_f64(),
    );
}
