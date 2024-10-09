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
PNRRCN4System class >> florence [

	^ self
		  routes: PNRRCN4Route florence
		  stops: PNRRCN4Stop florence
		  times: PNRRCN4StopTime florence
		  trips: PNRRCN4Trip florence
]

{ #category : 'instance creation' }
PNRRCN4System class >> routes: routes stops: stops times: times trips: trips [

	| routesMap stopsMap tripsMap secondsPerDay random |
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
			trip times overlappingPairsDo: [ :r :s |
				r stop temporalNeighborhood add: {
						s stop.
						r departureTime.
						(Duration
							 seconds:
							 s arrivalTime asSeconds - r departureTime asSeconds
							 % secondsPerDay
							 nanoSeconds: (random next * 1000000000) ceiling) } ] ] ].

	stops do: [ :stop | stop sortTemporalNeighborhood ].

	^ self new
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

{ #category : 'accessing' }
PNRRCN4System >> earliestArrivalTimePaths [

	^ self earliestArrivalTimePaths: self edgesStream
]

{ #category : 'accessing' }
PNRRCN4System >> earliestArrivalTimePaths: edgesStream [

	| fromTime toTime |
	fromTime := Time seconds: 0.
	toTime := Time hour: 23 minute: 0 second: 0.

	edgesStream do: [ :tuple |
		tuple bind: [ :u :v :t :d |
			t asSeconds + d asSeconds > toTime asSeconds ifTrue: [ ^ self ].

			self stops valuesDo: [ :stop |
				stop
					earliestArrivalTimePathsFrom: u
					to: v
					at: t
					duration: d
					fromTime: fromTime ] ] ]
]

{ #category : 'accessing' }
PNRRCN4System >> edgesStream [

	| collection |
	collection := OrderedCollection new.

	self stops do: [ :stop |
		stop temporalNeighborhood do: [ :triple |
			collection add: {
					stop.
					triple first.
					triple second.
					triple third } ] ].

	^ collection sort: [ :quad :anotherQuad |
		  quad third = anotherQuad third
			  ifTrue: [ quad fourth < anotherQuad fourth ]
			  ifFalse: [ quad third < anotherQuad third ] ]
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

		stop temporalNeighborhood do: [ :assoc |
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

	| col keep |
	col := aCollection select: [ :request |
		       keep := true.

		       request
			       fromStop:
				       (self stops
					        at: request fromStopId
					        ifAbsent: [ keep := false ]);
			       toStop:
				       (self stops
					        at: request toStopId
					        ifAbsent: [ keep := false ]);
			       time: (DateAndTime fromUnixTime: request unixTime) asTime.

		       keep ].

	^ col sort: [ :req :anotherReq |
		  req time = anotherReq time
			  ifTrue: [ req multiplicity < anotherReq multiplicity ]
			  ifFalse: [ req time < anotherReq time ] ]
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
