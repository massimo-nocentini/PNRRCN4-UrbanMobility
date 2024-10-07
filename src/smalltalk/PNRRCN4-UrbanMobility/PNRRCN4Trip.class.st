Class {
	#name : 'PNRRCN4Trip',
	#superclass : 'Object',
	#instVars : [
		'routeId',
		'id',
		'head',
		'direction',
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
		  addIntegerField: #routeId:;
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
