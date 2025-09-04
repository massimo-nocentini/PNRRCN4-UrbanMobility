use rust::temporal_graph::{single, RequestSample, TemporalGraph};
use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();

    let graph_filename = &args[1];
    let requests_filename = &args[2];
    let city = &args[5];

    let graph = TemporalGraph::parse(&graph_filename);
    let requests = RequestSample::parse(&requests_filename, &graph);
    let nrequests = requests.requests.len();
    let mut ats = Vec::new();
    let mut avgs = Vec::new();
    //for _k in 1..=nrequests {
    for _k in 1..=1_000_000 {
        let k = 1;
        let epsilon = ((nrequests as f64).ln() / (k as f64)).sqrt();
        let (at, _aw) = single(1, epsilon, 1, city, &graph, &requests);
        ats.push(at);
        avgs.push(ats.iter().sum::<f64>() / (ats.len() as f64));
    }

    println!("{:?}", avgs);
}
