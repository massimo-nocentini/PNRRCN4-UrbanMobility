Class {
	#name : 'PNRRFruitMBitCoinSampleForAverageDistance',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleForAverageDistance >> aggregateDistances: distances [

	^ distances size
]

{ #category : 'estimation' }
PNRRFruitMBitCoinSampleForAverageDistance >> estimate [

	| distance count |
	distance := 0.
	count := 0.

	self sample do: [ :vertex |
		vertex breadthFirstSearch distances valuesDo: [ :dist |
			distance := distance + dist.
			count := count + 1 ] ].

	^ (distance / count) asFloat
]
