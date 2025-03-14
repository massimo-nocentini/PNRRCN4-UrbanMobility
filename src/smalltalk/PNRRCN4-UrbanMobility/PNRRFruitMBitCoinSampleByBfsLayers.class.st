Class {
	#name : 'PNRRFruitMBitCoinSampleByBfsLayers',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleByBfsLayers >> sampleVertex: each bfs: bfs crossDistances: cross [

	^ bfs layers
		  ifEmpty: [ each ]
		  ifNotEmpty: [ :layers | layers first atRandom: random ]
]
