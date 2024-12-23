// Date: 2021-09-26

use std::collections::HashMap;

use csv::Error;

// from_stop_I;to_stop_I;dep_time_ut;arr_time_ut;route_type;trip_I;seq;route_I
type EdgeRecord = (String, String, usize, usize, usize, String, usize, usize);

#[derive(Debug)]
struct Edge {
    from_stop_id: usize,
    to_stop_id: usize,
    departure_time: usize,
    arrival_time: usize,
    route_type: usize,
    trip_id: usize,
    seq: usize,
    route_id: usize,
}

fn main() {
    let rdr = csv::ReaderBuilder::new()
        .has_headers(true)
        .delimiter(b';')
        .from_path("../data/transport/florence/edges.csv")
        .unwrap();

    let mut stops_index = 0usize;
    let mut trip_index = 0usize;
    let mut scores = HashMap::new();
    let mut edges: Vec<Edge> = Vec::new();

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
            from_stop_id: from_id,
            to_stop_id: to_id,
            departure_time: record.2,
            arrival_time: record.3,
            route_type: record.4,
            trip_id: trip_id,
            seq: record.6,
            route_id: record.7,
        };

        edges.push(edge);
    }

    println!("{:?}", edges);
}
