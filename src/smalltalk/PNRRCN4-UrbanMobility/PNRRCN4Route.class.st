Class {
	#name : 'PNRRCN4Route',
	#superclass : 'PNRRCN4Object',
	#instVars : [
		'id',
		'shortName',
		'longName',
		'trips'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

{ #category : 'parsing' }
PNRRCN4Route class >> onFileReference: fr [

	| reader |
	reader := NeoCSVReader on: fr readStream.

	^ reader
		  skipHeader;
		  recordClass: self;
		  addField: #id:;
		  addIgnoredField;
		  addField: #shortName:;
		  addField: #longName:;
		  upToEnd
]

{ #category : 'accessing' }
PNRRCN4Route >> id [

	^ id
]

{ #category : 'accessing' }
PNRRCN4Route >> id: anObject [

	id := anObject
]

{ #category : 'initialization' }
PNRRCN4Route >> initialize [

	super initialize.

	trips := OrderedCollection new
]

{ #category : 'accessing' }
PNRRCN4Route >> longName [

	^ longName ifNil: [ self id ]
]

{ #category : 'accessing' }
PNRRCN4Route >> longName: anObject [

	longName := anObject
]

{ #category : 'printing' }
PNRRCN4Route >> printOn: aStream [

	aStream
		<< self longName;
		space;
		<< '('.

	self trips size displayStringOn: aStream.

	aStream << ' trips)'
]

{ #category : 'accessing' }
PNRRCN4Route >> shortName [

	^ shortName
]

{ #category : 'accessing' }
PNRRCN4Route >> shortName: anObject [

	shortName := anObject
]

{ #category : 'accessing' }
PNRRCN4Route >> trips [

	^ trips
]
