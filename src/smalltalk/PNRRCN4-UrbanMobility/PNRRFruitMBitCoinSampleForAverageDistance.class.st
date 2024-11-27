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

	^ count > 0
		  ifTrue: [ (distance / count) asFloat ]
		  ifFalse: [ Float infinity ]
]

{ #category : 'accessing' }
PNRRFruitMBitCoinSampleForAverageDistance >> sampleVertex: each bfs: bfs crossDistances: cross [

	^ cross ifEmpty: [ each ] ifNotEmpty: [
		  | init distances j size |
		  size := cross size.
		  distances := OrderedCollection new: size.

		  init := 0.
		  cross keysAndValuesDo: [ :v :ds |
			  init := init + ds size.
			  distances add: v -> init ].

		  j := random nextInteger: init.

		  j := distances
			       findBinaryIndex: [ :assoc |
			       j threeWayCompareTo: assoc value ]
			       ifNone: [ :l :h | h min: size max: 1 ].

		  (distances at: j) key ]
]
