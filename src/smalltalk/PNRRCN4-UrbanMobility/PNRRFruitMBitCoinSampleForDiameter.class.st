Class {
	#name : 'PNRRFruitMBitCoinSampleForDiameter',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleForDiameter >> aggregateDistances: distances [

	^ distances max
]

{ #category : 'estimation' }
PNRRFruitMBitCoinSampleForDiameter >> estimate [

	| diameters |
	diameters := self sample collect: [ :vertex |
		             vertex breadthFirstSearch layers size ].

	^ diameters average asFloat
]
