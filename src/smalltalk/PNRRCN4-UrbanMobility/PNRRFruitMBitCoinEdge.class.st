Class {
	#name : 'PNRRFruitMBitCoinEdge',
	#superclass : 'Object',
	#instVars : [
		'from',
		'to',
		'index'
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

{ #category : 'accessing' }
PNRRFruitMBitCoinEdge >> index [

	^ index
]

{ #category : 'accessing' }
PNRRFruitMBitCoinEdge >> index: anObject [

	index := anObject
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
