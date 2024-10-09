Class {
	#name : 'PNRRCN4TemporalEdge',
	#superclass : 'Object',
	#instVars : [
		'from',
		'to',
		'duration',
		'departureTime'
	],
	#category : 'PNRRCN4-UrbanMobility',
	#package : 'PNRRCN4-UrbanMobility'
}

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> departureTime [

	^ departureTime
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> departureTime: anObject [

	departureTime := anObject
]

{ #category : 'displaying' }
PNRRCN4TemporalEdge >> displayStringOn: aStream [

	self from displayStringOn: aStream.

	aStream << ' -> '.

	self to displayStringOn: aStream.

	aStream << ' at '.

	self departureTime displayStringOn: aStream.

	aStream << ' in '.

	self duration displayStringOn: aStream
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> duration [

	^ duration
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> duration: anObject [

	duration := anObject
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> from [

	^ from
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> from: anObject [

	from := anObject
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> to [

	^ to
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> to: anObject [

	to := anObject
]
