Class {
	#name : 'PNRRCN4FruitTestCase',
	#superclass : 'TestCase',
	#traits : 'TIceImagesExporting',
	#classTraits : 'TIceImagesExporting classTrait',
	#category : 'PNRRCN4-UrbanMobility-Tests',
	#package : 'PNRRCN4-UrbanMobility-Tests'
}

{ #category : 'tests' }
PNRRCN4FruitTestCase >> testExportCompiledMethods [

	| pdf |
	self
		exportSlotsGraphOf: PNRRFruitMBitCoinGraph >> #verticesSample:
		pathSuffix: 'sampling'.

	self
		exportSlotsGraphOf: PNRRFruitMBitCoinVertex >> #breadthFirstSearch
		pathSuffix: 'bfs'.

	self
		exportSlotsGraphOf: PNRRFruitMBitCoinSample >> #diameter
		pathSuffix: 'diameter'.

	pdf := PopplerPdf
		       compileTeX:
		       PNRRFruitMBitCoinGraph estimatingDiameterTeXString
		       times: 2.

	self exportSlotsGraphOf: pdf pages pathSuffix: 'pdf'
]
