Class {
	#name : 'PNRRFruitMBitCoinSampleByBfsUniform',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleByBfsUniform >> sampleVertex: each bfs: bfs crossDistances: cross [

	^ cross
		  ifEmpty: [ each ]
		  ifNotEmpty: [ cross keys atRandom: self random ]
]
