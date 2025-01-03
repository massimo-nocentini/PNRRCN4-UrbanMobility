
local D = require 'diameter'

local filename = arg[1]
local n = arg[2] or 1
local epsilon = arg[3] or 0.1

local epsilon = { 
	--0.8, 
	--0.2, 
	0.1, 
}
local size = { 
	1, 
	--10, 
	--30, 
}
local filename = {

	
	--[[
	'../data/erdos-renyi/100-0.001p.txt',
	'../data/erdos-renyi/200-0.001p.txt',
	'../data/erdos-renyi/500-0.001p.txt',
	'../data/erdos-renyi/800-0.001p.txt',
	'../data/erdos-renyi/1k-0.001p.txt',
	'../data/erdos-renyi/2k-0.001p.txt',
	'../data/erdos-renyi/5k-0.001p.txt',
	--]]

	'/home/mn/Developer/bitcoin/pg-edges.txt',
}

--collectgarbage 'stop'

for _, f in pairs (filename) do
	local t = os.time ()
	local g = D.parse_graph (f)
	print (f, 'graph loaded in seconds: ', os.difftime (os.time (), t))
	for _, e in pairs (epsilon) do
		for _, n in pairs (size) do
			print (table.unpack (D.average_distance (f, g, n, e)))
		end
	end
end

