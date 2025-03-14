Class {
	#name : 'PNRRFruitMBitCoinVertex',
	#superclass : 'Object',
	#instVars : [
		'id',
		'outgoingNeighborhood',
		'incomingNeighborhood',
		'bfs',
		'bfsBackward',
		'index'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'breadth first search' }
PNRRFruitMBitCoinVertex >> breadthFirstSearch [

	^ bfs ifNil: [
		  bfs := self
			         breadthFirstSearchDo: nil
			         neighborhoodBlock: #outgoingNeighborhood
			         edgeAccessor: #to ]
]

{ #category : 'breadth first search' }
PNRRFruitMBitCoinVertex >> breadthFirstSearchBackward [

	^ bfsBackward ifNil: [
		  bfsBackward := self
			                 breadthFirstSearchDo: nil
			                 neighborhoodBlock: #incomingNeighborhood
			                 edgeAccessor: #from ]
]

{ #category : 'breadth first search' }
PNRRFruitMBitCoinVertex >> breadthFirstSearchDo: doBlock neighborhoodBlock: nBlock edgeAccessor: eBlock [

	| seen queue layers |
	seen := Dictionary new.
	layers := OrderedCollection new.

	queue := (nBlock value: self) collect: [ :edge |
		         (eBlock value: edge) -> 1 ].

	[ queue isEmpty ] whileFalse: [
		| assoc dist vertex |
		assoc := queue removeAt: 1.

		vertex := assoc key.
		dist := assoc value.

		seen at: vertex ifAbsentPut: [
			(nBlock value: vertex) do: [ :edge |
				queue add: (eBlock value: edge) -> (dist + 1) ].

			(layers at: dist ifAbsentPut: [ OrderedCollection new ]) add:
				vertex.

			doBlock ifNotNil: [ doBlock value: vertex value: dist ].

			dist ] ].

	^ PNRRFruitMBitCoinBFS new
		  layers: layers;
		  distances: seen;
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
