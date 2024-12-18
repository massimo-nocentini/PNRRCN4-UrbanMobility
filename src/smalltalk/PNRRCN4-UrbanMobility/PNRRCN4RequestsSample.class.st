Class {
	#name : 'PNRRCN4RequestsSample',
	#superclass : 'Object',
	#instVars : [
		'requests',
		'totalCount',
		'timeStepInSeconds'
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

{ #category : 'initialization' }
PNRRCN4RequestsSample >> initialize [

	super initialize.

	self timeStepInSeconds: 60
]

{ #category : 'testing' }
PNRRCN4RequestsSample >> isRequest: req lessThanRequest: anotherReq [

	^ req time = anotherReq time
		  ifTrue: [ req multiplicity < anotherReq multiplicity ]
		  ifFalse: [ req time < anotherReq time ]
]

{ #category : 'estimation' }
PNRRCN4RequestsSample >> occupancy: oMatrix crowding: cVector [

	| k timeStep newDictionaryBlock at aw |
	newDictionaryBlock := [ Dictionary new ].

	"Some parameters."
	timeStep := self timeStepInSeconds asFloat.
	k := self totalCount asFloat.

	"Output."
	at := aw := 0.0.

	"Go!"
	self requests do: [ :q |
		| path multiplicity |
		multiplicity := q multiplicity asFloat / k.

		path := q earliestArrivalTimePath.

		1 to: path size - 1 do: [ :i |
			| edge nextEdge c |
			edge := path at: i.
			nextEdge := path at: i + 1.

			c := cVector at: edge ifAbsentPut: 0.0.
			cVector at: edge put: c + multiplicity.

			at := at + (edge duration * multiplicity).

			edge trip = nextEdge trip ifFalse: [
				edge arrivalTime + timeStep to: nextEdge departureTime - timeStep
					by: timeStep do: [ :secs |
					| col |
					col := oMatrix at: secs ceiling ifAbsentPut: newDictionaryBlock.

					col
						at: edge to
						update: [ :o | o + multiplicity ]
						initial: multiplicity.

					aw := aw + multiplicity ] ] ] ].

	^ Array with: at with: aw
]

{ #category : 'estimation' }
PNRRCN4RequestsSample >> occupancyAndCrowding [

	| oMatrix cVector res pair |
	"The output."
	oMatrix := Dictionary new.
	cVector := Dictionary new.
	pair := self occupancy: oMatrix crowding: cVector.

	res := Dictionary new.
	oMatrix keysAndValuesDo: [ :t :dict |
		res
			at: (Time seconds: t)
			put: (dict associations timsort: #value reverse: true) ].

	^ PNRRCN4OccupancyAndCrowding new
		  requestsSample: self;
		  averageTime: (Duration seconds: pair first);
		  averageWaiting: pair second;
		  occupancyMatrix:
			  (res associations timsort: [ :assoc | assoc key asUnixTime ]);
		  crowdingVector:
			  (cVector associations timsort: #value reverse: true);
		  yourself
]

{ #category : 'displaying' }
PNRRCN4RequestsSample >> printOn: aStream [

	aStream
		<< 'Sample of ';
		<< self requests size asString;
		<< ' requests by ';
		<< self totalCount asString;
		<< ' people'
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
PNRRCN4RequestsSample >> timeStepInSeconds [

	^ timeStepInSeconds
]

{ #category : 'accessing' }
PNRRCN4RequestsSample >> timeStepInSeconds: anObject [

	timeStepInSeconds := anObject
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
PNRRCN4RequestsSample >> weighted [

	^ self weightedSampleOfSize: self totalCount
]

{ #category : 'sampling' }
PNRRCN4RequestsSample >> weightedSampleAbsoluteError: epsilon prob: p [

	| alpha k n |
	n := self totalCount.
	alpha := 2.0 / p log: n.
	k := alpha * n ln / epsilon squared doubled.

	^ self weightedSampleOfSize: k ceiling
]

{ #category : 'sampling' }
PNRRCN4RequestsSample >> weightedSampleOfSize: aSize [

	| random pool sample |
	aSize > self totalCount ifTrue: [
		Error signal: 'Requested too many people.' ].

	pool := OrderedCollection
		        new: self totalCount
		        streamContents: [ :aStream |
			        self requests do: [ :q |
				        | qq |
				        qq := q copy
					              multiplicity: 1;
					              yourself.

				        q multiplicity timesRepeat: [ aStream nextPut: qq ] ] ].

	random := RSRandom new.

	sample := IdentityDictionary new: aSize.
	aSize timesRepeat: [
		| q i m |
		i := random nextInteger: pool size.
		q := pool at: i. "using #at: means sampling with replacement, using #removeAt: means sampling without replacement."
		m := sample at: q ifAbsentPut: 0.
		sample at: q put: m + 1 ].

	sample keysAndValuesDo: [ :q :m | q multiplicity: m ].

	^ self class new
		  requests: sample keys;
		  totalCount: aSize;
		  yourself
]
