use rust::temporal_graph::{RequestSample, TemporalGraph};
use std::env;
use std::{collections::HashMap, usize};

fn main() {
    let args: Vec<String> = env::args().collect();

    let p = 0.001_f64;

    let graph_filename = &args[1];
    let requests_filename = &args[2];
    let time_step = args[3].parse::<usize>().unwrap();

    let graph = TemporalGraph::parse(&graph_filename);
    let mut temporal_paths = HashMap::new();

    let requests = RequestSample::parse(&requests_filename, &graph);

    print!(
        "|V| = {}, |E| = {}, |Q| = {}, |P| = {}, ",
        graph.vertices.len(),
        graph.edges.len(),
        requests.requests.len(),
        requests.total,
    );

    let exact = requests.estimate(time_step, &graph, &mut temporal_paths);

    println!(
        "True averages: travelling time {:.3}, waiting time {:.3}.",
        exact.average_travelling_time, exact.average_waiting_time,
    );

    println!("Epsilon & k & repetitions & AT mean & |AT - true| & AT std & AT CV & AW mean & |AW - true| & AW std & AW CV \\\\",);

    for epsilon in [0.8_f64, 0.4, 0.2, 0.15, 0.1, 0.05, 0.025] {
        let k = (((2.0 / p).ln() / (2.0 * epsilon.powi(2))).ceil() as usize)
            .min(requests.requests.len());
        for repetitions in [5, 10, 50, 100] {
            let mut at = Vec::new();
            let mut aw = Vec::new();

            let elapsed = std::time::Instant::now();

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
                "{} & {} & {} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:?} & {:?} & {:.3} \\\\",
                epsilon,
                k,
                repetitions,
                at_mean,
                (at_mean - exact.average_travelling_time).abs(),
                at_var.sqrt(),
                at_coeff_var,
                aw_mean,
                (aw_mean - exact.average_waiting_time).abs(),
                aw_var.sqrt(),
                aw_coeff_var,
                exact.elapsed,
                elapsed.elapsed(),
                exact.elapsed.as_secs_f64() / elapsed.elapsed().as_secs_f64(),
            );
        }
    }
}
