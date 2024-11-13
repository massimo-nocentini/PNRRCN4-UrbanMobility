Class {
	#name : 'PNRRFruitMBitCoinEdge',
	#superclass : 'Object',
	#instVars : [
		'from',
		'to'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinEdge >> from [

	^ from
]

{ #category : 'accessing' }
PNRRFruitMBitCoinEdge >> from: anObject [

	from := anObject
]

{ #category : 'printing' }
PNRRFruitMBitCoinEdge >> printOn: aStream [

	self from printOn: aStream.

	aStream << ' → '.

	self to printOn: aStream
]

{ #category : 'accessing' }
PNRRFruitMBitCoinEdge >> to [

	^ to
]

{ #category : 'accessing' }
PNRRFruitMBitCoinEdge >> to: anObject [

	to := anObject
]
