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

{ #category : 'as yet unclassified' }
PNRRCN4RequestsSample class >> defaultIsRequest: req lessThanRequest: anotherReq [

	^ req time = anotherReq time
		  ifTrue: [ req multiplicity < anotherReq multiplicity ]
		  ifFalse: [ req time < anotherReq time ]
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
