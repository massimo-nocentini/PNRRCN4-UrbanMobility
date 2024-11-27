Class {
	#name : 'PNRRFruitMBitCoinBench',
	#superclass : 'Object',
	#instVars : [
		'epsilons',
		'filenames',
		'repetitions',
		'random'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'benchmarking' }
PNRRFruitMBitCoinBench >> bench [

	Transcript
		cr;
		nextPutAll: '|';
		nextPutAll: 'filename';
		nextPutAll: '|';
		nextPutAll: 'vertices';
		nextPutAll: '|';
		nextPutAll: 'epsilon';
		nextPutAll: '|';
		nextPutAll: 'sample size';
		nextPutAll: '|';
		nextPutAll: 'repetitions';
		nextPutAll: '|';
		nextPutAll: 'estim diameter';
		nextPutAll: '|';
		nextPutAll: 'elapsed time';
		nextPutAll: '|';
		nextPutAll: 'estim avg distance';
		nextPutAll: '|';
		nextPutAll: 'elapsed time';
		nextPutAll: '|';
		nextPutAll: 'true diameter';
		nextPutAll: '|';
		nextPutAll: 'elapsed time';
		nextPutAll: '|';
		nextPutAll: 'true avg distance';
		nextPutAll: '|';
		nextPutAll: 'elapsed time';
		nextPutAll: '|';
		flush.

	Transcript
		cr;
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		nextPutAll: '---';
		nextPutAll: '|';
		flush.

	self filenames do: [ :filename |
		self epsilons do: [ :epsilon |
			self repetitions do: [ :n |
				| g |
				g := PNRRFruitMBitCoinGraph onFileReference:
					     filename asFileReference.
				self
					filename: filename
					graph: g
					epsilon: epsilon
					n: n ] ] ]
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> epsilons [

	^ epsilons
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> epsilons: anObject [

	epsilons := anObject
]

{ #category : 'benchmarking' }
PNRRFruitMBitCoinBench >> filename: filename graph: g epsilon: epsilon n: n [

	| vertices td d ta a ds as interval trued truea ttrued ttruea |
	interval := 1 to: n.

	vertices := g asVerticesArray.

	td := [
	      d := (interval collect: [ :i |
		            ds := PNRRFruitMBitCoinSampleForDiameter new
			                  random: self random;
			                  epsilon: epsilon;
			                  sample: vertices;
			                  yourself.
		            ds estimate ]) average ] timeToRun.

	ta := [
	      a := (interval collect: [ :i |
		            as := PNRRFruitMBitCoinSampleForAverageDistance new
			                  random: self random;
			                  epsilon: epsilon;
			                  sample: vertices;
			                  yourself.
		            as estimate ]) average ] timeToRun.


	ttrued := [ trued := g diameter ] timeToRun.

	ttruea := [ truea := g averageDistance ] timeToRun.


	Transcript
		cr;
		nextPutAll: '|';
		nextPutAll: filename;
		nextPutAll: '|';
		nextPutAll: vertices size asString;
		nextPutAll: '|';
		nextPutAll: epsilon asString;
		nextPutAll: '|';
		nextPutAll: ds sample size asString;
		nextPutAll: '|';
		nextPutAll: n asString;
		nextPutAll: '|';
		nextPutAll: d asString;
		nextPutAll: '|';
		nextPutAll: td asString;
		nextPutAll: '|';
		nextPutAll: a asString;
		nextPutAll: '|';
		nextPutAll: ta asString;
		nextPutAll: '|';
		nextPutAll: trued asString;
		nextPutAll: '|';
		nextPutAll: ttrued asString;
		nextPutAll: '|';
		nextPutAll: truea asString;
		nextPutAll: '|';
		nextPutAll: ttruea asString;
		nextPutAll: '|';
		flush
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> filenames [

	^ filenames
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> filenames: anObject [

	filenames := anObject
]

{ #category : 'initialization' }
PNRRFruitMBitCoinBench >> initialize [

	super initialize.

	self
		filenames: {  };
		epsilons: { 1. 0.8. 0.2. 0.1 };
		repetitions: { 1. 10. 30 };
		random: (RSRandom seed: Number firstCarmichaelNumber)
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> random [

	^ random
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> random: anObject [

	random := anObject
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> repetitions [

	^ repetitions
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> repetitions: anObject [

	repetitions := anObject
]
