Class {
	#name : 'PNRRFruitMBitCoinSampleForDiameter',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleForDiameter >> sampleVertex: each bfs: bfs crossDistances: cross [

	^ bfs layers
		  ifEmpty: [ each ]
		  ifNotEmpty: [ :ls | bfs distances keys atRandom: random ]
]
