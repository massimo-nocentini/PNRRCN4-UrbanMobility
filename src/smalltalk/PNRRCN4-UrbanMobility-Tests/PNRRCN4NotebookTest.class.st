Class {
	#name : 'PNRRCN4NotebookTest',
	#superclass : 'TestCase',
	#traits : 'TIceImagesExporting',
	#classTraits : 'TIceImagesExporting classTrait',
	#category : 'PNRRCN4-UrbanMobility-Tests',
	#package : 'PNRRCN4-UrbanMobility-Tests'
}

{ #category : 'notebook' }
PNRRCN4NotebookTest >> implementationNotebook: thisNotebook [

	<notebook>
	| florence |
	thisNotebook title: 'Occupancy and crowding in Florence'.

	"# Intro"

	"The transport network of Florence can be introduced with the following message:"

	florence := PNRRCN4FlorenceGraph instance.

	"# Earliest Arrival Time Paths"

	'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/earliest arrival time.pdf'
		asFileReference asPdf pages.

	PNRRCN4Stop >> #earliestArrivalTimePathsFromTime:toTime:.

	PNRRCN4Stop >> #earliestArrivalTimePathsFromTime:toTime:paths:.

	PNRRCN4TemporalEdge >> #earliestArrivalTimeMaxTime:pathsSoFar:.

	"# Sampling"

	PNRRCN4RequestsSample >> #weightedSampleAbsoluteError:prob:.

	PNRRCN4RequestsSample >> #weightedSampleOfSize:.

	"# Parsing the data sources"

	PNRRCN4System class >> #routes:stops:times:trips:.

	"## Routes"
	PNRRCN4Route class >> #onFileReference:.

	"## Stops"
	PNRRCN4Stop class >> #onFileReference:.

	"## Times"
	PNRRCN4StopTime class >> #onFileReference:.

	"## Trips"
	PNRRCN4Trip class >> #onFileReference:.

	"## Requests"
	PNRRCN4TripRequest class >> #onFileReference:
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testExportImplementationNotebook [

	self timeLimit: 1 minute.

	self exportSlotsGraphOf:
		(self class >> #implementationNotebook:) asNotebook
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingRequests [

	self
		assert: PNRRCN4TripRequest florence1 size equals: 10649;
		assert: PNRRCN4TripRequest florence2 size equals: 30161
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingRoutes [

	self assert: PNRRCN4FlorenceGraph routes size equals: 92
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingStopTimes [

	self timeLimit: 1 minute.

	self assert: PNRRCN4FlorenceGraph times size equals: 1142816
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingStops [

	self assert: PNRRCN4FlorenceGraph stops size equals: 2447
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingTrips [

	self assert: PNRRCN4FlorenceGraph trips size equals: 44499
]
