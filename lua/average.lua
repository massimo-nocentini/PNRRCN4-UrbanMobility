

local libluabag = require 'libluabag'


local t = os.time ()

local nvertices, graph, graph_t = libluabag.load_binary_repr(
	'/data/bitcoin/bitcoin-webgraph/pg.data', 
	'/data/bitcoin/bitcoin-webgraph/pg-t.data'
)


print ('Loaded in ', os.difftime(os.time(), t))

libluabag.free_binary_repr (nvertices, graph)
libluabag.free_binary_repr (nvertices, graph_t)

print 'freed.'