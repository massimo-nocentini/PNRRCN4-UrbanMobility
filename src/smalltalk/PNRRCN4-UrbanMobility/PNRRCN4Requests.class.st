Class {
	#name : 'PNRRCN4Requests',
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
PNRRCN4Requests class >> defaultIsRequest: req lessThanRequest: anotherReq [

	^ req time = anotherReq time
		  ifTrue: [ req multiplicity < anotherReq multiplicity ]
		  ifFalse: [ req time < anotherReq time ]
]

{ #category : 'accessing' }
PNRRCN4Requests >> requests [

	^ requests
]

{ #category : 'accessing' }
PNRRCN4Requests >> requests: anObject [

	requests := anObject
]

{ #category : 'accessing' }
PNRRCN4Requests >> totalCount [

	^ totalCount
]

{ #category : 'accessing' }
PNRRCN4Requests >> totalCount: anObject [

	totalCount := anObject
]

{ #category : 'initialization' }
PNRRCN4Requests >> weightedSampleOfSize: aSize [

	| random remaining pool sample attempts |
	random := RSRandom seed: Number firstCarmichaelNumber.

	pool := OrderedCollection new
		        addAll: self requests;
		        yourself.

	remaining := aSize min: pool size.
	attempts := 0.

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
				          remaining := remaining - 1 ] ] ].

	^ sample
		  sort: [ :req :anotherReq |
			  self class defaultIsRequest: req lessThanRequest: anotherReq ];
		  -> attempts
]
