Class {
	#name : 'PNRRCN4TemporalEdge',
	#superclass : 'PNRRCN4Object',
	#instVars : [
		'from',
		'to',
		'departureTime',
		'trip',
		'arrivalTime'
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
			  trip = anObject trip and: [
				  departureTime = anObject departureTime and: [
					  arrivalTime = anObject arrivalTime ] ] ] ]
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> arrivalTime [

	^ arrivalTime
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> arrivalTime: anObject [

	arrivalTime := anObject
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> departureTime [

	^ departureTime
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> departureTime: anObject [

	departureTime := anObject
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> duration [

	^ (self arrivalTime - self departureTime) asDuration
]

{ #category : 'paths - earliest arrival time' }
PNRRCN4TemporalEdge >> earliestArrivalTimeMaxTime: maxTime pathsSoFar: earliestArrivalTimePaths [

	| t tu tv at |
	at := self arrivalTime.

	at <= maxTime ifFalse: [ ^ self ].

	t := self departureTime.

	tu := earliestArrivalTimePaths
		      at: self from
		      ifAbsentPut: [ Float infinity -> nil ].

	tu key <= t ifFalse: [ ^ self ].

	tv := earliestArrivalTimePaths
		      at: self to
		      ifAbsentPut: [ Float infinity -> nil ].

	at < tv key ifFalse: [ ^ self ].

	tv key: at.
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

	^ from hash bitXor: (to hash bitXor:
			   (trip hash bitXor: (departureTime hash bitXor: arrivalTime hash)))
]

{ #category : 'displaying' }
PNRRCN4TemporalEdge >> printOn: aStream [

	self from printOn: aStream.

	aStream << ' -> '.

	self to printOn: aStream.

	aStream << ' at '.

	self departureTime printOn: aStream.

	aStream << ' in '.

	self duration printOn: aStream.

	aStream << ' by '.

	self trip printOn: aStream
]

{ #category : 'sorting' }
PNRRCN4TemporalEdge >> timsortSortKey [

	^ (self departureTime + self duration) asUnixTime
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> to [

	^ to
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> to: anObject [

	to := anObject
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> trip [

	^ trip
]

{ #category : 'accessing' }
PNRRCN4TemporalEdge >> trip: anObject [

	trip := anObject
]
