Class {
	#name : 'PNRRFruitMBitCoinGraph',
	#superclass : 'Object',
	#instVars : [
		'vertices',
		'edges'
	],
	#classVars : [
		'Instance'
	],
	#category : 'PNRRCN4-UrbanMobility-DLT Fruit - Bitcoin',
	#package : 'PNRRCN4-UrbanMobility',
	#tag : 'DLT Fruit - Bitcoin'
}

{ #category : 'TeX chunks' }
PNRRFruitMBitCoinGraph class >> estimatingDiameterTeXString [

	<tex: 'pdflatex' times: 2 pagesPerRow: 2>
	^ '
\documentclass[12pt, letterpaper]{article}
\usepackage[utf8]{inputenc}
%\documentclass[runningheads]{llncs}
%\documentclass[a4paper,UKenglish,cleveref, autoref, thm-restate]{lipics-v2021}
\usepackage{amsthm}
\usepackage{bbm}
\usepackage{complexity}
\usepackage{amsfonts}
\usepackage{soul,color}
\usepackage{authblk}
\usepackage{multirow}
\usepackage{mathrsfs}
\usepackage{xspace}
\usepackage{amsfonts,amssymb}
\usepackage{pgf,tikz}
\usepackage{euler}
\usepackage{times}
\usetikzlibrary{decorations}
\usetikzlibrary{decorations.markings}
\usepackage{tikz-network}
\usepackage{caption}
%\usepackage{fullpage}
\usepackage{subcaption}
\title{Diameter estimation}
\author{}
\date{}
\begin{document}
\maketitle

Let $G = (V, E)$ be a directed, \textit{acyclic} graph where $V$ and $E$ are the sets of vertices and edges, respectively.
Let $G^{T} = (V, E^{T})$ be the \textit{transposed} of $G$, where $ E^{T} = \lbrace (v, u): (u, v)\in E \rbrace$.

Define also $n = |V|$ and $R = |\lbrace (u, v) : u, v\in V \rbrace|$ such that there exists a path from $u$ to $v$ in the graph $G$. 
Let $S_k = (v_1, ..., v_k)$ be a sample of $k$ vertices uniformly choosen from $V$. 
For each $v_i \in S_k$ choose at random $u_i \in N_{E^{T}}(v_i)$, where $N_{E^{T}}: V \rightarrow 2^{V}$ denotes the neighborhood of a vertex in the transposed graph. 

The collection composed of each $u_i$, for all $i \in\lbrace 1,...,k\rbrace$, is our sample $U_k$ of vertices. 
To estimate the diameter, for each $u \in U_k$ compute $B_u = BFS(u, G)$ where $B_u=\lbrace (v, d) \in V \times \mathbb{N} \rbrace$ is a set of distances; then accumulate 
$$
\sum_{(v, d)\in B_u}{d}
$$
and $|B_u|$ in two variables $D$ and $C$, respectively initialized both to $0$; the ratio $\frac{D}{C}$ is the estimation of the diameter, as desired.

\begin{proof} Without loss of generality, let $u\in V$ be a vertex; then,
$$
\mathbb{P}\,\lbrace u \in U_k \rbrace = \frac{\left| \lbrace v \in V: u \leadsto v \rbrace \right|}{R}
$$
in
$$
\hat{D} = \sum_{(u, v) \in V^2:\, u \leadsto v}{\frac{dist(u, v)}{R}} 
$$
\end{proof}

\end{document}
	'
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instance [

	^ Instance ifNil: [ Instance := self newInstance ]
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instance1k [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/1k.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instance1m [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/1m.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instance5m [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/5m.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instanceErdosRenyi [

	^ self onFileReference:
		  'pharo-local/iceberg/massimo-nocentini/PNRRCN4-UrbanMobility/data/erdos-renyi/1k-0.001p.txt'
			  asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> instanceHuge [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/pg-edges.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> newInstance [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/very-small.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> onFileReference: aFileReference [

	| graph |
	graph := self new.

	aFileReference exists ifTrue: [
		aFileReference readStreamDo: [ :fileStream |
			[ fileStream atEnd ] whileFalse: [
				| line i |
				line := fileStream nextLine.
				i := line indexOf: Character tab.

				graph
					addEdgeFrom: (line copyFrom: 1 to: i - 1)
					to: (line copyFrom: i + 1 to: line size) ] ] ].

	^ graph
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> resetInstance [

	Instance := nil
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph class >> smallInstance [
	" '/home/mn/Developer/bitcoin/small.txt'"

	^ self onFileReference:
		  '/Volumes/Data/bitcoin/small.txt' asFileReference
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph >> addEdgeFrom: fromId to: toId [

	| edge from to |
	from := vertices at: fromId ifAbsentPut: [
		        PNRRFruitMBitCoinVertex new
			        id: fromId;
			        index: vertices size + 1;
			        yourself ].

	to := vertices at: toId ifAbsentPut: [
		      PNRRFruitMBitCoinVertex new
			      id: toId;
			      index: vertices size + 1;
			      yourself ].

	edge := PNRRFruitMBitCoinEdge new
		        from: from;
		        to: to;
		        index: edges size + 1;
		        yourself.

	edges add: edge.

	from outgoingNeighborhood add: edge.
	to incomingNeighborhood add: edge.

	^ edge
]

{ #category : 'converting' }
PNRRFruitMBitCoinGraph >> asVerticesArray [

	| array |
	array := Array new: vertices size.

	vertices valuesDo: [ :v | array at: v index put: v ].

	^ array
]

{ #category : 'estimation' }
PNRRFruitMBitCoinGraph >> diameter [

	| d |
	d := 0.
	
	vertices valuesDo: [ :v |
		d := d max: v breadthFirstSearch maxDistance ].

	^ d
]

{ #category : 'initialization' }
PNRRFruitMBitCoinGraph >> initialize [

	super initialize.

	vertices := Dictionary new.
	edges := OrderedCollection new
]

{ #category : 'accessing' }
PNRRFruitMBitCoinGraph >> vertexAt: anObject [

	^ vertices at: anObject
]

{ #category : 'sampling' }
PNRRFruitMBitCoinGraph >> verticesSample: epsilon [

	| k pool random sample backward cross distances init |
	k := (vertices size ln / epsilon squared) ceiling min: vertices size.

	random := RSRandom seed: Number firstCarmichaelNumber.

	pool := OrderedCollection newFrom: vertices values.

	sample := Array new: k.

	1 to: k do: [ :j |
		| i |
		i := random nextInteger: pool size.
		sample at: j put: (pool removeAt: i) ].

	cross := Dictionary new.

	backward := sample collect: [ :each |
		            | bfs |
		            bfs := each breadthFirstSearchBackwardDo: [ :v :d |
			                   | col |
			                   col := cross
				                          at: v
				                          ifAbsentPut: [ OrderedCollection new ].

			                   col add: d ].

		            bfs maxVertex ifNil: [ each ] ].

	distances := OrderedCollection new: cross size.
	init := 0.
	cross keysAndValuesDo: [ :v :ds |
		init := init + ds size.
		distances add: v -> init ].
	distances := distances timsort: #value.

	backward := sample collect: [ :each |
		            | j w |
		            j := random nextInteger: init.

		            w := distances
			                 findBinaryIndex: [ :assoc |
				                 | f |
				                 f := assoc value.
				                 j = f
					                 ifTrue: [ 0 ]
					                 ifFalse: [
						                 j < f
							                 ifTrue: [ -1 ]
							                 ifFalse: [ 1 ] ] ]
			                 ifNone: [ :l | l ].

		            (distances at: w) key ].

	^ PNRRFruitMBitCoinSample new
		  sample: backward;
		  yourself
]
