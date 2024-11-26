Class {
	#name : 'PNRRFruitMBitCoinSampleForDiameter',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'estimation' }
PNRRFruitMBitCoinSampleForDiameter >> estimate [

	| diameters |
	diameters := self sample collect: [ :vertex |
		             vertex breadthFirstSearch layers size ].

	^ diameters average asFloat
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleForDiameter >> sampleVertex: each bfs: bfs crossDistances: cross [

	^ bfs layers
		  ifEmpty: [ each ]
		  ifNotEmpty: [ :ls | ls last atRandom: random ]
]
