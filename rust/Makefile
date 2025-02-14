
echo:
	@echo "Usage: make run"

batch:
	time cargo run --release --bin batch -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 300 > ../data/transport/florence/analysis.csv
	
single:
	time cargo run --release --bin single -- ../data/transport/adelaide/edges.csv ../data/transport/adelaide/requests_K75480_N754800.csv 300 0.1 Adelaide > ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/belfast/edges.csv ../data/transport/belfast/requests_K19170_N191700.csv 300 0.1 Belfast >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/berlin/edges.csv ../data/transport/berlin/requests_K46010_N460100.csv 300 0.1 Berlin >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/bordeaux/edges.csv ../data/transport/bordeaux/requests_K34350_N343500.csv 300 0.1 Bordeaux >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/brisbane/edges.csv ../data/transport/brisbane/requests_K96450_N964500.csv 300 0.1 Brisbane >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/canberra/edges.csv ../data/transport/canberra/requests_K27640_N276400.csv 300 0.1 Canberra >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/detroit/edges.csv ../data/transport/detroit/requests_K56830_N568300.csv 300 0.1 Detroit >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/dublin/edges.csv ../data/transport/dublin/requests_K45710_N457100.csv 300 0.1 Dublin >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 300 0.1 Florence >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/grenoble/edges.csv ../data/transport/grenoble/requests_K15470_N154700.csv 300 0.1 Grenoble >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/helsinki/edges.csv ../data/transport/helsinki/requests_K69860_N698600.csv 300 0.1 Helsinki >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/kuopio/edges.csv ../data/transport/kuopio/requests_K5490_N54900.csv 300 0.1 Kuopio >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/lisbon/edges.csv ../data/transport/lisbon/requests_K70730_N707300.csv 300 0.1 Lisbon >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/luxembourg/edges.csv ../data/transport/luxembourg/requests_K13670_N136700.csv 300 0.1 Luxembourg >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/melbourne/edges.csv ../data/transport/melbourne/requests_K194930_N1949300.csv 300 0.1 Melbourne >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/nantes/edges.csv ../data/transport/nantes/requests_K23530_N235300.csv 300 0.1 Nantes >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/palermo/edges.csv ../data/transport/palermo/requests_K21760_N217600.csv 300 0.1 Palermo >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/prague/edges.csv ../data/transport/prague/requests_K51470_N514700.csv 300 0.1 Prague >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/rennes/edges.csv ../data/transport/rennes/requests_K14070_N140700.csv 300 0.1 Rennes >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/rome/edges.csv ../data/transport/rome/requests_K78690_N786900.csv 300 0.1 Rome >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/sydney/edges.csv ../data/transport/sydney/requests_K240630_N2406300.csv 300 0.1 Sydney >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/toulouse/edges.csv ../data/transport/toulouse/requests_K33290_N332900.csv 300 0.1 Toulouse >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/turku/edges.csv ../data/transport/turku/requests_K18500_N185000.csv 300 0.1 Turku >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/venice/edges.csv ../data/transport/venice/requests_K18740_N187400.csv 300 0.1 Venice >> ../data/transport/single-0.1.csv
	time cargo run --release --bin single -- ../data/transport/winnipeg/edges.csv ../data/transport/winnipeg/requests_K50790_N507900.csv 300 0.1 Winnipeg >> ../data/transport/single-0.1.csv

full:
	time cargo run --release --bin rust -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.1 50 300 > ../data/transport/florence/analysis-0.1e-50reps-300s.txt