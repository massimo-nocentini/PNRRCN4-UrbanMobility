Class {
	#name : 'PNRRCN4StopTime',
	#superclass : 'PNRRCN4Object',
	#instVars : [
		'tripId',
		'arrivalTime',
		'departureTime',
		'stopId',
		'sequence',
		'traveledDistance',
		'stop',
		'trip'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

{ #category : 'parsing' }
PNRRCN4StopTime class >> onFileReference: fr [

	| converter |
	converter := [ :s |
	             | triple main nano hour |
	             main := s splitOn: $..

	             nano := main size = 2
		                     ifTrue: [
		                     main second asInteger min: 999999999 max: 0 ]
		                     ifFalse: [ 0 ].

	             triple := main first splitOn: $:.

	             hour := triple first asInteger.

	             hour < 23
		             ifTrue: [
			             Time
				             hour: hour
				             minute: triple second asInteger
				             second: triple third asInteger
				             nanoSecond: nano ]
		             ifFalse: [ nil ] ].

	^ (NeoCSVReader on: fr readStream)
		  skipHeader;
		  recordClass: self;
		  addField: #tripId:;
		  addField: #arrivalTime: converter: converter;
		  addField: #departureTime: converter: converter;
		  addField: #stopId:;
		  addIntegerField: #sequence:;
		  addField: #traveledDistance:;
		  upToEnd
]

{ #category : 'accessing' }
PNRRCN4StopTime >> arrivalTime [

	^ arrivalTime
]

{ #category : 'accessing' }
PNRRCN4StopTime >> arrivalTime: anObject [

	arrivalTime := anObject
]

{ #category : 'accessing' }
PNRRCN4StopTime >> departureTime [

	^ departureTime
]

{ #category : 'accessing' }
PNRRCN4StopTime >> departureTime: anObject [

	departureTime := anObject
]

{ #category : 'printing' }
PNRRCN4StopTime >> printOn: aStream [

	aStream
		<< self stop name;
		space;
		<< ' ('.

	self stop code displayStringOn: aStream.

	aStream << ') departs at '.

	self departureTime displayStringOn: aStream.

	self traveledDistance ifNotNil: [ :td |
		aStream << ' after '.

		td displayStringOn: aStream.

		aStream << 'km' ]
]

{ #category : 'accessing' }
PNRRCN4StopTime >> sequence [

	^ sequence
]

{ #category : 'accessing' }
PNRRCN4StopTime >> sequence: anObject [

	sequence := anObject
]

{ #category : 'accessing' }
PNRRCN4StopTime >> stop [

	^ stop
]

{ #category : 'accessing' }
PNRRCN4StopTime >> stop: anObject [

	stop := anObject
]

{ #category : 'accessing' }
PNRRCN4StopTime >> stopId [

	^ stopId
]

{ #category : 'accessing' }
PNRRCN4StopTime >> stopId: anObject [

	stopId := anObject
]

{ #category : 'accessing' }
PNRRCN4StopTime >> traveledDistance [

	^ traveledDistance
]

{ #category : 'accessing' }
PNRRCN4StopTime >> traveledDistance: anObject [

	traveledDistance := anObject
]

{ #category : 'accessing' }
PNRRCN4StopTime >> trip [

	^ trip
]

{ #category : 'accessing' }
PNRRCN4StopTime >> trip: anObject [

	trip := anObject
]

{ #category : 'accessing' }
PNRRCN4StopTime >> tripId [

	^ tripId
]

{ #category : 'accessing' }
PNRRCN4StopTime >> tripId: anObject [

	tripId := anObject
]
