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
	#category : 'PNRRCN4-UrbanMobility-API',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'API'
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

	aStream
		<< 'In average: ';
		<< self averageWaiting ceiling asString;
		<< ' people wait at stops'.

	aStream << ', travelling time '.
	self averageTime printOn: aStream
]

{ #category : 'printing' }
PNRRCN4OccupancyAndCrowding >> printStringVerbose [

	^ String streamContents: [ :aStream |
		  self printOn: aStream.

		  aStream
			  cr;
			  cr;
			  << '*** Requests sample';
			  cr.
		  self requestsSample printOn: aStream.

		  aStream
			  cr;
			  cr;
			  << '*** Crowding vector (most crowded edge first)';
			  cr.

		  self crowdingVector do: [ :each |
			  aStream
				  << (each value * 100.0 printShowingDecimalPlaces: 2);
				  << '% people travelling in '.
			  each key printOn: aStream.
			  aStream cr ].

		  aStream
			  cr;
			  cr;
			  <<
				  '*** Occupancy matrix (chronologically ordered, most crowded stops first)';
			  cr.

		  self occupancyMatrix do: [ :each |
			  each key printOn: aStream.
			  aStream << ':'.

			  each value do: [ :assoc |
				  aStream
					  cr;
					  tab.
				  aStream << (assoc value * 100.00 printShowingDecimalPlaces: 2).
				  aStream << '% of people waiting in '.
				  assoc key printOn: aStream ].

			  aStream cr ] ]
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> requestsSample [

	^ requestsSample
]

{ #category : 'accessing' }
PNRRCN4OccupancyAndCrowding >> requestsSample: anObject [

	requestsSample := anObject
]
