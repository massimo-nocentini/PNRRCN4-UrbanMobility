
to-webgraph:
	webgraph from arcs --exact --num-nodes 5000 5k-0001p < 5k-0.001p.csv
	webgraph from arcs --exact --source-column 1 --target-column 0 --num-nodes 5000 5k-0001p-t < 5k-0.001p.csv
	webgraph build ef 5k-0001p
	webgraph build ef 5k-0001p-t
