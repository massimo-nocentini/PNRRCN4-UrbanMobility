Class {
	#name : 'PNRRFruitMBitCoinSampleByBfsCross',
	#superclass : 'PNRRFruitMBitCoinSample',
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleByBfsCross >> sampleVertex: each bfs: bfs crossDistances: cross [

	^ cross ifEmpty: [ each ] ifNotEmpty: [
		  | init distances j size |
		  size := cross size.
		  distances := OrderedCollection new: size.

		  init := 0.
		  cross keysAndValuesDo: [ :v :d |
			  init := init + d.
			  distances add: v -> init ].

		  j := random nextInteger: init.

		  j := distances
			       findBinaryIndex: [ :assoc |
			       j threeWayCompareTo: assoc value ]
			       ifNone: [ :l :h | h min: size max: 1 ].

		  (distances at: j) key ]
]
