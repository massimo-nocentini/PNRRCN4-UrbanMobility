Class {
	#name : 'PNRRCN4RequestsSample',
	#superclass : 'Object',
	#instVars : [
		'requests',
		'totalCount'
	],
	#category : 'PNRRCN4-UrbanMobility-API',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'API'
}

{ #category : 'sorting' }
PNRRCN4RequestsSample class >> defaultIsRequest: req lessThanRequest: anotherReq [

	^ req time = anotherReq time
		  ifTrue: [ req multiplicity < anotherReq multiplicity ]
		  ifFalse: [ req time < anotherReq time ]
]

{ #category : 'instance creation' }
PNRRCN4RequestsSample class >> requests: aCollection onSystem: aSystem [

	| col keep count stops |
	stops := aSystem stops.
	count := 0.

	col := aCollection select: [ :request |
		       keep := true.

		       request
			       fromStop: (stops at: request fromStopId ifAbsent: [
						        keep := false.
						        nil ]);
			       toStop: (stops at: request toStopId ifAbsent: [
						        keep := false.
						        nil ]);
			       time: (DateAndTime fromUnixTime: request unixTime) asTime.

		       keep ifTrue: [ count := count + request multiplicity ].

		       keep ].

	^ self new
		  requests: col;
		  totalCount: count;
		  yourself
]

{ #category : 'displaying' }
PNRRCN4RequestsSample >> displayStringOn: aStream [

	aStream
		<< 'Sample of ';
		<< self requests size asString;
		<< ' requests by ';
		<< self totalCount asString;
		<< ' people'
]

{ #category : 'estimation' }
PNRRCN4RequestsSample >> occupancyAndCrowdingOnEdgeStream: edges [

	| aw at k oMatrix cVector |
	k := self requests size.
	aw := at := 0.0.
	oMatrix := Dictionary new.
	cVector := Dictionary new.

	self requests do: [ :q |
		| path |
		path := q earliestArrivalTimePathOnEdgeStream: edges.
		1 to: path size - 1 do: [ :i |
			| edge nextEdge c |
			edge := path at: i.
			nextEdge := path at: i + 1.

			c := cVector at: edge ifAbsentPut: [ 0 ].
			cVector at: edge put: c + 1.

			at := at + edge duration asFloatSeconds

			"edge route = nextEdge route ifFalse: [
				edge departureTime asFloatSeconds + edge duration asFloatSeconds
				+ 1 to: nextEdge departureTime asFloatSeconds - 1 do: [ :secs |
					| o tup |
					tup := {
						       edge to.
						       secs }.
					o := oMatrix at: tup ifAbsentPut: [ 0 ].
					oMatrix at: tup put: o + q multiplicity.

					aw := aw + 1 ] ]" ] ].

	oMatrix keysDo: [ :tup |
		oMatrix at: tup update: [ :o | (o / k) asFloat ] ].

	cVector keysDo: [ :edge |
		cVector at: edge update: [ :c | (c / k) asFloat ] ].

	^ PNRRCN4OccupancyAndCrowding new
		  requestsSample: self;
		  averageTime: at;
		  averageWaiting: aw;
		  occupancyMatrix: oMatrix;
		  crowdingVector: cVector;
		  yourself
]

{ #category : 'accessing' }
PNRRCN4RequestsSample >> requests [

	^ requests
]

{ #category : 'accessing' }
PNRRCN4RequestsSample >> requests: anObject [

	requests := anObject sorted: [ :req :anotherReq |
		            self class
			            defaultIsRequest: req
			            lessThanRequest: anotherReq ]
]

{ #category : 'accessing' }
PNRRCN4RequestsSample >> totalCount [

	^ totalCount
]

{ #category : 'accessing' }
PNRRCN4RequestsSample >> totalCount: anObject [

	totalCount := anObject
]

{ #category : 'sampling' }
PNRRCN4RequestsSample >> weightedSampleAbsoluteError: epsilon prob: p [

	^ self weightedSampleOfSize:
		  (p halved ln negated halved / epsilon squared) ceiling
]

{ #category : 'sampling' }
PNRRCN4RequestsSample >> weightedSampleOfSize: aSize [

	| random remaining pool sample attempts count |
	random := RSRandom seed: Number firstCarmichaelNumber.

	pool := OrderedCollection new
		        addAll: self requests;
		        yourself.

	remaining := aSize min: pool size.
	attempts := 0.
	count := 0.

	sample := Array new: remaining streamContents: [ :aStream |
		          [ remaining > 0 ] whileTrue: [
			          | i req prob multiplicity |
			          attempts := attempts + 1. "one more attempt, just for debugging."
			          i := random nextInteger: pool size. "try an index."
			          req := pool at: i. "retrive the actual request."
			          multiplicity := req multiplicity. "bind its multiplicity"
			          prob := (multiplicity / totalCount) asFloat. "compute its frequence, aka probability mass."
			          random next <= prob ifTrue: [
				          aStream nextPut: req. "take it!"
				          pool removeAt: i. "remove from the remaining possibilities."
				          count := count + multiplicity. "accumulate the number of people."
				          remaining := remaining - 1 "one less to do" ] ] ].

	self traceCr: 'Attempts for sampling: ' , attempts asString.

	^ self class new
		  requests: sample;
		  totalCount: count;
		  yourself
]
