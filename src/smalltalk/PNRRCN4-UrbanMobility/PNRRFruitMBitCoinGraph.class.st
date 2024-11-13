Class {
	#name : 'PNRRFruitMBitCoinGraph',
	#superclass : 'Object',
	#instVars : [
		'vertices'
	],
	#classVars : [
		'Instance'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instance [

	^ Instance ifNil: [ Instance := self newInstance ]
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> newInstance [

	^ self onFileReference:
		  '/home/mn/Developer/bitcoin/small.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> onFileReference: aFileReference [

	| graph |
	graph := self new.

	aFileReference exists ifTrue: [
		aFileReference readStreamDo: [ :fileStream |
			[ fileStream atEnd ] whileFalse: [
				| line |
				line := fileStream nextLine splitOn: Character tab.
				graph addEdgeFrom: line first to: line second ] ] ].

	^ graph
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph >> addEdgeFrom: fromId to: toId [

	| edge from to |
	from := vertices at: fromId ifAbsentPut: [
		        PNRRFruitMBitCoinVertex new
			        id: fromId;
			        yourself ].

	to := vertices at: toId ifAbsentPut: [
		      PNRRFruitMBitCoinVertex new
			      id: toId;
			      yourself ].

	edge := PNRRFruitMBitCoinEdge new
		        from: from;
		        to: to;
		        yourself.

	from outgoingNeighborhood add: edge.
	to incomingNeighborhood add: edge.

	^ edge
]

{ #category : 'initialization' }
PNRRFruitMBitCoinGraph >> initialize [

	super initialize.

	vertices := Dictionary new
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph >> vertexAt: anObject [

	^ vertices at: anObject
]
