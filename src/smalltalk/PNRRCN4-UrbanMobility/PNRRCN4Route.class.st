Class {
	#name : 'PNRRCN4Route',
	#superclass : 'Object',
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

{ #category : 'instance creation' }
PNRRCN4Route class >> florence [

	^ self onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/routes.txt'
			  asFileReference
]

{ #category : 'parsing' }
PNRRCN4Route class >> onFileReference: fr [

	| reader |
	reader := NeoCSVReader on: fr readStream.

	^ reader
		  skipHeader;
		  recordClass: self;
		  addIntegerField: #id:;
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

	self trips: OrderedCollection new
]

{ #category : 'accessing' }
PNRRCN4Route >> longName [

	^ longName
]

{ #category : 'accessing' }
PNRRCN4Route >> longName: anObject [

	longName := anObject
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

{ #category : 'accessing' }
PNRRCN4Route >> trips: anObject [

	trips := anObject
]
