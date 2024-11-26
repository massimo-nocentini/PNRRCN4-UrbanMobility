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
PNRRFruitMBitCoinSample >> aggregateDistances: distances [

	self subclassResponsibility
]

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

	sample := aCollection
		          samplingWithEpsilon: epsilon
		          random: random
		          collect: [ :each |
			          | cross |
			          cross := Dictionary new.

			          each breadthFirstSearchBackwardDo: [ :v :d |
				          cross
					          at: v
					          ifPresent: [ :col | col add: d ]
					          ifAbsentPut: [ OrderedCollection with: d ] ].

			          cross ifEmpty: [ each ] ifNotEmpty: [
				          | init distances |
				          distances := OrderedCollection new: cross size.
				          init := 0.

				          cross keysAndValuesDo: [ :v :ds |
					          init := init + (self aggregateDistances: ds).
					          distances add: v -> init ].

				          (distances weightedSample: #value random: random) key ] ]
]
