
local D = require 'diameter'

local f = '../data/dummy/d1.txt'
local n = arg[2] or 1
local e = arg[3] or 0.1


local g = D.parse_graph (f)
print (table.unpack (D.average_distance (f, g, n, e)))
