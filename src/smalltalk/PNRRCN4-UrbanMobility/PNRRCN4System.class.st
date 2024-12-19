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

{ #category : 'instance creation' }
PNRRCN4System class >> manyToManyTimes: times tripsMap: tripsMap stopsMap: stopsMap onGraph: graph [

	| col |
	col := OrderedCollection new.

	times
		select: [ :each |
		each arrivalTime isNotNil & each departureTime isNotNil ]
		thenDo: [ :each |
			| trip from to stoptime |
			trip := tripsMap at: each tripId.

			from := stopsMap at: each fromId.
			stoptime := PNRRCN4StopTime new
				            owner: graph;
				            stopId: from id;
				            stop: from;
				            tripId: trip id;
				            trip: trip;
				            arrivalTime: each departureTimeAsDateAndTime;
				            departureTime: each departureTimeAsDateAndTime;
				            sequence: trip times size + 1;
				            yourself.

			trip times add: stoptime.
			from times add: stoptime.
			col add: stoptime.

			to := stopsMap at: each toId.
			stoptime := PNRRCN4StopTime new
				            owner: graph;
				            stopId: to id;
				            stop: to;
				            tripId: trip id;
				            trip: trip;
				            arrivalTime: each arrivalTimeAsDateAndTime;
				            departureTime: each arrivalTimeAsDateAndTime;
				            sequence: trip times size + 1;
				            yourself.

			trip times add: stoptime.
			to times add: stoptime.
			col add: stoptime ].

	^ col
]

{ #category : 'instance creation' }
PNRRCN4System class >> mapOfRoutes: routes onGraph: graph [

	| routesMap |
	routesMap := Dictionary new.
	routes do: [ :each |
		each owner: graph.
		routesMap at: each id put: each ].
	^ routesMap
]

{ #category : 'instance creation' }
PNRRCN4System class >> mapOfStops: stops onGraph: graph [

	| stopsMap |
	stopsMap := Dictionary new.
	stops do: [ :each |
		each owner: graph.
		stopsMap at: each id put: each ].
	^ stopsMap
]

{ #category : 'instance creation' }
PNRRCN4System class >> mapOfTrips: trips routesMap: routesMap onGraph: graph [

	| tripsMap |
	tripsMap := Dictionary new.
	trips do: [ :each |
		| route |
		"Tying the 1-to-many relation with the routes."
		route := routesMap at: each routeId.
		route trips add: each.

		each
			route: route;
			owner: graph.

		tripsMap at: each id put: each ].

	^ tripsMap
]

{ #category : 'instance creation' }
PNRRCN4System class >> newTemporalEdgeFrom: from to: to trip: trip onGraph: graph [

	^ PNRRCN4TemporalEdge new
		  from: from stop;
		  to: to stop;
		  arrivalTime: to arrivalTime;
		  departureTime: from departureTime;
		  trip: trip;
		  owner: graph;
		  yourself
]

{ #category : 'instance creation' }
PNRRCN4System class >> routes: routes stops: stops times: times trips: trips [

	| routesMap stopsMap tripsMap temporalEdges graph stoptimes |
	graph := self new.

	routesMap := self mapOfRoutes: routes onGraph: graph.

	stopsMap := self mapOfStops: stops onGraph: graph.

	tripsMap := self
		            mapOfTrips: trips
		            routesMap: routesMap
		            onGraph: graph.

	stoptimes := self
		             manyToManyTimes: times
		             tripsMap: tripsMap
		             stopsMap: stopsMap
		             onGraph: graph.

	routes do: [ :route |
		route trips do: [ :trip |
			trip times
				sort: [ :t1 :t2 | t1 sequence < t2 sequence ];
				overlappingPairsDo: [ :from :to |
					| edge |
					edge := self
						        newTemporalEdgeFrom: from
						        to: to
						        trip: trip
						        onGraph: graph.

					from stop temporalOutgoingNeighborhood add: edge.
					to stop temporalIncomingNeighborhood add: edge ] ] ].

	temporalEdges := OrderedCollection new.
	stops do: [ :stop |
		stop sortTemporalNeighborhoods.
		temporalEdges addAll: stop temporalOutgoingNeighborhood ].

	^ graph
		  temporalEdges: temporalEdges timsort;
		  routes: routes;
		  stops: stopsMap;
		  times: stoptimes;
		  trips: tripsMap;
		  yourself
]

{ #category : 'visiting' }
PNRRCN4System >> acceptSlotDescriptorsVisitor: aVisitor [

	^ aVisitor visitPNRRCN4Graph: self
]

{ #category : 'printing' }
PNRRCN4System >> printOn: aStream [

	aStream << 'a temporal graph (V, E) such that |V| = '.

	self stops size printOn: aStream.

	aStream << ' and |E| = '.

	self temporalEdges ifNotNil: [ :te | te size printOn: aStream ]
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
