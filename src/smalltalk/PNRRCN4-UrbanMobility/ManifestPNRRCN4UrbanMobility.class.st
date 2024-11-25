"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestPNRRCN4UrbanMobility',
	#superclass : 'PackageManifest',
	#category : 'PNRRCN4-UrbanMobility-Manifest',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestPNRRCN4UrbanMobility class >> ruleToDoCollectRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#PNRRFruitMBitCoinGraph #verticesSample: #false)) #'2024-11-25T10:38:49.526108+01:00') )
]
