Class {
	#name : 'PNRRCN4Stop',
	#superclass : 'Object',
	#instVars : [
		'id',
		'name',
		'latitude',
		'longitude',
		'code'
	],
	#category : 'PNRRCN4-UrbanMobility',
	#package : 'PNRRCN4-UrbanMobility'
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

	^ code
]

{ #category : 'accessing' }
PNRRCN4Stop >> code: anObject [

	code := anObject
]

{ #category : 'accessing' }
PNRRCN4Stop >> id [

	^ id
]

{ #category : 'accessing' }
PNRRCN4Stop >> id: anObject [

	id := anObject
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