Class {
	#name : 'PNRRFruitMBitCoinSampleForAverageDistance',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

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

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleForAverageDistance >> sampleVertex: each bfs: bfs crossDistances: cross [

	^ cross ifEmpty: [ each ] ifNotEmpty: [
		  | init distances |
		  distances := OrderedCollection new: cross size.
		  init := 0.

		  cross keysAndValuesDo: [ :v :ds |
			  init := init + ds size.
			  distances add: v -> init ].

		  (distances weightedSample: #value random: random) key ]
]
