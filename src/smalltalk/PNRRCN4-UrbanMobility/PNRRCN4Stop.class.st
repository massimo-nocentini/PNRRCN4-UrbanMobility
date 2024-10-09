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
PNRRCN4Stop >> earliestArrivalTimePathsFrom: u to: v at: t duration: d fromTime: fromTime toTime: toTime [

	| seconds |
	earliestArrivalTimePaths
		at: self
		ifAbsentPut: [ fromTime asSeconds -> OrderedCollection new ].

	seconds := t asSeconds + d asSeconds.
	(seconds <= toTime asSeconds and: [
		 | tu |
		 tu := earliestArrivalTimePaths
			       at: u
			       ifAbsentPut: [ Float infinity -> OrderedCollection new ].
		 tu key < t asSeconds ]) ifTrue: [
		| tv |
		tv := earliestArrivalTimePaths
			      at: v
			      ifAbsentPut: [ Float infinity -> OrderedCollection new ].
		seconds < tv key ifTrue: [
			tv key: seconds.
			tv value add: {
					u.
					v.
					t } ] ]
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
	temporalNeighborhood := Set new.
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

{ #category : 'accessing' }
PNRRCN4Stop >> sortTemporalNeighborhood [

	| sorted |
	sorted := SortedCollection sortUsing: [ :triple :anotherTriple |
		          triple second = anotherTriple second
			          ifTrue: [ triple third < anotherTriple third ]
			          ifFalse: [ triple second < anotherTriple second ] ].

	self temporalNeighborhood do: [ :each | sorted add: each ].

	temporalNeighborhood := sorted
]

{ #category : 'accessing' }
PNRRCN4Stop >> temporalNeighborhood [

	^ temporalNeighborhood
]

{ #category : 'accessing' }
PNRRCN4Stop >> times [

	^ times
]
