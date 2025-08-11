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

    let exact = requests.estimate( &graph, &mut temporal_paths);

    println!(
        "True averages: travelling time {:.3}, waiting time {:.3}; computed in {:?}.",
        exact.average_travelling_time_as_f64(), exact.average_waiting_time_as_f64(), exact.elapsed
    );

    println!("Epsilon & k & repetitions & AT mean & |AT - true| & AT std & AT CV & AW mean & |AW - true| & AW std & AW CV \\\\",);

    for k in [1, 6, 24, 96, 169, 381, 1521, 6081] {
        let epsilon = ((2.0 / p).ln() / (2.0 * (k as f64))).sqrt();

        for repetitions in [1, 5, 10, 50, 100] {
            let mut at = Vec::new();
            let mut aw = Vec::new();

            let elapsed = std::time::Instant::now();

            let mut avg_crowding = HashMap::new();
            let mut avg_om = HashMap::new();

            for _ in 0..repetitions {
                let sampled = requests.sample(k);
                let estimation = sampled.estimate( &graph, &mut temporal_paths);

                for (&edge, &crowding) in estimation.crowding_vector.iter() {
                    avg_crowding
                        .entry(edge)
                        .and_modify(|e| *e += crowding)
                        .or_insert(crowding);
                }

                for (&edge, &om) in estimation.occupancy_matrix.iter() {
                    avg_om.entry(edge).and_modify(|e| *e += om).or_insert(om);
                }

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

            let avg_crowding_normalized: HashMap<_, _> = avg_crowding
                .iter()
                .map(|(&edge, &crowding)| (edge, crowding as f64 / repetitions as f64))
                .collect();

            let mut crowing_errors = Vec::new();
            for (&e, &c) in exact.crowding_vector.iter() {
                if c > 0 {
                    let normalized_crowding = avg_crowding_normalized.get(&e).unwrap_or(&0.0);
                    let error = ((c as f64) - normalized_crowding).abs();
                    crowing_errors.push(error);
                }
            }
            let avg_crowding_error =
                crowing_errors.iter().sum::<f64>() / crowing_errors.len() as f64;
            let var_crowding_error = crowing_errors
                .iter()
                .map(|x| (x - avg_crowding_error).powi(2))
                .sum::<f64>()
                / crowing_errors.len() as f64;

            let avg_crowding_error_coeff_var = var_crowding_error.sqrt() / avg_crowding_error;

            let mut om_errors = Vec::new();
            for (&e, &om) in exact.occupancy_matrix.iter() {
                if om > 0 {
                    let normalized_om = avg_om.get(&e).unwrap_or(&0);
                    let error = (om as f64) - (*normalized_om as f64);
                    om_errors.push(error);
                }
            }
            let avg_om_error = om_errors.iter().sum::<f64>() / om_errors.len() as f64;
            let var_om_error = om_errors
                .iter()
                .map(|x| ((*x as f64) - avg_om_error).powi(2))
                .sum::<f64>()
                / om_errors.len() as f64;
            let avg_om_error_coeff_var = var_om_error.sqrt() / avg_om_error;

            println!(
                "{:.3} & {} & {} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:?} & {:.3} \\\\",
                epsilon,
                k,
                repetitions,
                (at_mean - exact.average_travelling_time_as_f64()).abs(),
                at_coeff_var,
                (aw_mean - exact.average_waiting_time_as_f64()).abs(),
                aw_coeff_var,
                avg_crowding_error.abs(),
                avg_crowding_error_coeff_var,
                avg_om_error.abs(),
                avg_om_error_coeff_var,                
                elapsed.elapsed(),
                exact.elapsed.as_secs_f64() / elapsed.elapsed().as_secs_f64(),
            );

            // println!(
            //     "{:.3} & {} & {} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:.3} & {:?} & {:?} & {:.3} \\\\",
            //     epsilon,
            //     k,
            //     repetitions,
            //     at_mean,
            //     (at_mean - exact.average_travelling_time).abs(),
            //     at_var.sqrt(),
            //     at_coeff_var,
            //     aw_mean,
            //     (aw_mean - exact.average_waiting_time).abs(),
            //     aw_var.sqrt(),
            //     aw_coeff_var,
            //     exact.elapsed,
            //     elapsed.elapsed(),
            //     exact.elapsed.as_secs_f64() / elapsed.elapsed().as_secs_f64(),
            // );
        }
    }
}
