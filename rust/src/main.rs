// Date: 2021-09-26

use rand::thread_rng;
use rand::Rng;
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

fn parse_edges(scores: &mut HashMap<String, usize>, edges: &mut Vec<Edge>) -> usize {
    let mut stops_index = 0usize;
    let mut trip_index = 0usize;
    let mut max_time = 0usize;

    let rdr = csv::ReaderBuilder::new()
        .has_headers(true)
        .delimiter(b';')
        .from_path("../data/transport/florence/edges.csv")
        .unwrap();

    for result in rdr.into_deserialize() {
        let record: EdgeRecord = result.unwrap();

        let from_id = match scores.get(&record.0) {
            None => {
                let v = stops_index;
                scores.insert(record.0, v);
                stops_index += 1;
                v
            }
            Some(i) => *i,
        };

        let to_id = match scores.get(&record.1) {
            None => {
                let v = stops_index;
                scores.insert(record.1, v);
                stops_index += 1;
                v
            }
            Some(i) => *i,
        };

        let trip_id = match scores.get(&record.5) {
            None => {
                let v = trip_index;
                scores.insert(record.5, v);
                trip_index += 1;
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

    max_time
}

fn parse_requests(scores: &HashMap<String, usize>, requests: &mut Vec<Request>) -> usize {
    let mut total = 0usize;

    let rdr = csv::ReaderBuilder::new()
        .has_headers(true)
        .delimiter(b';')
        .from_path("../data/transport/florence/requests_K10747_N30965.csv")
        .unwrap();

    for result in rdr.into_deserialize() {
        let record: RequestRecord = result.unwrap();

        if let Some(v) = scores.get(&record.0) {
            if let Some(w) = scores.get(&record.1) {
                let req = Request {
                    from_id: *v,
                    to_id: *w,
                    departure_time: record.2,
                    multiplicity: record.3,
                };
                total += req.multiplicity;
                requests.push(req);
            } else {
                continue;
            };
        } else {
            continue;
        };
    }

    total
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
                            None => Some(ta),
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

    for _ in 0..k {
        let m = rng.gen_range(0..total);

        let (mut lo, mut hi) = (0, multiplicities.len() - 1);

        // Binary search: find the first index lo such that multiplicities[lo] >= m.
        while lo < hi {
            let mid = (lo + hi) >> 1;
            if multiplicities[mid] < m {
                lo = mid + 1;
            } else {
                hi = mid;
            }
        }

        let choosen = &requests[lo];

        let unary_request = Request {
            from_id: choosen.from_id,
            to_id: choosen.to_id,
            departure_time: choosen.departure_time,
            multiplicity: 1,
            //..*choosen
        };

        sample.push(unary_request);
    }

    sample
}

fn estimate<'a>(
    sample: &Vec<Request>,
    max_time: usize,
    num_nodes: usize,
    edges: &'a Vec<Edge>,
) -> (HashMap<&'a Edge, f64>, f64) {
    let mut crowding_vector = HashMap::new();

    let mut at = 0;

    let total = sample.iter().fold(0, |acc, req| acc + req.multiplicity) as f64;

    for req in sample.iter() {
        println!("*{:?}", req);
        let fmul = (req.multiplicity as f64) / total;
        let paths =
            earliest_arrival_paths(req.from_id, req.departure_time, max_time, num_nodes, edges);
        let path = reify_path(req.to_id, &paths);
        for edge in path {
            println!("** {:?}", edge);
            let c = crowding_vector.entry(edge).or_insert(0.0);
            *c += fmul;
            at += req.multiplicity * edge.duration;
        }
    }

    (crowding_vector, (at as f64) / total)
}

fn main() {
    let mut scores = HashMap::new();
    let mut edges: Vec<Edge> = Vec::new();
    let mut requests: Vec<Request> = Vec::new();

    let max_time = parse_edges(&mut scores, &mut edges);
    parse_requests(&mut scores, &mut requests);

    let sampled = sample(381, &requests);

    let (crowding_vector, at) = estimate(&sampled, max_time, scores.len(), &edges);

    println!("{:?}", crowding_vector);

    println!("{:?}", at);
}
