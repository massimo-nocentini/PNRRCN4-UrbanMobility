Class {
	#name : 'PNRRFruitMBitCoinBFS',
	#superclass : 'Object',
	#instVars : [
		'distances',
		'maxVertex'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'accessing' }
PNRRFruitMBitCoinBFS >> distances [

	^ distances
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBFS >> distances: anObject [

	distances := anObject
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBFS >> maxDistance [

	^ self distances at: self maxVertex ifAbsent: 0
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBFS >> maxVertex [

	^ maxVertex
]

{ #category : 'accessing' }
PNRRFruitMBitCoinBFS >> maxVertex: anObject [

	maxVertex := anObject
]
