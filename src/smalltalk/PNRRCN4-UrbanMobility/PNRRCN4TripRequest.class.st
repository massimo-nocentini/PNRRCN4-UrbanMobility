Class {
	#name : 'PNRRCN4TripRequest',
	#superclass : 'PNRRCN4Object',
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

{ #category : 'displaying' }
PNRRCN4TripRequest >> displayStringOn: aStream [

	self fromStop displayStringOn: aStream.

	aStream << ' -> '.

	self toStop displayStringOn: aStream.

	aStream << ', '.

	self multiplicity displayStringOn: aStream.

	aStream << ' people at '.

	self time displayStringOn: aStream
]

{ #category : 'paths - earliest arrival time' }
PNRRCN4TripRequest >> earliestArrivalTimePath [

	| paths |
	paths := self fromStop
		         earliestArrivalTimePathsFromTime: self time
		         toTime: self owner temporalEdges last departureTime.

	^ paths at: self toStop ifAbsent: [ Array new ]
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

{ #category : 'sorting' }
PNRRCN4TripRequest >> timsortSortKey [

	^ self unixTime
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

	unixTime := anObject.
	time := DateAndTime fromUnixTime: unixTime
]
