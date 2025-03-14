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

	col := aCollection
		       select: [ :request |
			       (stops includesKey: request fromStopId) and: [
				       stops includesKey: request toStopId ] ]
		       thenCollect: [ :request |
			       count := count + request multiplicity.
			
			       request
				       owner: aSystem;
				       fromStop: (stops at: request fromStopId);
				       toStop: (stops at: request toStopId);
				       yourself ].

	^ self new
		  requests: col timsort;
		  totalCount: count;
		  yourself
]

{ #category : 'initialization' }
PNRRCN4RequestsSample >> initialize [

	super initialize.

	self timeStepInSeconds: 1 minute
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
	timeStep := self timeStepInSeconds.
	k := self totalCount asFloat.

	"Output."
	at := Duration zero.
	aw := 0.0.

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
					col := oMatrix
						       at: secs asUnixTime
						       ifAbsentPut: newDictionaryBlock.

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
			at: (DateAndTime fromUnixTime: t)
			put: (dict associations timsort: #value reverse: true) ].

	^ PNRRCN4OccupancyAndCrowding new
		  requestsSample: self;
		  averageTime: pair first;
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

	| random sample cumulatedMultiplicities count |
	aSize > self totalCount ifTrue: [
		Error signal: 'Requested too many people.' ].

	cumulatedMultiplicities := self requests
		                           scan: [ :m :each | m + each multiplicity ]
		                           withoutInit: 0.

	random := RSRandom new.

	count := 0.
	sample := Array new: aSize streamContents: [ :s |
		          1 to: aSize do: [ :i |
			          | hi lo m each j |
			          m := random nextInteger: cumulatedMultiplicities last.

			          lo := 1.
			          hi := cumulatedMultiplicities size.

			          [ lo < hi ] whileTrue: [
				          j := lo + hi >> 1.
				          each := cumulatedMultiplicities at: j.

				          each < m
					          ifTrue: [ lo := j + 1 ]
					          ifFalse: [ hi := j ] ].

			          each := (self requests at: lo) copy
				                  multiplicity: 1;
				                  yourself.

			          s nextPut: each.

			          count := count + each multiplicity ] ].

	^ self class new
		  requests: sample;
		  totalCount: count;
		  yourself
]
