Class {
	#name : 'PNRRCN4EdgesStreamRepresentation',
	#superclass : 'Object',
	#instVars : [
		'edgesStream'
	],
	#category : 'PNRRCN4-UrbanMobility-API',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'API'
}

{ #category : 'instance creation' }
PNRRCN4EdgesStreamRepresentation class >> onSystem: aSystem [

	| temporalStream |
	temporalStream := Array
		                  new: aSystem temporalEdgesSize
		                  streamContents: [ :aStream |
			                  aSystem stops do: [ :stop |
				                  aStream nextPutAll:
					                  stop temporalOutgoingNeighborhood ] ].

	^ self new
		  edgesStream:
			  (temporalStream timsort: [ :edge | edge timsortSortKey ]);
		  yourself
]

{ #category : 'displaying' }
PNRRCN4EdgesStreamRepresentation >> displayStringOn: aStream [

	self edgesStream size displayStringOn: aStream.
	aStream << ' edges: first dep time '.
	self edgesStream first departureTime displayStringOn: aStream.
	aStream << ', last dep time '.
	self edgesStream last departureTime displayStringOn: aStream
]

{ #category : 'accessing' }
PNRRCN4EdgesStreamRepresentation >> edgesStream [

	^ edgesStream
]

{ #category : 'accessing' }
PNRRCN4EdgesStreamRepresentation >> edgesStream: anObject [

	edgesStream := anObject
]
