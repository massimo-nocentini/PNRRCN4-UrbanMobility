Class {
	#name : 'PNRRFruitMBitCoinBench',
	#superclass : 'Object',
	#instVars : [
		'epsilons',
		'filenames',
		'repetitions'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'benchmarking' }
PNRRFruitMBitCoinBench >> bench [

	self filenames do: [ :filename |
		self epsilons do: [ :epsilon |
			self repetitions do: [ :n |
				self filename: filename epsilon: epsilon n: n ] ] ]
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
PNRRFruitMBitCoinBench >> filename: filename epsilon: epsilon n: n [

	| g vertices td d ta a |
	g := PNRRFruitMBitCoinGraph onFileReference: filename asFileReference.

	vertices := g asVerticesArray.

	td := [
	      d := PNRRFruitMBitCoinSampleForDiameter new
		           sample: vertices;
		           estimate ] timeToRun.

	ta := [
	      a := PNRRFruitMBitCoinSampleForAverageDistance new
		           sample: vertices;
		           estimate ] timeToRun.

	Transcript
		nextPutAll: filename;
		tab;
		nextPutAll: vertices size asString
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
		repetitions: { 1. 10. 30 }
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> repetitions [

	^ repetitions
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBench >> repetitions: anObject [

	repetitions := anObject
]
