
local D = require 'diameter'

local f = '../data/erdos-renyi/5k-0.001p.txt'


local g = D.parse_graph (f)

D.write_graph (g,  '../data/erdos-renyi/5k-0.001p.data', 'outhood')