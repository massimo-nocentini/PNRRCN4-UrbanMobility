Class {
	#name : 'PNRRFruitMBitCoinGraph',
	#superclass : 'Object',
	#instVars : [
		'vertices',
		'edges'
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
PNRRFruitMBitCoinGraph class >> instance1k [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/1k.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instance1m [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/1m.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instance5m [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/5m.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instanceHuge [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/pg-edges.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> newInstance [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/very-small.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> onFileReference: aFileReference [

	| graph |
	graph := self new.

	aFileReference exists ifTrue: [
		aFileReference readStreamDo: [ :fileStream |
			[ fileStream atEnd ] whileFalse: [
				| line i |
				line := fileStream nextLine.
				i := line indexOf: Character tab.

				graph
					addEdgeFrom: (line copyFrom: 1 to: i - 1)
					to: (line copyFrom: i + 1 to: line size) ] ] ].

	^ graph
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> resetInstance [

	Instance := nil
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> smallInstance [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/small.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph >> addEdgeFrom: fromId to: toId [

	| edge from to |
	from := vertices at: fromId ifAbsentPut: [
		        PNRRFruitMBitCoinVertex new
			        id: fromId;
			        index: vertices size + 1;
			        yourself ].

	to := vertices at: toId ifAbsentPut: [
		      PNRRFruitMBitCoinVertex new
			      id: toId;
			      index: vertices size + 1;
			      yourself ].

	edge := PNRRFruitMBitCoinEdge new
		        from: from;
		        to: to;
		        index: edges size + 1;
		        yourself.

	edges add: edge.

	from outgoingNeighborhood add: edge.
	to incomingNeighborhood add: edge.

	^ edge
]

{ #category : 'converting' }
PNRRFruitMBitCoinGraph >> asVerticesArray [

	| array |
	array := Array new: vertices size.

	vertices valuesDo: [ :v | array at: v index put: v ].

	^ array
]

{ #category : 'initialization' }
PNRRFruitMBitCoinGraph >> initialize [

	super initialize.

	vertices := Dictionary new.
	edges := OrderedCollection new
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph >> vertexAt: anObject [

	^ vertices at: anObject
]

{ #category : 'sampling' }
PNRRFruitMBitCoinGraph >> verticesSample: epsilon [

	| k pool random sample backward |
	k := (vertices size ln / epsilon squared) ceiling min: vertices size.

	random := RSRandom seed: Number firstCarmichaelNumber.

	pool := OrderedCollection newFrom: vertices values.

	sample := Array new: k streamContents: [ :sampleStream |
		          k timesRepeat: [
			          | i |
			          i := random nextInteger: pool size.
			          sampleStream nextPut: (pool removeAt: i) ] ].

	backward := sample collect: [ :each |
		            each incomingNeighborhood
			            ifEmpty: [ each ]
			            ifNotEmpty: [ :neighborhood |
				            | edge |
				            edge := neighborhood atRandom: random.
				            edge from ] ].

	^ PNRRFruitMBitCoinSample new
		  sample: backward;
		  yourself
]