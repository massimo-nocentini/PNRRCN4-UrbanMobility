Class {
	#name : 'PNRRCN4OccupancyAndCrowding',
	#superclass : 'Object',
	#instVars : [
		'requestsSample',
		'averageWaiting',
		'averageTime',
		'occupancyMatrix',
		'crowdingVector'
	],
	#category : 'PNRRCN4-UrbanMobility-Core',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Core'
}

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> averageTime [

	^ averageTime
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> averageTime: anObject [

	averageTime := anObject
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> averageWaiting [

	^ averageWaiting
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> averageWaiting: anObject [

	averageWaiting := anObject
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> crowdingVector [

	^ crowdingVector
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> crowdingVector: anObject [

	crowdingVector := anObject
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> occupancyMatrix [

	^ occupancyMatrix
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> occupancyMatrix: anObject [

	occupancyMatrix := anObject
]

{ #category : 'printing' }
PNRRCN4OccupancyAndCrowding >> printOn: aStream [

	| avg |
	aStream << 'In average: waiting time '.
	self averageWaiting printOn: aStream.

	aStream << ', travelling time '.
	self averageTime printOn: aStream.

	avg := self crowdingVector
		       foldr: [ :each :count | each value + count ]
		       init: 0.

	aStream << ', people per edge '.
	(avg / self crowdingVector size) asFloat printOn: aStream
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> requestsSample [

	^ requestsSample
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> requestsSample: anObject [

	requestsSample := anObject
]
