Class {
	#name : 'PNRRCN4FromToEdge',
	#superclass : 'PNRRCN4Object',
	#instVars : [
		'fromId',
		'toId',
		'departureTime',
		'arrivalTime',
		'routeType',
		'tripId',
		'routeId',
		'sequence'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

{ #category : 'accessing' }
PNRRCN4FromToEdge >> arrivalTime [

	^ arrivalTime
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> arrivalTime: anObject [

	arrivalTime := anObject
]

{ #category : 'as yet unclassified' }
PNRRCN4FromToEdge >> arrivalTimeAsDateAndTime [

	^ DateAndTime fromUnixTime: self arrivalTime
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> departureTime [

	^ departureTime
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> departureTime: anObject [

	departureTime := anObject
]

{ #category : 'as yet unclassified' }
PNRRCN4FromToEdge >> departureTimeAsDateAndTime [

	^ DateAndTime fromUnixTime: self departureTime
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> fromId [

	^ fromId
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> fromId: anObject [

	fromId := anObject
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> routeId [

	^ routeId
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> routeId: anObject [

	routeId := anObject
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> routeType [

	^ routeType
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> routeType: anObject [

	routeType := anObject
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> sequence [

	^ sequence
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> sequence: anObject [

	sequence := anObject
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> toId [

	^ toId
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> toId: anObject [

	toId := anObject
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> tripId [

	^ tripId
]

{ #category : 'accessing' }
PNRRCN4FromToEdge >> tripId: anObject [

	tripId := anObject
]
