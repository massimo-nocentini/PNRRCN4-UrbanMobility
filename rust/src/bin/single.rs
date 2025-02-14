use rust::temporal_graph::{RequestSample, TemporalGraph};
use std::env;
use std::{collections::HashMap, usize};

fn main() {
    let args: Vec<String> = env::args().collect();

    let graph_filename = &args[1];
    let requests_filename = &args[2];
    let time_step = args[3].parse::<usize>().unwrap();
    let epsilon = args[4].parse::<f64>().unwrap();
    let city = &args[5];

    let graph = TemporalGraph::parse(&graph_filename);
    let mut temporal_paths = HashMap::new();

    let requests = RequestSample::parse(&requests_filename, &graph);

    let exact = requests.estimate(time_step, &graph, &mut temporal_paths);

    

    let k =
        (((requests.requests.len() as f64).ln() / (epsilon.powi(2) * 2.0)).ceil() as usize).min(requests.requests.len());

    let repetitions = 50;
    let mut at = Vec::new();
    let mut aw = Vec::new();

    for _ in 0..repetitions {
        let sampled = requests.sample(k);
        let estimation = sampled.estimate(time_step, &graph, &mut temporal_paths);

        at.push(estimation.average_travelling_time);
        aw.push(estimation.average_waiting_time);
    }

    let freps = repetitions as f64;

    let at_mean = at.iter().sum::<f64>() / freps;
    let aw_mean = aw.iter().sum::<f64>() / freps;

    let at_var = at.iter().map(|x| (x - at_mean).powi(2)).sum::<f64>() / freps;
    let aw_var = aw.iter().map(|x| (x - aw_mean).powi(2)).sum::<f64>() / freps;

    let at_coeff_var = at_var.sqrt() / at_mean;
    let aw_coeff_var = aw_var.sqrt() / aw_mean;

    println!(
        "{} & {} & {} & {} & {} & {} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} \\\\",
        city,
        graph.vertices.len(),
        graph.edges.len(),
        requests.requests.len(),
        requests.total,
        k,
        exact.average_travelling_time, 
        at_mean,
        (at_mean - exact.average_travelling_time).abs(),
        at_var.sqrt(),
        at_coeff_var,
        exact.average_waiting_time,
        aw_mean,
        (aw_mean - exact.average_waiting_time).abs(),
        aw_var.sqrt(),
        aw_coeff_var,
    );
}
