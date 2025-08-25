
echo:
	echo "Usage: make run"

batch:
	time cargo run --release --bin batch -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv > ../data/transport/florence/analysis.csv

single-generic:
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/adelaide/edges.csv ../data/transport/adelaide/requests_K75480_N754800.csv  $(REPS) $(K) Adelaide > ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/belfast/edges.csv ../data/transport/belfast/requests_K19170_N191700.csv  $(REPS) $(K) Belfast >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/berlin/edges.csv ../data/transport/berlin/requests_K46010_N460100.csv  $(REPS) $(K) Berlin >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/bordeaux/edges.csv ../data/transport/bordeaux/requests_K34350_N343500.csv  $(REPS) $(K) Bordeaux >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/brisbane/edges.csv ../data/transport/brisbane/requests_K96450_N964500.csv  $(REPS) $(K) Brisbane >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/canberra/edges.csv ../data/transport/canberra/requests_K27640_N276400.csv  $(REPS) $(K) Canberra >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/detroit/edges.csv ../data/transport/detroit/requests_K56830_N568300.csv  $(REPS) $(K) Detroit >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/dublin/edges.csv ../data/transport/dublin/requests_K45710_N457100.csv  $(REPS) $(K) Dublin >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/grenoble/edges.csv ../data/transport/grenoble/requests_K15470_N154700.csv  $(REPS) $(K) Grenoble >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/helsinki/edges.csv ../data/transport/helsinki/requests_K69860_N698600.csv  $(REPS) $(K) Helsinki >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/kuopio/edges.csv ../data/transport/kuopio/requests_K5490_N54900.csv  $(REPS) $(K) Kuopio >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/lisbon/edges.csv ../data/transport/lisbon/requests_K70730_N707300.csv  $(REPS) $(K) Lisbon >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/luxembourg/edges.csv ../data/transport/luxembourg/requests_K13670_N136700.csv  $(REPS) $(K) Luxembourg >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/melbourne/edges.csv ../data/transport/melbourne/requests_K194930_N1949300.csv  $(REPS) $(K) Melbourne >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/nantes/edges.csv ../data/transport/nantes/requests_K23530_N235300.csv  $(REPS) $(K) Nantes >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/palermo/edges.csv ../data/transport/palermo/requests_K21760_N217600.csv  $(REPS) $(K) Palermo >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/paris/edges.csv ../data/transport/paris/requests_K11950_N1195000.csv  $(REPS) $(K) Paris >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/prague/edges.csv ../data/transport/prague/requests_K51470_N514700.csv  $(REPS) $(K) Prague >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/rennes/edges.csv ../data/transport/rennes/requests_K14070_N140700.csv  $(REPS) $(K) Rennes >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/rome/edges.csv ../data/transport/rome/requests_K78690_N786900.csv  $(REPS) $(K) Rome >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/sydney/edges.csv ../data/transport/sydney/requests_K240630_N2406300.csv  $(REPS) $(K) Sydney >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/toulouse/edges.csv ../data/transport/toulouse/requests_K33290_N332900.csv  $(REPS) $(K) Toulouse >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/turku/edges.csv ../data/transport/turku/requests_K18500_N185000.csv  $(REPS) $(K) Turku >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/venice/edges.csv ../data/transport/venice/requests_K18740_N187400.csv  $(REPS) $(K) Venice >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv
	time cargo run --release --bin $(SINGLE_BIN) -- ../data/transport/winnipeg/edges.csv ../data/transport/winnipeg/requests_K50790_N507900.csv  $(REPS) $(K) Winnipeg >> ../data/transport/$(SINGLE_BIN)-$(REPS)-$(K).csv

single-by-k-bench:
	SINGLE_BIN=single-by-k REPS=1 K=1124 make single-generic &
	SINGLE_BIN=single-by-k REPS=10 K=1124 make single-generic &
	SINGLE_BIN=single-by-k REPS=100 K=1124 make single-generic &	
	SINGLE_BIN=single-by-k REPS=500 K=1124 make single-generic &
	SINGLE_BIN=single-by-k REPS=1000 K=1124 make single-generic &
	SINGLE_BIN=single-by-k REPS=5000 K=1124 make single-generic &
	SINGLE_BIN=single-by-k REPS=10000 K=1124 make single-generic &
	SINGLE_BIN=single-by-k REPS=50000 K=1124 make single-generic &
	SINGLE_BIN=single-by-k REPS=100000 K=1124 make single-generic &

single-by-k:
	SINGLE_BIN=single-by-k REPS=50 K=1 make single-generic &
	SINGLE_BIN=single-by-k REPS=50 K=10 make single-generic &
	SINGLE_BIN=single-by-k REPS=50 K=100 make single-generic &
	SINGLE_BIN=single-by-k REPS=50 K=500 make single-generic &
	SINGLE_BIN=single-by-k REPS=50 K=1000 make single-generic &
	SINGLE_BIN=single-by-k REPS=50 K=5000 make single-generic &

single-by-epsilon:
	SINGLE_BIN=single-by-epsilon REPS=50 K=0.1 make single-generic

full:
	time cargo run --release --bin rust -- ../data/transport/florence/edges.csv ../data/transport/florence/requests_K10747_N30965.csv 0.1 50 300 > ../data/transport/florence/analysis-0.1e-50reps-300s.txt

csv:
	cd ../data/js && node compose.js > single-all.csv && node batch.js > batch.csv