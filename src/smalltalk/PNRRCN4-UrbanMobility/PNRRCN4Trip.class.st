"
An instance $t$ of mine represents a _bus_ in a transport network.
"
Class {
	#name : 'PNRRCN4Trip',
	#superclass : 'PNRRCN4Object',
	#instVars : [
		'routeId',
		'id',
		'head',
		'times',
		'route'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

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
		  addIgnoredField;
		  upToEnd
]

{ #category : 'accessing' }
PNRRCN4Trip >> head [

	^ head ifNil: [ self id ]
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

{ #category : 'printing' }
PNRRCN4Trip >> printOn: aStream [

	aStream
		<< self head;
		<< ' ('.

	self times size printOn: aStream.
	aStream << ' stops'.

	self times ifNotEmpty: [
		aStream << ' in '.
		self times last arrivalTime - self times first departureTime
			printOn: aStream.

		aStream << ' at '.

		self times first departureTime printOn: aStream ].

	aStream << ')'
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
