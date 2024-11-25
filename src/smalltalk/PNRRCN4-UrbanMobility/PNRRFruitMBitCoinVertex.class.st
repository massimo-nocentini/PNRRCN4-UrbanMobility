Class {
	#name : 'PNRRFruitMBitCoinVertex',
	#superclass : 'Object',
	#instVars : [
		'id',
		'outgoingNeighborhood',
		'incomingNeighborhood',
		'bfs',
		'index'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'visiting' }
PNRRFruitMBitCoinVertex >> breadthFirstSearch [

	^ self
		  breadthFirstSearchNeighborhoodBlock: #outgoingNeighborhood
		  edgeAccessor: #to
]

{ #category : 'visiting' }
PNRRFruitMBitCoinVertex >> breadthFirstSearchBackward [

	^ self
		  breadthFirstSearchNeighborhoodBlock: #incomingNeighborhood
		  edgeAccessor: #from
]

{ #category : 'visiting' }
PNRRFruitMBitCoinVertex >> breadthFirstSearchNeighborhoodBlock: nBlock edgeAccessor: eBlock [

	| seen queue vertexAtMaxDistance |
	seen := Dictionary new.
	vertexAtMaxDistance := nil -> 0.
	queue := (nBlock value: self) collect: [ :edge |
		         (eBlock value: edge) -> 1 ].

	[ queue isEmpty ] whileFalse: [
		| assoc dist vertex |
		assoc := queue removeAt: 1.

		vertex := assoc key.
		dist := assoc value.

		seen at: vertex ifAbsentPut: [
			| neighborhood |
			neighborhood := (nBlock value: vertex) collect: [ :edge |
				                (eBlock value: edge) -> (dist + 1) ].

			queue addAll: neighborhood.

			dist > vertexAtMaxDistance value ifTrue: [
				vertexAtMaxDistance := vertex -> dist ].

			dist ] ].

	^ PNRRFruitMBitCoinBFS new
		  distances: seen;
		  maxVertex: vertexAtMaxDistance key;
		  yourself
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

{ #category : 'accessing' }
PNRRFruitMBitCoinVertex >> index [

	^ index
]

{ #category : 'accessing' }
PNRRFruitMBitCoinVertex >> index: anObject [

	index := anObject
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
