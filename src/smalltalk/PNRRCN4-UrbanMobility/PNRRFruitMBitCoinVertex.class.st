Class {
	#name : 'PNRRFruitMBitCoinVertex',
	#superclass : 'Object',
	#instVars : [
		'id',
		'outgoingNeighborhood',
		'incomingNeighborhood'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

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
