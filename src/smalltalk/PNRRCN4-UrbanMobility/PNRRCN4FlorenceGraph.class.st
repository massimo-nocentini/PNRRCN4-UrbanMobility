Class {
	#name : 'PNRRCN4FlorenceGraph',
	#superclass : 'Object',
	#classVars : [
		'Instance'
	],
	#category : 'PNRRCN4-UrbanMobility-Case studies',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Case studies'
}

{ #category : 'accessing' }
PNRRCN4FlorenceGraph class >> instance [

	Instance ifNil: [
		[ Instance := self instantiateInstance ] timeToRun traceCr ].

	^ Instance
]

{ #category : 'instance creation' }
PNRRCN4FlorenceGraph class >> instantiateInstance [

	^ PNRRCN4System
		  routes: self routes
		  stops: self stops
		  times: self times
		  trips: self trips
]

{ #category : 'class initialization' }
PNRRCN4FlorenceGraph class >> routes [

	^ PNRRCN4Route onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/routes.txt'
			  asFileReference
]

{ #category : 'class initialization' }
PNRRCN4FlorenceGraph class >> stops [

	^ PNRRCN4Stop onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/stops.txt'
			  asFileReference
]

{ #category : 'class initialization' }
PNRRCN4FlorenceGraph class >> times [

	^ PNRRCN4StopTime onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/stop_times.txt'
			  asFileReference
]

{ #category : 'instance creation' }
PNRRCN4FlorenceGraph class >> tripRequests1 [

	^ PNRRCN4TripRequest onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/requests/requests_K10649_N30161.csv'
			  asFileReference
]

{ #category : 'instance creation' }
PNRRCN4FlorenceGraph class >> tripRequests2 [

	^ PNRRCN4TripRequest onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/requests/requests_K30161_N30161.csv'
			  asFileReference
]

{ #category : 'class initialization' }
PNRRCN4FlorenceGraph class >> trips [

	^ PNRRCN4Trip onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/florence/trips.txt'
			  asFileReference
]
