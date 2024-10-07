Class {
	#name : 'PNRRCN4NotebookTest',
	#superclass : 'TestCase',
	#category : 'PNRRCN4-UrbanMobility-Tests',
	#package : 'PNRRCN4-UrbanMobility-Tests'
}

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingRoutes [

	| routes |
	routes := PNRRCN4Route florence.

	self assert: routes size equals: 92
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingStopTimes [

	| stopTimes |
	self timeLimit: 1 minute.
	stopTimes := PNRRCN4StopTime florence.

	self assert: stopTimes size equals: 1142816
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingStops [

	| stops |
	stops := PNRRCN4Stop florence.

	self assert: stops size equals: 2447
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingTrips [

	| trips |
	trips := PNRRCN4Trip florence.

	self assert: trips size equals: 44499
]
