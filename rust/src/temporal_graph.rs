
use rand::SeedableRng;
use rand::rngs;
use rand::Rng;
use std::collections::HashMap;
use std::hash::Hash;

use std::time::Duration;
use std::time::Instant;

use std::usize;
use std::vec;

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
    route_type: usize,
    trip_id: usize,
    seq: usize,
    route_id: usize,
}

impl Edge {
    pub fn duration(&self) -> usize
    {
        self.arrival_time.strict_sub(self.departure_time)
    }
}

#[derive(Debug)]
pub struct Request {
    from_id: usize,
    to_id: usize,
    departure_time: usize,
    people: usize,
}

pub struct RequestSample {
    pub requests: Vec<Request>,
    pub tot_people: usize,
}

pub struct Estimation<'a> {
    pub occupancy_matrix: HashMap<(usize, usize), usize>,
    pub crowding_vector: HashMap<&'a Edge, usize>,
    pub average_travelling_time: usize,
    pub average_waiting_time: usize,
    pub elapsed: Duration,
    pub empty_paths: usize,
    pub total_people: usize,
}

impl Estimation<'_> {
    pub fn average_travelling_time_as_f64(&self) -> f64 {
        (self.average_travelling_time as f64) / (self.total_people.max(1) as f64)
    }

    pub fn average_waiting_time_as_f64(&self) -> f64 {
        (self.average_waiting_time as f64) / (self.total_people.max(1) as f64)
    }
}

pub struct TemporalGraph {
    pub vertices: HashMap<String, usize>,
    pub vertices_rev: Vec<String>,
    pub edges: Vec<Edge>,
    max_time: usize,
    min_time: usize,
}

impl TemporalGraph {
    pub fn parse(filename: &str) -> TemporalGraph {
        let mut vertices = HashMap::new();
        let mut vertices_len = vertices.len();

        let mut edges = Vec::new();

        let mut trips = HashMap::new();
        let mut trips_len = trips.len();

        let mut max_time = 0usize;
        let mut min_time = usize::MAX;

        let rdr = csv::ReaderBuilder::new()
            .has_headers(true)
            .delimiter(b';')
            .from_path(filename)
            .expect("Failed to open graph file");

        for result in rdr.into_deserialize() {
            let record: EdgeRecord = result.expect("Failed to deserialize edge record");

            let from_id = *vertices.entry(record.0).or_insert(vertices_len);
            vertices_len = vertices.len();
            
            let to_id = *vertices.entry(record.1).or_insert(vertices_len);
            vertices_len = vertices.len();

            let trip_id = *trips.entry(record.5).or_insert(trips_len);
            trips_len = trips.len();

            let edge = Edge {
                from_id,
                to_id,
                departure_time: record.2,
                arrival_time: record.3,
                route_type: record.4,
                trip_id,
                seq: record.6,
                route_id: record.7,
            };

            max_time = max_time.max(edge.arrival_time);
            min_time = min_time.min(edge.departure_time);

            edges.push(edge);
        }

        edges.sort_by(|a, b| a.departure_time.cmp(&b.departure_time));

        let mut vertices_rev = vec![String::new(); vertices_len];
        for (v, &i) in vertices.iter() {
            vertices_rev[i] = v.clone();
        }

        TemporalGraph {
            vertices,
            vertices_rev,
            edges,
            max_time,
            min_time,
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

    fn earliest_arrival_path(
        self: & TemporalGraph,
        from: usize,
        to: usize,
        start_t: usize,
        stop_t: usize,
    ) -> Vec<& Edge> {
        let paths = self.earliest_arrival_paths(from, start_t, stop_t);

        let mut path = Vec::new();
        let mut w = to;

        while let Some(p) = paths[w] {
            path.push(p);

            w = p.from_id;
        }

        path.reverse();

        path
    }
}

impl RequestSample {

    pub fn parse(filename: &str, graph: &TemporalGraph) -> RequestSample {
        let rdr = csv::ReaderBuilder::new()
            .has_headers(true)
            .delimiter(b';')
            .from_path(filename)
            .expect("Failed to open requests file");

        let mut requests = Vec::new();
        let mut tot_people = 0usize;

        for result in rdr.into_deserialize() {
            let record: RequestRecord = result.expect("Failed to deserialize request record");

            if let Some(&v) = graph.vertices.get(&record.0) {
                if let Some(&w) = graph.vertices.get(&record.1) {
                    let req = Request {
                        from_id: v,
                        to_id: w,
                        departure_time: record.2,
                        people: record.3,
                    };
                    tot_people += req.people;
                    requests.push(req);
                } else {
                    eprintln!("Warning: to_stop {} not found in graph.", record.1);
                }
            } else {
                eprintln!("Warning: from_stop {} not found in graph.", record.0);
            }
        }

        RequestSample { requests, tot_people }
    }

    pub fn sample(self: &RequestSample, k: usize, with_replacement: bool, rng: &mut impl Rng) -> RequestSample 
    {
        let mut sample = Vec::with_capacity(k);

        let mut nqs = Vec::with_capacity(self.requests.len());
        
        let mut total = 0usize;
        for req in self.requests.iter() {
            total += req.people;
            nqs.push(total);
        }

        let n = nqs.len() - 1;
    
        for _ in 0..k {
            
            let (mut lo, mut hi) = (0, n);

            let m = rng.gen_range(nqs[lo]..=nqs[hi]);

            while lo < hi {
                let mid = (lo + hi) >> 1;

                if nqs[mid] < m {
                    lo = mid + 1;
                } else {
                    hi = mid;
                }
            }

            let unary_request = Request {
                people: 1,
                ..self.requests[lo]
            };

            if with_replacement == false {
    
                for i in lo..nqs.len() {
                    nqs[i] -= 1;
                }
                
            }

            sample.push(unary_request);
        }

        RequestSample {
            requests: sample,
            tot_people: k,
        }
    }

    pub fn sample_each(self: &RequestSample, i: usize) -> RequestSample {
        let mut sample = Vec::new();

        sample.push(Request {
            //multiplicity: 1,
            ..self.requests[i]
        });

        RequestSample {
            tot_people: sample[0].people,
            requests: sample,
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

        let mut empty_paths = 0usize;
        let mut effective_people = 0usize;

        let start_timestamp = Instant::now();

        for req in self.requests.iter() {
            
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
                empty_paths += 1;
                // eprintln!(
                //     "Warning: no path found from {} to {} at time {}.",
                //     graph.vertices_rev[req.from_id],
                //     graph.vertices_rev[req.to_id],
                //     req.departure_time
                // );
                continue;
            }

            effective_people += req.people;

            // if path.len() == 1 {
            //     let edge = path[0];
            //     println!("one size path");

            //     *crowding_vector.entry(edge).or_insert(0) += mul;

            //     let mut at_each = edge.duration - 1;

            //     at += mul * at_each;
            // }

            for e in 0..path.len() - 1 {
                let edge = path[e];

                *crowding_vector.entry(edge).or_insert(0) += req.people;

                let mut at_each = edge.duration() - 1;

                if let Some(&next_edge) = path.get(e + 1) {
                    if edge.trip_id != next_edge.trip_id {
                        for t in edge.arrival_time..=next_edge.departure_time {
                            *occupancy.entry((edge.to_id, t)).or_insert(0) += req.people;
                            aw += req.people;
                        }
                    } else {
                        at_each += next_edge.departure_time - edge.arrival_time + 1;
                    }
                }

                at += req.people * at_each;
            }
        }

        eprintln!(
            "Estimated {} empty paths out of {} requests (ratio {:.3}%).",
            empty_paths,
            self.requests.len(),
            (empty_paths as f64) / (self.requests.len() as f64) * 100.0
        );
        
        Estimation {
            occupancy_matrix: occupancy,
            crowding_vector,
            average_travelling_time: at,
            average_waiting_time: aw,
            elapsed: start_timestamp.elapsed(),
            empty_paths,
            total_people: effective_people,
        }
    }
}

pub fn single(
    k: usize,
    epsilon: f64,
    repetitions: usize,
    city: &str,
    graph: &TemporalGraph,
    requests: &RequestSample,
) -> (f64, f64) {
    let mut temporal_paths = HashMap::new();
    
    let mut at = Vec::new();
    let mut aw = Vec::new();

    let mut rng = rngs::StdRng::seed_from_u64(561);

    let elapsed = std::time::Instant::now();
    for _ in 0..repetitions {
        let sampled = requests.sample(k, false, &mut rng);
        let estimation = sampled.estimate(&graph, &mut temporal_paths);
        
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
        requests.tot_people,
        epsilon,
        k,
        0,//exact.average_travelling_time_as_f64(), 
        at_mean,
        0,//(at_mean - exact.average_travelling_time_as_f64()).abs(),
        at_var.sqrt(),
        at_coeff_var,
        0,//exact.average_waiting_time_as_f64(),
        aw_mean,
        0,//(aw_mean - exact.average_waiting_time_as_f64()).abs(),
        aw_var.sqrt(),
        aw_coeff_var,
        0,//exact.elapsed,
        elapsed.elapsed(),
        elapsed.elapsed().as_secs_f64() * 1000.0,
        0//exact.elapsed.as_secs_f64() / elapsed.elapsed().as_secs_f64(),
    );

    (at_mean, aw_mean)
}

pub fn single_each(
    epsilon: f64,
    city: &str,
    graph: &TemporalGraph,
    requests: &RequestSample,
) {
    let mut temporal_paths = HashMap::new();
    let exact = requests.estimate( &graph, &mut temporal_paths);

    let mut at = Vec::new();
    let mut aw = Vec::new();
    let k = requests.requests.len();
    let elapsed = std::time::Instant::now();

    let mut check = 0usize;
    for i in 0..k {
        let sampled = requests.sample_each(i);
        let estimation = sampled.estimate(&graph, &mut temporal_paths);
        let norm = (sampled.tot_people as f64) / (requests.tot_people as f64);
        check += estimation.average_travelling_time;
        at.push(estimation.average_travelling_time_as_f64() * norm);
        aw.push(estimation.average_waiting_time_as_f64() * norm);
    }

    println!("check {} wrt exact {}", ((check as f64) / (requests.tot_people as f64)), exact.average_travelling_time_as_f64());
    let freps = k as f64;

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
        requests.tot_people,
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
