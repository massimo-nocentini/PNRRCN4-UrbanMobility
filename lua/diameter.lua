
-- the following script allows us to test the main algorithm over the whole file.

local libluabag = require 'libluabag'

local function bfs (v, borhoodSelector)

	local key = 'bfs' .. borhoodSelector
	
	if not v[key] then
		--[[
		local seen = {layers = {}}
		local queue = {} for i, w in ipairs (v[borhoodSelector]) do queue[i] = {vertex = w, distance = 1} end

		while #queue > 0 do
			local meta = table.remove (queue, 1)
			local vertex, distance = meta.vertex, meta.distance
			if not seen[vertex] then
				seen[vertex] = distance
				table.insert(seen, vertex)

				local l = seen.layers[distance]
				if not l then l = {}; seen.layers[distance] = l end
				table.insert (l, vertex)

				local d = distance + 1
				for i, w in ipairs (vertex[borhoodSelector]) do table.insert (queue, {vertex = w, distance = d}) end
			end
		end
		--]]

		---[[
		local seen = libluabag.pbfs (v, borhoodSelector)
		seen.layers = {}
		--for w, d in pairs (B) do
			--local w = v.graph.vertices[k]
			--seen[k] = w	-- by position
		--	seen[w] = d -- by key
		--	table.insert (seen, w)
			--local l = seen.layers[d]
			--if not l then l = {}; seen.layers[d] = l end
			--table.insert (l, w)
		--end
		
		--]]

		v[key] = seen
	end

	return v[key]

end

local function sample_size (vertices, epsilon)
	local n = #vertices
	return math.min(math.ceil (math.log (n) / (epsilon * epsilon)), n)
end

local function sample (vertices, k)

	local pool = {} for i, v in ipairs (vertices) do pool[i] = v end -- just prepare the pool

	local V = {} for j=1, k do V[j] = table.remove (pool, math.random (#pool)) end

	local S = {} -- the sample

	for i = 1, k do
		local v = V[i]
		local vbfs = bfs (v, 'inhood')

		for j = 1, #vbfs do
			local w = vbfs[j]
			if not S[w] then
				S[w] = 0
				table.insert (S, w)
			end
			S[w] = S[w] + vbfs[w]
		end

		if #vbfs == 0 then 
			if not S[v] then 
				S[v] = 1
				table.insert (S, v) 
			end
		end
	end

	local SS = {} 
	for j=1, k do
		if #S == 0 then SS[j] = V[j] 
		else SS[j] = table.remove (S, math.random (#S)) end
	end

	return SS

end


local function average_distance (V)

	local d, c = 0, 0

	for i, v in ipairs (V) do
		local vbfs = bfs (v, 'outhood')
		for i, w in ipairs (vbfs) do
			d = d + vbfs[w]
			c = c + 1 
		end
	end

	return d / c
end

--------------------------------------------------------------------------------

local module = {}

function module.parse_graph (filename)

	local graph = { vertices = {}, edges = {} }

	local function vertex_of (id)

		local vs = graph.vertices

		if not vs[id] then
			local v = {
				graph = graph,
				id = id,
				index = #vs + 1, 
				outhood = {}, 
				inhood = {}
			}
			vs[v.index] = v -- to allow access by position
			vs[id] = v -- and by id.
		end

		return vs[id]
	end

	for l in io.lines (filename) do
		local i = string.find (l, '\t')
		local from = vertex_of (string.sub (l, 1, i - 1))
		local to = vertex_of (string.sub (l, i + 1))

		table.insert (from.outhood, to)
		table.insert (to.inhood, from)
		table.insert (graph.edges, {from, to})
	end

	return graph
end

function module.average_distance (filename, graph, n, epsilon)

	local t = os.time ()
	local avg = 0.0
	local k = sample_size (graph.vertices, epsilon) 
	for i = 1, n do
		local S = sample (graph.vertices, k)
		avg = avg + average_distance(S)
	end
	avg = avg / n
	t = os.difftime (os.time(), t)

	return {
		filename,
		#graph.vertices,
		#graph.edges,
		epsilon,
		k,
		n,
		t,
		average_distance (graph.vertices),
		avg,
	}
end

module.write_graph = libluabag.write_graph

return module
