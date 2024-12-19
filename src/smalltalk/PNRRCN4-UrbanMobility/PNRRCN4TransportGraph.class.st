Class {
	#name : 'PNRRCN4TransportGraph',
	#superclass : 'Object',
	#classVars : [
		'Graphs'
	],
	#category : 'PNRRCN4-UrbanMobility-Case studies',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Case studies'
}

{ #category : 'accessing' }
PNRRCN4TransportGraph class >> graphNames [

	^ #( adelaide belfast berlin bordeaux brisbane canberra detroit
	     dublin florence grenoble helsinki kuopio lisbon luxembourg
	     melbourne nantes palermo paris prague rennes rome sydney toulouse
	     turku venice winnipeg )
]

{ #category : 'class initialization' }
PNRRCN4TransportGraph class >> initialize [

	Graphs := Dictionary new
]

{ #category : 'instance creation' }
PNRRCN4TransportGraph class >> load: graphName [

	| stops |
	stops := PNRRCN4Stop onFileReference:
		         ('pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/transport/'
		          , graphName) asFileReference
]

{ #category : 'instance creation' }
PNRRCN4TransportGraph class >> named: graphName [

	^ Graphs at: graphName ifAbsentPut: [ self load: graphName ]
]
