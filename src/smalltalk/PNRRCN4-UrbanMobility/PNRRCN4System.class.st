Class {
	#name : 'PNRRCN4System',
	#superclass : 'Object',
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
	trips do: [ :each | tripsMap at: each id put: each ]
]
