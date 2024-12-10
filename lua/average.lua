

local libluabag = require 'libluabag'


local t = os.time ()

local nvertices, graph, graph_t = libluabag.load_binary_repr(
	'/home/mn/Developer/bitcoin/pg.data', 
	'/home/mn/Developer/bitcoin/pg-t.data'
)


print ('Loaded in ', os.difftime(os.time(), t))

libluabag.free_binary_repr (nvertices, graph)
libluabag.free_binary_repr (nvertices, graph_t)