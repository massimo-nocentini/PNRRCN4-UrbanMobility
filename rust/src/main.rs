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
        "|V| = {}, |E| = {}, |Q| = {}, |P| = {}, k = {}, repetitions = {}.",
        graph.vertices.len(),
        graph.edges.len(),
        requests.requests.len(),
        requests.total,
        k,
        repetitions
    );

    // let at_true = 0.0;
    // let aw_true = 0.0;

    let exact = requests.estimate(time_step, &graph, &mut temporal_paths);

    let at_true = exact.average_travelling_time;
    let aw_true = exact.average_waiting_time;

    let mut at = Vec::new();
    let mut aw = Vec::new();

    let mut cw = HashMap::new();
    let mut om = HashMap::new();

    for _ in 0..repetitions {
        let sampled = requests.sample(k);
        let estimation = sampled.estimate(time_step, &graph, &mut temporal_paths);

        at.push(estimation.average_travelling_time);
        aw.push(estimation.average_waiting_time);

        for (edge, fmul) in estimation.crowding_vector {
            cw.entry(edge)
                .and_modify(|e| *e = *e + fmul)
                .or_insert(fmul);
        }

        for (key, fmul) in estimation.occupancy_matrix {
            om.entry(key).and_modify(|e| *e = *e + fmul).or_insert(fmul);
        }
    }

    let freps = repetitions as f64;

    let at_mean = at.iter().sum::<f64>() / freps;
    let aw_mean = aw.iter().sum::<f64>() / freps;

    let at_var = at.iter().map(|x| (x - at_mean).powi(2)).sum::<f64>() / freps;
    let aw_var = aw.iter().map(|x| (x - aw_mean).powi(2)).sum::<f64>() / freps;

    let at_coeff_var = at_var.sqrt() / at_mean;
    let aw_coeff_var = aw_var.sqrt() / aw_mean;

    println!(
        "Average travelling time: true {:?}, estimated {:?} (std: {}, CoV: {}).",
        Duration::from_secs_f64(at_true),
        Duration::from_secs_f64(at_mean),
        at_var.sqrt(),
        at_coeff_var
    );

    println!(
        "Average waiting time: true {:?}, estimated {:?} (std: {}, CoV: {}).",
        Duration::from_secs_f64(aw_true),
        Duration::from_secs_f64(aw_mean),
        aw_var.sqrt(),
        aw_coeff_var
    );

    let mut cw_named = Vec::new();
    for (edge, fmul) in cw.iter() {
        let from_name = graph.vertices_rev.get(&edge.from_id).unwrap();
        let to_name = graph.vertices_rev.get(&edge.to_id).unwrap();
        cw_named.push((from_name, to_name, edge.departure_time, fmul, edge));
    }

    cw_named.sort_by(|a, b| b.3.cmp(a.3));

    println!("Top 50 crowded edges:");
    for (from, to, d, fmul, edge) in cw_named.iter().take(50) {
        println!(
            "\t{} -> {}: {:.3} (exact {}) people at {:?}.",
            from,
            to,
            **fmul,// as f64) / (repetitions as f64),
            exact.crowding_vector.get(*edge).unwrap(),
            Duration::from_secs(*d as u64)
        );
    }

    let mut om_named = HashMap::new();

    for ((v, t), fmul) in om.iter() {
        let v_name = graph.vertices_rev.get(v).unwrap();

        let exact = match exact.occupancy_matrix.get(&(*v, *t)) {
            None => 0,
            Some(e) => *e,
        };

        match om_named.get_mut(t) {
            None => {
                let mut m = HashMap::new();
                m.insert(v_name, (*fmul, exact));
                om_named.insert(t, m);
            }
            Some(m) => {
                m.entry(v_name)
                    .and_modify(|e| {
                        e.0 += *fmul;
                        e.1 += exact
                    })
                    .or_insert((*fmul, exact));
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
            entry
                .entry(*v)
                .and_modify(|e: &mut (usize, usize)| {
                    e.0 += fmul.0;
                    e.1 += fmul.1
                })
                .or_insert(*fmul);
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

    om_named_grouped_vec.sort_by(|a, b| {
        a.1.iter()
            .map(|each| each.1 .0)
            .sum::<usize>()
            .cmp(&b.1.iter().map(|each| each.1 .0).sum::<usize>())
            .reverse()
    });

    println!("Ordered crowded stops grouped by time step:");
    for (t, m) in om_named_grouped_vec {
        println!("\tAfter {:?}:", Duration::from_secs(t as u64));
        for (v, fmul) in m.iter() {
            println!(
                "\t\t{}: {:.3} people (exact {:.3}).",
                v,
                fmul.0,// as f64 / (repetitions as f64),
                fmul.1// as f64 / (requests.total as f64)
            );
        }
    }
}
