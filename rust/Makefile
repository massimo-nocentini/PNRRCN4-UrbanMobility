
echo:
	@echo "Usage: make run"

batch:
	time cargo run --release --bin batch -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 300 > ../data/transport/florence/analysis.csv
	
single:
	time cargo run --release --bin single -- ../data/transport/adelaide/edges.csv ../data/transport/adelaide/requests_K75480_N754800.csv 300 Adelaide > ../data/transport/single.csv
	time cargo run --release --bin single -- ../data/transport/belfast/edges.csv ../data/transport/belfast/requests_K19170_N191700.csv 300 Belfast >> ../data/transport/single.csv
	time cargo run --release --bin single -- ../data/transport/berlin/edges.csv ../data/transport/berlin/requests_K46010_N460100.csv 300 Berlin >> ../data/transport/single.csv
	time cargo run --release --bin single -- ../data/transport/bordeaux/edges.csv ../data/transport/bordeaux/requests_K34350_N343500.csv 300 Bordeaux >> ../data/transport/single.csv
	time cargo run --release --bin single -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 300 Florence >> ../data/transport/single.csv

run:
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.1 1 300 > ../data/transport/florence/analysis-0.1e-1reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.1 5 300 > ../data/transport/florence/analysis-0.1e-5reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.1 10 300 > ../data/transport/florence/analysis-0.1e-10reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.1 20 300 > ../data/transport/florence/analysis-0.1e-20reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.1 50 300 > ../data/transport/florence/analysis-0.1e-50reps-300s.txt

	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.2 1 300 > ../data/transport/florence/analysis-0.2e-1reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.2 5 300 > ../data/transport/florence/analysis-0.2e-5reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.2 10 300 > ../data/transport/florence/analysis-0.2e-10reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.2 20 300 > ../data/transport/florence/analysis-0.2e-20reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.2 50 300 > ../data/transport/florence/analysis-0.2e-50reps-300s.txt
	
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.4 1 300 > ../data/transport/florence/analysis-0.4e-1reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.4 5 300 > ../data/transport/florence/analysis-0.4e-5reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.4 10 300 > ../data/transport/florence/analysis-0.4e-10reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.4 20 300 > ../data/transport/florence/analysis-0.4e-20reps-300s.txt
	#time cargo run --release -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.4 50 300 > ../data/transport/florence/analysis-0.4e-50reps-300s.txt
	
	time cargo run --release --bin rust -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.8 1 300 > ../data/transport/florence/analysis-0.8e-1reps-300s.txt
	time cargo run --release --bin rust -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.8 5 300 > ../data/transport/florence/analysis-0.8e-5reps-300s.txt
	time cargo run --release --bin rust -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.8 10 300 > ../data/transport/florence/analysis-0.8e-10reps-300s.txt
	time cargo run --release --bin rust -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.8 20 300 > ../data/transport/florence/analysis-0.8e-20reps-300s.txt
	time cargo run --release --bin rust -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.8 50 300 > ../data/transport/florence/analysis-0.8e-50reps-300s.txt