Class {
	#name : 'PNRRCN4TemporalEdge',
	#superclass : 'Object',
	#instVars : [
		'from',
		'to',
		'duration',
		'departureTime'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
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

{ #category : 'paths - earliest arrival time' }
PNRRCN4TemporalEdge >> earliestArrivalTimeMaxTime: maxTime pathsSoFar: earliestArrivalTimePaths [

	| t tu arrivalTime tv |
	t := self departureTime asNanoSeconds.

	t > maxTime ifTrue: [ ^ self ].

	arrivalTime := t + self duration asNanoSeconds.

	tu := earliestArrivalTimePaths
		      at: self from
		      ifAbsentPut: [ Float infinity -> nil ].

	(arrivalTime <= maxTime and: [ tu key <= t ]) ifFalse: [ ^ self ].

	tv := earliestArrivalTimePaths
		      at: self to
		      ifAbsentPut: [ Float infinity -> nil ].

	arrivalTime < tv key ifFalse: [ ^ self ].

	tv key: arrivalTime.
	tv value: self
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
