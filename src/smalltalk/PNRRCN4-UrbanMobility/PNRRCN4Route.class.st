Class {
	#name : 'PNRRCN4Route',
	#superclass : 'Object',
	#instVars : [
		'id',
		'shortName',
		'longName'
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
