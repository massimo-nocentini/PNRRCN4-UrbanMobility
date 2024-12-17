
webgraph from arcs --exact --num-nodes 842 1k-0001p < 1k-0.001p.csv
webgraph from arcs --exact --source-column 1 --target-column 0 --num-nodes 842 1k-0001p-t < 1k-0.001p.csv
webgraph build ef 1k-0001p
webgraph build ef 1k-0001p-t

webgraph from arcs --exact --num-nodes 1964 2k-0001p < 2k-0.001p.csv
webgraph from arcs --exact --source-column 1 --target-column 0 --num-nodes 1964 2k-0001p-t < 2k-0.001p.csv
webgraph build ef 2k-0001p
webgraph build ef 2k-0001p-t

webgraph from arcs --exact --num-nodes 5000 5k-0001p < 5k-0.001p.csv
webgraph from arcs --exact --source-column 1 --target-column 0 --num-nodes 5000 5k-0001p-t < 5k-0.001p.csv
webgraph build ef 5k-0001p
webgraph build ef 5k-0001p-t

