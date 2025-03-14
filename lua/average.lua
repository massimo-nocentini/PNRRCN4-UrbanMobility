

local libluabag = require 'libluabag'


local t = os.time ()

--local nvertices, graph = libluabag.load_binary_repr '/data/bitcoin/bitcoin-webgraph/pg.data'
local nvertices, graph = libluabag.load_binary_repr '../data/erdos-renyi/5k-0.001p.data'

print ('Loaded in ', os.difftime(os.time(), t))

t = os.time ()

local distances = libluabag.bin_bfs (math.random(nvertices), nvertices, graph)

print ('bfs in ', os.difftime(os.time(), t))


libluabag.free_binary_repr (nvertices, graph)

print 'freed.'