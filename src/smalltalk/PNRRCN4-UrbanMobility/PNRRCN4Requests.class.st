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
PNRRCN4Requests >> weightedSampleOfSize: s [

	| random remaining pool sample |
	random := RSRandom seed: Number firstCarmichaelNumber.

	pool := OrderedCollection new
		        addAll: self requests;
		        yourself.

	sample := Array streamContents: [ :aStream |
		          remaining := s min: requests size.

		          [ remaining > 0 ] whileTrue: [
			          | i req |
			          i := random nextInteger: pool size.
			          req := pool at: i.

			          random next <= (req multiplicity / totalCount) asFloat
				          ifTrue: [
					          aStream << req.
					          pool removeAt: i.
					          remaining := remaining - 1 ] ] ].

	^ sample
		  sort: [ :req :anotherReq |
			  self class defaultIsRequest: req lessThanRequest: anotherReq ];
		  yourself
]
