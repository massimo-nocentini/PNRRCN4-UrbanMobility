Class {
	#name : 'PNRRCN4NotebookTest',
	#superclass : 'TestCase',
	#category : 'PNRRCN4-UrbanMobility-Tests',
	#package : 'PNRRCN4-UrbanMobility-Tests'
}

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingRoutes [

	| routes |
	routes := PNRRCN4Route onFileReference:
		          'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/routes.txt'
			          asFileReference.

	self assert: routes size equals: 92
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingStopTimes [

	| stopTimes |
	stopTimes := PNRRCN4StopTime onFileReference:
		             'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/stop_times.txt'
			             asFileReference.

	self assert: stopTimes size equals: 1142816
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingStops [

	| stops |
	stops := PNRRCN4Stop onFileReference:
		         'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/stops.txt'
			         asFileReference.

	self assert: stops size equals: 2447
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingTrips [

	| trips |
	trips := PNRRCN4Trip onFileReference:
		         'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/trips.txt'
			         asFileReference.

	self assert: trips size equals: 44499
]
