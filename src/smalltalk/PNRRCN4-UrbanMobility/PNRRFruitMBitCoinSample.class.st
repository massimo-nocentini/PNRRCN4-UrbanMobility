Class {
	#name : 'PNRRFruitMBitCoinSample',
	#superclass : 'Object',
	#instVars : [
		'sample',
		'random',
		'epsilon'
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

	self subclassResponsibility
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

	| cross c |
	cross := Dictionary new.

	c := aCollection
		     samplingWithEpsilon: epsilon
		     random: random
		     collect: [ :each |
			     | bfs |
			     bfs := each breadthFirstSearchBackward.

			     bfs distances keysAndValuesDo: [ :v :d |
				     cross
					     at: v
					     ifPresent: [ :col | col add: d ]
					     ifAbsentPut: [ OrderedCollection with: d ] ].

			     each -> bfs ].

	sample := c collect: [ :assoc |
		          self
			          sampleVertex: assoc key
			          bfs: assoc value
			          crossDistances: cross ]
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> sampleVertex: each bfs: bfs crossDistances: cross [

	self subclassResponsibility
]
