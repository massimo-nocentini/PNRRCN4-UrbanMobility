Class {
	#name : 'PNRRCN4NotebookTest',
	#superclass : 'TestCase',
	#category : 'PNRRCN4-UrbanMobility-Tests',
	#package : 'PNRRCN4-UrbanMobility-Tests'
}

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
