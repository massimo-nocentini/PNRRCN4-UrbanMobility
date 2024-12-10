

local libluabag = require 'libluabag'


local t = os.time ()

local nvertices, graph = libluabag.load_binary_repr '/data/bitcoin/bitcoin-webgraph/pg.data'

print ('Loaded in ', os.difftime(os.time(), t))

libluabag.free_binary_repr (nvertices, graph)

print 'freed.'