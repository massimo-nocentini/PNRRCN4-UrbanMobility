use rust::temporal_graph::{RequestSample, TemporalGraph};
use std::env;
use std::time::Duration;
use std::{collections::HashMap, usize};

fn main() {
    let args: Vec<String> = env::args().collect();

    let p = 0.001_f64;

    let graph_filename = &args[1];
    let requests_filename = &args[2];
    let epsilon = args[3].parse::<f64>().unwrap();
    let repetitions = args[4].parse::<usize>().unwrap();
    let time_step = args[5].parse::<usize>().unwrap();

    let graph = TemporalGraph::parse(&graph_filename);
    let mut temporal_paths = HashMap::new();

    let requests = RequestSample::parse(&requests_filename, &graph);

    let k =
        (((2.0 / p).ln() / (2.0 * epsilon.powi(2))).ceil() as usize).min(requests.requests.len());

    println!(
        "|V| = {}, |E| = {}, |Q| = {}, |P| = {}, k = {}.",
        graph.vertices.len(),
        graph.edges.len(),
        requests.requests.len(),
        requests.total,
        k
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
        let sampled = requests.sample(k);
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
