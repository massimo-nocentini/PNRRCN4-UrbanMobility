use rust::temporal_graph::{single, RequestSample, TemporalGraph};
use std::env;
use std::usize;

fn main() {
    let args: Vec<String> = env::args().collect();

    let graph_filename = &args[1];
    let requests_filename = &args[2];
    let repetitions = args[3].parse::<usize>().unwrap();
    let k = args[4].parse::<usize>().unwrap();
    let city = &args[5];

    let graph = TemporalGraph::parse(&graph_filename);
    let requests = RequestSample::parse(&requests_filename, &graph);
    let epsilon = ((requests.requests.len() as f64).ln() / (k as f64)).sqrt();

    single(k, epsilon, repetitions, city, &graph, &requests);
}
