Class {
	#name : 'PNRRCN4Trip',
	#superclass : 'Object',
	#instVars : [
		'routeId',
		'id',
		'head',
		'direction',
		'times',
		'route'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

{ #category : 'instance creation' }
PNRRCN4Trip class >> florence [

	^ self onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/trips.txt'
			  asFileReference
]

{ #category : 'parsing' }
PNRRCN4Trip class >> onFileReference: fr [

	| reader |
	reader := NeoCSVReader on: fr readStream.

	^ reader
		  skipHeader;
		  recordClass: self;
		  addField: #routeId:;
		  addIgnoredField;
		  addField: #id:;
		  addField: #head:;
		  addIgnoredField;
		  addField: #direction:;
		  upToEnd
]

{ #category : 'accessing' }
PNRRCN4Trip >> direction [

	^ direction
]

{ #category : 'accessing' }
PNRRCN4Trip >> direction: anObject [

	direction := anObject
]

{ #category : 'displaying' }
PNRRCN4Trip >> displayStringOn: aStream [

	self head displayStringOn: aStream.

	aStream << ' '.

	self times size displayStringOn: aStream.
	aStream << ' stops in '.

	(Duration seconds: (self times last arrivalTime asFloatSeconds
		  - self times first departureTime asFloatSeconds) abs)
		displayStringOn: aStream.

	aStream << ' at '.

	self times first departureTime displayStringOn: aStream
]

{ #category : 'accessing' }
PNRRCN4Trip >> head [

	^ head
]

{ #category : 'accessing' }
PNRRCN4Trip >> head: anObject [

	head := anObject
]

{ #category : 'accessing' }
PNRRCN4Trip >> id [

	^ id
]

{ #category : 'accessing' }
PNRRCN4Trip >> id: anObject [

	id := anObject
]

{ #category : 'initialization' }
PNRRCN4Trip >> initialize [

	super initialize.

	times := OrderedCollection new
]

{ #category : 'accessing' }
PNRRCN4Trip >> route [

	^ route
]

{ #category : 'accessing' }
PNRRCN4Trip >> route: anObject [

	route := anObject
]

{ #category : 'accessing' }
PNRRCN4Trip >> routeId [

	^ routeId
]

{ #category : 'accessing' }
PNRRCN4Trip >> routeId: anObject [

	routeId := anObject
]

{ #category : 'accessing' }
PNRRCN4Trip >> times [

	^ times
]
