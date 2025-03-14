Class {
	#name : 'PNRRFruitMBitCoinSample',
	#superclass : 'Object',
	#instVars : [
		'sample',
		'random',
		'epsilon',
		'originalVertices'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> epsilon [

	^ epsilon
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> epsilon: anObject [

	epsilon := anObject
]

{ #category : 'estimation' }
PNRRFruitMBitCoinSample >> estimate [

	| sum count |
	sum := 0.
	count := 0.

	self sample do: [ :vertex |
		vertex breadthFirstSearch distances keysAndValuesDo: [ :v :d |
			sum := sum + d.
			count := count + 1 ] ].

	^ sum asFloat / count asFloat
]

{ #category : 'initialization' }
PNRRFruitMBitCoinSample >> initialize [

	super initialize.

	self
		epsilon: 0.1;
		random: (RSRandom seed: Number firstCarmichaelNumber)
]

{ #category : 'printing' }
PNRRFruitMBitCoinSample >> printOn: aStream [

	aStream << 'a sample of size '.

	self sample size printOn: aStream
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> random [

	^ random
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> random: anObject [

	random := anObject
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> sample [

	^ sample
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> sample: aCollection [

	| cross |
	originalVertices := aCollection.

	cross := Dictionary new.

	sample := aCollection
		          samplingWithEpsilon: epsilon
		          random: random
		          collect: [ :each |
			          | bfs |
			          bfs := each breadthFirstSearchBackward.

			          bfs distances keysAndValuesDo: [ :v :d |
				          cross at: v update: [ :dd | dd min: d ] initial: d ].

			          each -> bfs ].

	sample withIndexDo: [ :assoc :i |
		| v |
		v := self
			     sampleVertex: assoc key
			     bfs: assoc value
			     crossDistances: cross.

		sample at: i put: v ]
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> sampleVertex: each bfs: bfs crossDistances: cross [

	self subclassResponsibility
]
