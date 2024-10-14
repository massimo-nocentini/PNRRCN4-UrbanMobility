Class {
	#name : 'PNRRCN4System',
	#superclass : 'Object',
	#instVars : [
		'routes',
		'stops',
		'times',
		'trips',
		'temporalEdgesSize'
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

	| routesMap stopsMap tripsMap secondsPerDay random temporalEdgesSize |
	random := RSRandom seed: Float firstCarmichaelNumber.

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

	times do: [ :each |
		| trip stop |
		trip := tripsMap at: each tripId.
		stop := stopsMap at: each stopId.

		each stop: stop.
		each trip: trip.

		trip times add: each.
		stop times add: each ].

	secondsPerDay := 1 day asSeconds.
	routes do: [ :route |
		route trips do: [ :trip |
			trip times
				sort: [ :t1 :t2 | t1 sequence < t2 sequence ];
				overlappingPairsDo: [ :from :to |
					| edge d |
					d := Duration
						     seconds:
							     to arrivalTime asSeconds - from departureTime asSeconds
							     % secondsPerDay
						     nanoSeconds: (random next * 1e9) floor.

					edge := PNRRCN4TemporalEdge new
						        from: from stop;
						        to: to stop;
						        departureTime: from departureTime;
						        duration: d;
						        route: route;
						        yourself.

					from stop temporalOutgoingNeighborhood add: edge.
					to stop temporalIncomingNeighborhood add: edge ] ] ].


	temporalEdgesSize := 0.
	stops do: [ :stop |
		temporalEdgesSize := temporalEdgesSize
		                     + stop temporalOutgoingNeighborhood size.
		stop sortTemporalNeighborhoods ].

	^ self new
		  temporalEdgesSize: temporalEdgesSize;
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

{ #category : 'parsing' }
PNRRCN4System >> requests: aCollection [

	| col keep count |
	count := 0.

	col := aCollection select: [ :request |
		       keep := true.

		       request
			       fromStop: (self stops at: request fromStopId ifAbsent: [
						        keep := false.
						        nil ]);
			       toStop: (self stops at: request toStopId ifAbsent: [
						        keep := false.
						        nil ]);
			       time: (DateAndTime fromUnixTime: request unixTime) asTime.

		       keep ifTrue: [ count := count + request multiplicity ].

		       keep ].

	^ PNRRCN4RequestsSample new
		  requests: col;
		  totalCount: count;
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
PNRRCN4System >> temporalEdgesSize [

	^ temporalEdgesSize
]

{ #category : 'accessing' }
PNRRCN4System >> temporalEdgesSize: anObject [

	temporalEdgesSize := anObject
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
