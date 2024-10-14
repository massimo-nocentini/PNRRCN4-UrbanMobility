Class {
	#name : 'PNRRCN4StopTime',
	#superclass : 'Object',
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

{ #category : 'instance creation' }
PNRRCN4StopTime class >> florence [

	^ self onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/stop_times.txt'
			  asFileReference
]

{ #category : 'parsing' }
PNRRCN4StopTime class >> onFileReference: fr [

	| converter random |
	random := RSRandom seed: Number firstCarmichaelNumber.

	converter := [ :s |
	             | triple main nano |
	             main := s splitOn: $..

	             nano := main size = 2
		                     ifTrue: [
		                     main second asInteger min: 999999999 max: 0 ]
		                     ifFalse: [ (random next * 1e9) floor ].

	             triple := main first splitOn: $:.

	             Time
		             hour: triple first asInteger % 24
		             minute: triple second asInteger
		             second: triple third asInteger
		             nanoSecond: nano ].

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

{ #category : 'displaying' }
PNRRCN4StopTime >> displayStringOn: aStream [

	aStream
		<< self stop name;
		space;
		<< ' ('.

	self stop code displayStringOn: aStream.

	aStream << ') departs at '.

	self departureTime displayStringOn: aStream.

	aStream << ' after '.

	self traveledDistance displayStringOn: aStream.

	aStream << 'km'
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
