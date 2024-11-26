Class {
	#name : 'PNRRFruitMBitCoinSample',
	#superclass : 'Object',
	#instVars : [
		'sample'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'estimation' }
PNRRFruitMBitCoinSample >> averageDistance [

	| distance count |
	distance := 0.
	count := 0.

	self sample do: [ :vertex |
		vertex breadthFirstSearch distances valuesDo: [ :dist |
			distance := distance + dist.
			count := count + 1 ] ].

	^ (distance / count) asFloat
]

{ #category : 'estimation' }
PNRRFruitMBitCoinSample >> diameter [

	| diameters |
	diameters := self sample collect: [ :vertex |
		             vertex breadthFirstSearch layers size ].

	^ diameters average asFloat
]

{ #category : 'printing' }
PNRRFruitMBitCoinSample >> printOn: aStream [

	aStream << 'a sample of size '.

	self sample size printOn: aStream
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> sample [

	^ sample
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSample >> sample: anObject [

	sample := anObject
]
