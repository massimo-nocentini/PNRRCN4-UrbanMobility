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

	| stops times routes trips |
	stops := self loadStopsFromFileReference:
		         'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/transport'
			         asFileReference / graphName / 'nodes.csv'.

	times := self loadStopTimesFromFileReference:
		         'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/transport'
			         asFileReference / graphName / 'edges.csv'.

	routes := Dictionary new.
	trips := Dictionary new.

	times do: [ :each |
		routes at: each routeId ifAbsentPut: [
			PNRRCN4Route new
				id: each routeId;
				longName: each routeId;
				yourself ].

		trips at: each tripId ifAbsentPut: [
			PNRRCN4Trip new
				id: each tripId;
				routeId: each routeId;
				yourself ] ].

	times sort: [ :a :b |
		a departureTime = b departureTime
			ifTrue: [ a arrivalTime < b arrivalTime ]
			ifFalse: [ a departureTime = b departureTime ] ].

	^ PNRRCN4System
		  routes: routes values
		  stops: stops
		  times: times
		  trips: trips values
]

{ #category : 'instance creation' }
PNRRCN4TransportGraph class >> loadStopTimesFromFileReference: fr [

	^ (NeoCSVReader on: fr readStream)
		  separator: $;;
		  skipHeader;
		  recordClass: PNRRCN4FromToEdge;
		  addField: #fromId:;
		  addField: #toId:;
		  addIntegerField: #departureTime:;
		  addIntegerField: #arrivalTime:;
		  addIntegerField: #routeType:;
		  addField: #tripId:;
		  addIntegerField: #sequence:;
		  addField: #routeId:;
		  upToEnd
]

{ #category : 'instance creation' }
PNRRCN4TransportGraph class >> loadStopsFromFileReference: fr [

	| reader |
	reader := NeoCSVReader on: fr readStream.

	^ reader
		  separator: $;;
		  skipHeader;
		  recordClass: PNRRCN4Stop;
		  addField: #id:;
		  addFloatField: #latitude:;
		  addFloatField: #longitude:;
		  addField: #name:;
		  upToEnd
]

{ #category : 'instance creation' }
PNRRCN4TransportGraph class >> named: graphName [

	^ Graphs at: graphName ifAbsentPut: [ self load: graphName ]
]
