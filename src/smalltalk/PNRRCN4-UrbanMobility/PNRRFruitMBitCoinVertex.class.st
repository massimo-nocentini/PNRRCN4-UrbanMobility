Class {
	#name : 'PNRRFruitMBitCoinVertex',
	#superclass : 'Object',
	#instVars : [
		'id',
		'outgoingNeighborhood',
		'incomingNeighborhood',
		'bfs'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'visiting' }
PNRRFruitMBitCoinVertex >> breadthFirstSearch [

	| seen queue |
	seen := Dictionary new.

	queue := self outgoingNeighborhood collect: [ :edge | edge to -> 1 ].

	[ queue isEmpty ] whileFalse: [
		| assoc dist vertex |
		assoc := queue removeAt: 1.

		vertex := assoc key.
		dist := assoc value.

		seen at: vertex ifAbsentPut: [
			| neighborhood |
			neighborhood := vertex outgoingNeighborhood collect: [ :edge |
				                edge to -> (dist + 1) ].

			queue addAll: neighborhood.

			dist ] ].

	^ seen
]

{ #category : 'visiting' }
PNRRFruitMBitCoinVertex >> breadthFirstSearchRec [

	^ bfs ifNil: [
		  | seen |
		  seen := Dictionary new
			          at: self put: 0;
			          yourself.

		  self outgoingNeighborhood do: [ :edge |
			  edge to breadthFirstSearchRec keysAndValuesDo: [ :v :d |
				  | w dd |
				  dd := d + 1.
				  w := seen at: v ifAbsent: dd.
				  seen at: v put: (w min: dd) ] ].

		  bfs := seen ]
]

{ #category : 'accessing' }
PNRRFruitMBitCoinVertex >> id [

	^ id
]

{ #category : 'accessing' }
PNRRFruitMBitCoinVertex >> id: anObject [

	id := anObject
]

{ #category : 'accessing' }
PNRRFruitMBitCoinVertex >> incomingNeighborhood [

	^ incomingNeighborhood
]

{ #category : 'initialization' }
PNRRFruitMBitCoinVertex >> initialize [

	super initialize.

	incomingNeighborhood := OrderedCollection new.
	outgoingNeighborhood := OrderedCollection new
]

{ #category : 'accessing' }
PNRRFruitMBitCoinVertex >> outgoingNeighborhood [

	^ outgoingNeighborhood
]

{ #category : 'printing' }
PNRRFruitMBitCoinVertex >> printOn: aStream [

	aStream
		<< 'Vertex ';
		<< self id;
		<< ' ('.

	self outgoingNeighborhood size printOn: aStream.

	aStream << ' outgoings, '.

	self incomingNeighborhood size printOn: aStream.

	aStream << ' incomings)'
]
