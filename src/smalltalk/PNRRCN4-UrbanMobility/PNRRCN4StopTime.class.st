Class {
	#name : 'PNRRCN4StopTime',
	#superclass : 'Object',
	#instVars : [
		'tripId',
		'arrivalTime',
		'departureTime',
		'stopId',
		'sequence',
		'traveledDistance'
	],
	#category : 'PNRRCN4-UrbanMobility',
	#package : 'PNRRCN4-UrbanMobility'
}

{ #category : 'parsing' }
PNRRCN4StopTime class >> onFileReference: fr [

	| reader |
	reader := NeoCSVReader on: fr readStream.

	^ reader
		  skipHeader;
		  recordClass: self;
		  addField: #tripId:;
		  addField: #arrivalTime: converter: [ :s |
			  | triple |
			  triple := s splitOn: $:.

			  Time
				  hour: triple first asInteger % 24
				  minute: triple second asInteger
				  second: triple third asInteger ];
		  addField: #departureTime:;
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

{ #category : 'accessing' }
PNRRCN4StopTime >> sequence [

	^ sequence
]

{ #category : 'accessing' }
PNRRCN4StopTime >> sequence: anObject [

	sequence := anObject
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
PNRRCN4StopTime >> tripId [

	^ tripId
]

{ #category : 'accessing' }
PNRRCN4StopTime >> tripId: anObject [

	tripId := anObject
]
