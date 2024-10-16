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

{ #category : 'instance creation' }
PNRRCN4RequestsSample class >> requests: aCollection onSystem: aSystem [

	| col count stops |
	stops := aSystem stops.
	count := 0.

	col := aCollection select: [ :request |
		       | keep |
		       keep := true.

		       request
			       fromStop: (stops at: request fromStopId ifAbsent: [
						        keep := false.
						        nil ]);
			       toStop: (stops at: request toStopId ifAbsent: [
						        keep := false.
						        nil ]);
			       time: (DateAndTime fromUnixTime: request unixTime) asTime.

		       keep ifTrue: [
			       count := count + request multiplicity.
			       request owner: aSystem ].

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

{ #category : 'testing' }
PNRRCN4RequestsSample >> isRequest: req lessThanRequest: anotherReq [

	^ req time = anotherReq time
		  ifTrue: [ req multiplicity < anotherReq multiplicity ]
		  ifFalse: [ req time < anotherReq time ]
]

{ #category : 'estimation' }
PNRRCN4RequestsSample >> occupancyAndCrowding [

	| aw at k oMatrix cVector res edges |
	edges := self temporalEdges.
	k := self requests size asFloat.
	aw := at := 0.0.
	oMatrix := Dictionary new.
	cVector := Dictionary new.

	self requests do: [ :q |
		| path multiplicity |
		multiplicity := q multiplicity asFloat / k.

		path := q earliestArrivalTimePath.

		1 to: path size - 1 do: [ :i |
			| edge nextEdge c |
			edge := path at: i.
			nextEdge := path at: i + 1.

			c := cVector at: edge ifAbsentPut: 0.
			cVector at: edge put: c + 1.

			at := at + edge duration asFloatSeconds.

			edge trip = nextEdge trip ifFalse: [
				edge arrivalTime asFloatSeconds + 60.0 to:
					nextEdge departureTime asFloatSeconds - 60.0 by: 60.0 do: [ :secs |
					| col |
					col := oMatrix at: secs ceiling ifAbsentPut: [ Dictionary new ].

					col
						at: edge to
						update: [ :o | o + multiplicity ]
						initial: multiplicity.

					aw := aw + 1.0 ] ] ] ].

	res := Dictionary new.
	oMatrix keysAndValuesDo: [ :t :dict |
		res
			at: (Time seconds: t)
			put: (dict associations timsort: #value reverse: true) ].

	^ PNRRCN4OccupancyAndCrowding new
		  requestsSample: self;
		  averageTime: (Duration seconds: at / k);
		  averageWaiting: (Duration seconds: aw / k);
		  occupancyMatrix:
			  (res associations timsort: [ :assoc | assoc key asFloatSeconds ]);
		  crowdingVector:
			  (cVector associations timsort: #value reverse: true);
		  yourself
]

{ #category : 'accessing' }
PNRRCN4RequestsSample >> requests [

	^ requests
]

{ #category : 'accessing' }
PNRRCN4RequestsSample >> requests: anObject [

	requests := anObject sorted: [ :req :anotherReq |
		            self isRequest: req lessThanRequest: anotherReq ]
]

{ #category : 'accessing' }
PNRRCN4RequestsSample >> temporalEdges [

	^ self requests
		  ifEmpty: [ Array new ]
		  ifNotEmpty: [ :reqs | reqs first owner temporalEdges ]
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

	| random remaining pool sample count |
	aSize >= self requests size ifTrue: [ ^ self ].

	random := RSRandom new.

	pool := OrderedCollection new
		        addAll: self requests;
		        yourself.

	remaining := aSize.
	count := 0.

	sample := Array new: remaining streamContents: [ :aStream |
		          [ remaining > 0 ] whileTrue: [
			          | i req prob multiplicity |
			          i := random nextInteger: pool size. "try an index."
			          req := pool at: i. "retrive the actual request."
			          multiplicity := req multiplicity. "bind its multiplicity"
			          prob := multiplicity / totalCount. "compute its frequence, aka probability mass."
			          random next <= prob asFloat ifTrue: [
				          aStream nextPut: req. "take it!"
				          pool removeAt: i. "remove from the remaining possibilities."
				          count := count + multiplicity. "accumulate the number of people."
				          remaining := remaining - 1 "one less to do" ] ] ].

	^ self class new
		  requests: sample;
		  totalCount: count;
		  yourself
]
