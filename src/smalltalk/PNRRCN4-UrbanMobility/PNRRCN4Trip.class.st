Class {
	#name : 'PNRRCN4Trip',
	#superclass : 'Object',
	#instVars : [
		'routeId',
		'tripId',
		'head',
		'direction'
	],
	#category : 'PNRRCN4-UrbanMobility',
	#package : 'PNRRCN4-UrbanMobility'
}

{ #category : 'parsing' }
PNRRCN4Trip class >> onFileReference: fr [

	| reader |
	reader := NeoCSVReader on: fr readStream.

	^ reader
		  skipHeader;
		  recordClass: self;
		  addIntegerField: #routeId:;
		  addIgnoredField;
		  addField: #tripId:;
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
PNRRCN4Trip >> routeId [

	^ routeId
]

{ #category : 'accessing' }
PNRRCN4Trip >> routeId: anObject [

	routeId := anObject
]

{ #category : 'accessing' }
PNRRCN4Trip >> tripId [

	^ tripId
]

{ #category : 'accessing' }
PNRRCN4Trip >> tripId: anObject [

	tripId := anObject
]
