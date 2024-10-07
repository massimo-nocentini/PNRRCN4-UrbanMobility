Class {
	#name : 'PNRRCN4System',
	#superclass : 'Object',
	#instVars : [
		'routes',
		'stops',
		'times',
		'trips'
	],
	#category : 'PNRRCN4-UrbanMobility-API',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'API'
}

{ #category : 'instance creation' }
PNRRCN4System class >> routes: routes stops: stops times: times trips: trips [

	| routesMap stopsMap timesMap tripsMap |
	routesMap := Dictionary new.
	routes do: [ :each | routesMap at: each id put: each ].

	stopsMap := Dictionary new.
	stops do: [ :each | stopsMap at: each id put: each ].

	timesMap := Dictionary new.
	times do: [ :each | timesMap at: each id put: each ].

	tripsMap := Dictionary new.
	trips do: [ :each | tripsMap at: each id put: each ].

	timesMap valuesDo: [ :each |
		each stop: (stopsMap at: each stopId).
		each trip: (tripsMap at: each tripId) ].

	tripsMap valuesDo: [ :each |
		each route: (routesMap at: each routeId) ].

	^ self new
		  routes: routesMap;
		  stops: stopsMap;
		  times: timesMap;
		  trips: tripsMap;
		  yourself
]

{ #category : 'accessing' }
PNRRCN4System >> routes [

	^ routes
]

{ #category : 'accessing' }
PNRRCN4System >> routes: anObject [

	routes := anObject
]

{ #category : 'accessing' }
PNRRCN4System >> stops [

	^ stops
]

{ #category : 'accessing' }
PNRRCN4System >> stops: anObject [

	stops := anObject
]

{ #category : 'accessing' }
PNRRCN4System >> times [

	^ times
]

{ #category : 'accessing' }
PNRRCN4System >> times: anObject [

	times := anObject
]

{ #category : 'accessing' }
PNRRCN4System >> trips [

	^ trips
]

{ #category : 'accessing' }
PNRRCN4System >> trips: anObject [

	trips := anObject
]
