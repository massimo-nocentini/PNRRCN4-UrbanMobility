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
			with: [ spec repository: 'github://svenvc/NeoCSV:master/repository' ].

		spec
			baseline: 'ContainersEssentials'
			with: [
			spec repository: 'github://massimo-nocentini/Containers-Essentials:master' ].

		spec
			baseline: 'TimSort'
			with: [
				spec
					repository: 'github://massimo-nocentini/timsort.st:master/src';
					loads: #( 'Core' ) ].

		spec
			baseline: 'LibPoppler'
			with: [
			spec repository: 'github://massimo-nocentini/libpoppler.st:master/src' ].

		spec
			package: 'PNRRCN4-UrbanMobility'
			with: [ spec requires: #( 'NeoCSV' 'ContainersEssentials' 'TimSort' ) ];
			package: 'PNRRCN4-UrbanMobility-Tests'
			with: [ spec requires: #( 'PNRRCN4-UrbanMobility' 'LibPoppler' ) ] ]
]
