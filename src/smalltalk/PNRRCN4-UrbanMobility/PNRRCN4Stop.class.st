Class {
	#name : 'PNRRCN4Stop',
	#superclass : 'PNRRCN4Object',
	#instVars : [
		'id',
		'name',
		'latitude',
		'longitude',
		'code',
		'times',
		'temporalOutgoingNeighborhood',
		'temporalIncomingNeighborhood'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

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

	^ code ifNil: [ self id ]
]

{ #category : 'accessing' }
PNRRCN4Stop >> code: anObject [

	code := anObject
]

{ #category : 'paths - earliest arrival time' }
PNRRCN4Stop >> earliestArrivalTimePathsFromTime: fromTime toTime: maxTime [

	| paths reified |
	paths := IdentityDictionary new
		         at: self put: fromTime -> nil;
		         yourself.

	self owner temporalEdges do: [ :edge |
		edge earliestArrivalTimeMaxTime: maxTime pathsSoFar: paths ].

	reified := IdentityDictionary new: paths size.

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
	temporalOutgoingNeighborhood := Set new.
	temporalIncomingNeighborhood := Set new
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

{ #category : 'printing' }
PNRRCN4Stop >> printOn: aStream [

	self name displayStringOn: aStream.

	aStream
		space;
		<< '('.

	self code displayStringOn: aStream.

	aStream << ')'
]

{ #category : 'neighborhoods' }
PNRRCN4Stop >> sortTemporalNeighborhoods [

	temporalOutgoingNeighborhood := temporalOutgoingNeighborhood timsort.

	temporalIncomingNeighborhood := temporalIncomingNeighborhood timsort
]

{ #category : 'neighborhoods' }
PNRRCN4Stop >> temporalIncomingNeighborhood [

	^ temporalIncomingNeighborhood
]

{ #category : 'neighborhoods' }
PNRRCN4Stop >> temporalOutgoingNeighborhood [

	^ temporalOutgoingNeighborhood
]

{ #category : 'accessing' }
PNRRCN4Stop >> times [

	^ times
]
