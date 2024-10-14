Class {
	#name : 'PNRRCN4TemporalEdge',
	#superclass : 'Object',
	#instVars : [
		'from',
		'to',
		'duration',
		'departureTime',
		'route'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

{ #category : 'comparing' }
PNRRCN4TemporalEdge >> = anObject [
	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ from = anObject from and: [
		  to = anObject to and: [
			  route = anObject route and: [
				  departureTime = anObject departureTime ] ] ]
]

{ #category : 'converting' }
PNRRCN4TemporalEdge >> arrivalTimeAsFloat [

	^ self departureTime asFloatSeconds + self duration asFloatSeconds
]

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
	arrivalTime := t + self duration asNanoSeconds.

	arrivalTime <= maxTime ifFalse: [ ^ self ].

	tu := earliestArrivalTimePaths
		      at: self from
		      ifAbsentPut: [ Float infinity -> nil ].

	tu key <= t ifFalse: [ ^ self ].

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

{ #category : 'comparing' }
PNRRCN4TemporalEdge >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ from hash bitXor:
		  (to hash bitXor: (route hash bitXor: departureTime hash))
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> route [

	^ route
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> route: anObject [

	route := anObject
]

{ #category : 'sorting' }
PNRRCN4TemporalEdge >> timsortSortKey [

	^ self departureTime asFloatSeconds * 60.0
	  + self duration asFloatSeconds
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> to [

	^ to
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> to: anObject [

	to := anObject
]
