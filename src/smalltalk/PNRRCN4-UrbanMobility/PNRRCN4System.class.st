Class {
	#name : 'PNRRCN4System',
	#superclass : 'Object',
	#instVars : [
		'routes',
		'stops',
		'times',
		'trips',
		'temporalEdges'
	],
	#category : 'PNRRCN4-UrbanMobility-API',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'API'
}

{ #category : 'examples' }
PNRRCN4System class >> florence [

	^ self
		  routes: PNRRCN4Route florence
		  stops: PNRRCN4Stop florence
		  times: PNRRCN4StopTime florence
		  trips: PNRRCN4Trip florence
]

{ #category : 'instance creation' }
PNRRCN4System class >> routes: routes stops: stops times: times trips: trips [

	| routesMap stopsMap tripsMap temporalEdges |
	routesMap := Dictionary new.
	routes do: [ :each | routesMap at: each id put: each ].

	stopsMap := Dictionary new.
	stops do: [ :each | stopsMap at: each id put: each ].

	tripsMap := Dictionary new.
	trips do: [ :each |
		| route |
		"Tying the 1-to-many relation with the routes."
		route := routesMap at: each routeId.
		route trips add: each.
		each route: route.

		tripsMap at: each id put: each ].

	times
		select: [ :each |
		each arrivalTime isNotNil & each departureTime isNotNil ]
		thenDo: [ :each |
			| trip stop |
			trip := tripsMap at: each tripId.
			stop := stopsMap at: each stopId.

			each stop: stop.
			each trip: trip.

			trip times add: each.
			stop times add: each ].

	routes do: [ :route |
		route trips do: [ :trip |
			trip times
				sort: [ :t1 :t2 | t1 sequence < t2 sequence ];
				overlappingPairsDo: [ :from :to |
					| edge |
					edge := PNRRCN4TemporalEdge new
						        from: from stop;
						        to: to stop;
						        arrivalTime: to arrivalTime;
						        departureTime: from departureTime;
						        trip: trip;
						        yourself.

					from stop temporalOutgoingNeighborhood add: edge.
					to stop temporalIncomingNeighborhood add: edge ] ] ].

	temporalEdges := OrderedCollection new.
	stops do: [ :stop |
		stop sortTemporalNeighborhoods.
		temporalEdges addAll: stop temporalOutgoingNeighborhood ].

	^ self new
		  temporalEdges: temporalEdges timsort;
		  routes: routes;
		  stops: stopsMap;
		  times: times;
		  trips: tripsMap;
		  yourself
]

{ #category : 'export' }
PNRRCN4System >> asTemporalGraphInSexpString [

	^ String streamContents: [ :aStream |
		  self exportTemporalGraphInSexpFormatOnStream: aStream ]
]

{ #category : 'export' }
PNRRCN4System >> exportTemporalGraphInSexpFormatOnStream: aStream [

	aStream
		<< '(define florenceTemporalGraph ''(';
		lf.

	self stops valuesDo: [ :stop |
		aStream
			<< '(';
			<< stop code;
			space.

		stop temporalOutgoingNeighborhood do: [ :assoc |
			| destStop time |
			destStop := assoc key.
			time := assoc value.

			aStream
				<< '(';
				<< destStop code;
				space;
				<< time asSeconds asString;
				<< ')';
				space ].

		aStream
			<< ')';
			lf ].

	aStream << '))'
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
PNRRCN4System >> temporalAssociations [

	| assocs |
	assocs := OrderedCollection new.

	self routes do: [ :route |
		route trips do: [ :trip |
			trip times overlappingPairsDo: [ :r :s | assocs add: r -> s ] ] ].

	^ assocs sort: [ :assoc :anotherAssoc |
		  assoc key departureTime < anotherAssoc key departureTime ]
]

{ #category : 'accessing' }
PNRRCN4System >> temporalEdges [

	^ temporalEdges
]

{ #category : 'accessing' }
PNRRCN4System >> temporalEdges: anObject [

	temporalEdges := anObject
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
