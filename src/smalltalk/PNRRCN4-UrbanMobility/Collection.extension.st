Extension { #name : 'Collection' }

{ #category : '*PNRRCN4-UrbanMobility' }
Collection >> samplingWithEpsilon: epsilon random: random collect: block [

	| k pool mySize sample |
	mySize := self size.

	k := (mySize ln / epsilon squared) ceiling min: mySize.

	pool := OrderedCollection newFrom: self.

	sample := Array new: k.

	1 to: k do: [ :j |
		| i o m |
		i := random nextInteger: pool size.
		o := pool removeAt: i.
		m := block value: o.
		sample at: j put: m ].

	^ sample
]
