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
		'temporalNeighborhood'
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

{ #category : 'paths - earliest arrival time' }
PNRRCN4Stop >> earliestArrivalTimePathsOnEdgeStream: edgesStream fromTime: fromTime toTime: maxTime [

	| paths reified |
	paths := self
		         earliestArrivalTimePathsOnEdgeStream: edgesStream
		         fromTime: fromTime
		         toTime: maxTime
		         paths: IdentityDictionary new.

	reified := IdentityDictionary new.

	paths keysAndValuesDo: [ :key :assoc |
		| edge path |
		edge := assoc value.
		path := OrderedCollection new.

		[ edge ] whileNotNil: [
			path addFirst: edge.
			edge := (paths at: edge from) value ].

		reified at: key put: path ].

	^ reified
]

{ #category : 'paths - earliest arrival time' }
PNRRCN4Stop >> earliestArrivalTimePathsOnEdgeStream: edgesStream fromTime: fromTime toTime: maxTime paths: paths [

	| toTimeNanoSeconds |
	toTimeNanoSeconds := maxTime asNanoSeconds.

	paths at: self put: fromTime asNanoSeconds -> nil.

	edgesStream do: [ :edge | "edge departureTime >= maxTime ifTrue: [ ^ paths ]."
		edge earliestArrivalTimeMaxTime: toTimeNanoSeconds pathsSoFar: paths ].

	^ paths
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
	temporalNeighborhood := OrderedCollection new
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
