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
		          '/home/mn/Downloads/48-urbanoareametropolitanafiorentina/routes.txt'
			          asFileReference.

	self assert: routes size equals: 92
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingStopTimes [

	| stopTimes |
	stopTimes := PNRRCN4StopTime onFileReference:
		             '/home/mn/Downloads/48-urbanoareametropolitanafiorentina/stop_times.txt'
			             asFileReference.

	self assert: stopTimes size equals: 1142816
]

{ #category : 'tests' }
PNRRCN4NotebookTest >> testLoadingStops [

	| stops |
	stops := PNRRCN4Stop onFileReference:
		         '/home/mn/Downloads/48-urbanoareametropolitanafiorentina/stops.txt'
			         asFileReference.

	self assert: stops size equals: 2447
]
