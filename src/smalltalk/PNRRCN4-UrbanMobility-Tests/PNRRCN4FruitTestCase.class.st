Class {
	#name : 'PNRRCN4FruitTestCase',
	#superclass : 'TestCase',
	#traits : 'TIceImagesExporting',
	#classTraits : 'TIceImagesExporting classTrait',
	#category : 'PNRRCN4-UrbanMobility-Tests',
	#package : 'PNRRCN4-UrbanMobility-Tests'
}

{ #category : 'benchmarking' }
PNRRCN4FruitTestCase >> exampleFor001p [

	<script: 'PNRRCN4FruitTestCase new exampleFor001p'>
	| elapsedTime |
	elapsedTime := [
	               PNRRFruitMBitCoinBench new
		               filenames:
			               { 'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/100-0.001p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/200-0.001p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/500-0.001p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/800-0.001p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/1k-0.001p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/2k-0.001p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/5k-0.001p.txt' };
		               bench ] timeToRun.

	Transcript
		cr;
		nextPutAll: elapsedTime asString
]

{ #category : 'benchmarking' }
PNRRCN4FruitTestCase >> exampleFor01p [

	<script: 'PNRRCN4FruitTestCase new exampleFor01p'>
	| elapsedTime |
	elapsedTime := [
	               PNRRFruitMBitCoinBench new
		               filenames:
			               { 'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/100-0.01p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/200-0.01p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/500-0.01p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/800-0.01p.txt'.
			               'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/1k-0.01p.txt' };
		               bench ] timeToRun.

	Transcript
		cr;
		nextPutAll: elapsedTime asString
]

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
		exportSlotsGraphOf:
		PNRRFruitMBitCoinVertex >> #breadthFirstSearchBackward
		pathSuffix: 'bfs-back'.



	self
		exportSlotsGraphOf: PNRRFruitMBitCoinSample >> #diameter
		pathSuffix: 'diameter'.

	pdf := PopplerPdf
		       compileTeX:
		       PNRRFruitMBitCoinGraph estimatingDiameterTeXString
		       times: 2.

	self exportSlotsGraphOf: pdf pages pathSuffix: 'pdf'
]
