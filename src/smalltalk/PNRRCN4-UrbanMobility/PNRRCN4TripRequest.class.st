Class {
	#name : 'PNRRCN4TripRequest',
	#superclass : 'Object',
	#instVars : [
		'fromStop',
		'toStop',
		'fromStopId',
		'toStopId',
		'time',
		'unixTime',
		'multiplicity'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

{ #category : 'instance creation' }
PNRRCN4TripRequest class >> florence1 [

	^ self onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/requests/requests_K10649_N30161.csv'
			  asFileReference
]

{ #category : 'instance creation' }
PNRRCN4TripRequest class >> florence2 [

	^ self onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/requests/requests_K30161_N30161.csv'
			  asFileReference
]

{ #category : 'instance creation' }
PNRRCN4TripRequest class >> onFileReference: fr [

	^ (NeoCSVReader on: fr readStream)
		  separator: $;;
		  skipHeader;
		  recordClass: self;
		  addField: #fromStopId:;
		  addField: #toStopId:;
		  addIntegerField: #unixTime:;
		  addIntegerField: #multiplicity:;
		  upToEnd
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> fromStop [

	^ fromStop
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> fromStop: anObject [

	fromStop := anObject
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> fromStopId [

	^ fromStopId
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> fromStopId: anObject [

	fromStopId := anObject
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> multiplicity [

	^ multiplicity
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> multiplicity: anObject [

	multiplicity := anObject
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> time [

	^ time
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> time: anObject [

	time := anObject
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> toStop [

	^ toStop
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> toStop: anObject [

	toStop := anObject
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> toStopId [

	^ toStopId
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> toStopId: anObject [

	toStopId := anObject
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> unixTime [

	^ unixTime
]

{ #category : 'accessing' }
PNRRCN4TripRequest >> unixTime: anObject [

	unixTime := anObject
]
