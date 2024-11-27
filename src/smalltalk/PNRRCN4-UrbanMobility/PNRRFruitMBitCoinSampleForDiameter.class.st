Class {
	#name : 'PNRRFruitMBitCoinSampleForDiameter',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'estimation' }
PNRRFruitMBitCoinSampleForDiameter >> estimate [

	| sum count |
	sum := 0.
	count := 0.
	originalVertices do: [ :vertex |
		vertex breadthFirstSearch distances keysAndValuesDo: [ :v :d |
			sum := sum + d ].

		count := count + vertex breadthFirstSearch distances size ].

	^ (sum / count) asFloat
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleForDiameter >> sampleVertex: each bfs: bfs crossDistances: cross [

	^ bfs layers
		  ifEmpty: [ each ]
		  ifNotEmpty: [ :ls | bfs distances keys atRandom: random ]
]
