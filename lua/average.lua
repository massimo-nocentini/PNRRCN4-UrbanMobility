

local libluabag = require 'libluabag'


local t = os.time ()

local nvertices, graph = libluabag.load_binary_repr '/data/bitcoin/bitcoin-webgraph/pg.data'

print ('Loaded in ', os.difftime(os.time(), t))

t = os.time ()

local distances = libluabag.bin_bfs (0, nvertices, graph)

print ('bfs in ', os.difftime(os.time(), t))

for k, v in ipairs (distances) do

	print (k, v)

end

libluabag.free_binary_repr (nvertices, graph)

print 'freed.'