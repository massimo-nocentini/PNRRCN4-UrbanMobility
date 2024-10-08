Class {
	#name : 'BaselineOfPNRRCN4UrbanMobility',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPNRRCN4UrbanMobility',
	#package : 'BaselineOfPNRRCN4UrbanMobility'
}

{ #category : 'baselines' }
BaselineOfPNRRCN4UrbanMobility >> baseline: spec [

	<baseline>
	spec for: #common do: [
		spec
			baseline: 'NeoCSV'
			with: [ spec repository: 'github://svenvc/NeoCSV' ].

		spec
			package: 'PNRRCN4-UrbanMobility';
			package: 'PNRRCN4-UrbanMobility-Tests' ]
]
