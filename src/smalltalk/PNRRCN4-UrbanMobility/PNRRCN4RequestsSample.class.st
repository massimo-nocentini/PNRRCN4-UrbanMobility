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

{ #category : 'initialization' }
PNRRCN4RequestsSample >> weightedSampleOfSize: aSize [

	| random remaining pool sample attempts count |
	random := RSRandom seed: Number firstCarmichaelNumber.

	pool := OrderedCollection new
		        addAll: self requests;
		        yourself.

	remaining := aSize min: pool size.
	attempts := 0.
	count := 0.

	sample := Array streamContents: [ :aStream |
		          [ remaining > 0 ] whileTrue: [
			          | i req prob |
			          attempts := attempts + 1.
			          i := random nextInteger: pool size.
			          req := pool at: i.
			          prob := (req multiplicity / totalCount) asFloat.
			          random next <= prob ifTrue: [
				          aStream nextPut: req.
				          pool removeAt: i.
				          count := count + req multiplicity.
				          remaining := remaining - 1 ] ] ].

	self traceCr: 'Attempts for sampling: ' , attempts asString.

	^ self class new
		  requests: sample;
		  totalCount: count;
		  yourself
]
