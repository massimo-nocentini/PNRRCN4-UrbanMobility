Class {
	#name : 'PNRRCN4Stop',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'latitude',
		'longitude',
		'code',
		'times',
		'temporalNeighborhood',
		'earliestArrivalTimePaths'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

{ #category : 'instance creation' }
PNRRCN4Stop class >> florence [

	^ self onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/stops.txt'
			  asFileReference
]

{ #category : 'parsing' }
PNRRCN4Stop class >> onFileReference: fr [

	| reader |
	reader := NeoCSVReader on: fr readStream.

	^ reader
		  skipHeader;
		  recordClass: self;
		  addField: #id:;
		  addField: #name:;
		  addFloatField: #latitude:;
		  addFloatField: #longitude:;
		  addField: #code:;
		  upToEnd
]

{ #category : 'accessing' }
PNRRCN4Stop >> code [

	^ code
]

{ #category : 'accessing' }
PNRRCN4Stop >> code: anObject [

	code := anObject
]

{ #category : 'displaying' }
PNRRCN4Stop >> displayStringOn: aStream [

	aStream
		<< self name;
		space;
		<< '('.

	self times size displayStringOn: aStream.

	aStream << ' times)'
]

{ #category : 'accessing' }
PNRRCN4Stop >> earliestArrivalTimePaths [

	^ earliestArrivalTimePaths
]

{ #category : 'accessing' }
PNRRCN4Stop >> earliestArrivalTimePathsTemporalEdge: edge toTime: toTime [

	| u v t d tu arrivalTime tv |
	u := edge from.
	v := edge to.
	t := edge departureTime asNanoSeconds.
	d := edge duration asNanoSeconds.

	arrivalTime := t + d.

	tu := earliestArrivalTimePaths
		      at: u
		      ifAbsentPut: [ Float infinity -> nil ].

	(arrivalTime <= toTime and: [ tu key <= t ]) ifFalse: [ ^ self ].

	tv := earliestArrivalTimePaths
		      at: v
		      ifAbsentPut: [ Float infinity -> nil ].

	arrivalTime < tv key ifFalse: [ ^ self ].

	tv key: arrivalTime.
	tv value: edge ~~> (earliestArrivalTimePaths at: u) value
]

{ #category : 'accessing' }
PNRRCN4Stop >> id [

	^ id
]

{ #category : 'accessing' }
PNRRCN4Stop >> id: anObject [

	id := anObject
]

{ #category : 'initialization' }
PNRRCN4Stop >> initialize [

	super initialize.

	times := OrderedCollection new.
	temporalNeighborhood := OrderedCollection new.
	earliestArrivalTimePaths := IdentityDictionary new
]

{ #category : 'accessing' }
PNRRCN4Stop >> latitude [

	^ latitude
]

{ #category : 'accessing' }
PNRRCN4Stop >> latitude: anObject [

	latitude := anObject
]

{ #category : 'accessing' }
PNRRCN4Stop >> longitude [

	^ longitude
]

{ #category : 'accessing' }
PNRRCN4Stop >> longitude: anObject [

	longitude := anObject
]

{ #category : 'accessing' }
PNRRCN4Stop >> name [

	^ name
]

{ #category : 'accessing' }
PNRRCN4Stop >> name: anObject [

	name := anObject
]

{ #category : 'sorting' }
PNRRCN4Stop >> sortTemporalNeighborhoodFromSystem: client [

	temporalNeighborhood := temporalNeighborhood timsort: [ :edge |
		                        client timsortKeyFunctionOnTemporalEdge:
			                        edge ]
]

{ #category : 'accessing' }
PNRRCN4Stop >> temporalNeighborhood [

	^ temporalNeighborhood
]

{ #category : 'accessing' }
PNRRCN4Stop >> times [

	^ times
]
