
-- the following script allows us to test the main algorithm over the whole file.

local function parse_graph (filename)

	local graph = { vertices = {}, edges = {} }

	local function vertex_of (id)
		local vs = graph.vertices
		if not vs[id] then 
			local v = {id = id, progressive = #vs + 1, outhood = {}, inhood = {}} -- a very simple table that represents a vertex.
			vs[v.progressive] = v
			vs[id] = v
		end

		return vs[id]
	end

	for l in io.lines (filename) do
		local i = string.find (l, '\t')
		local from = vertex_of (string.sub (l, 1, i - 1))
		local to = vertex_of (string.sub (l, i + 1))
		--print (l, from.id, to.id)

		table.insert (from.outhood, to)
		table.insert (to.inhood, from)
		table.insert (graph.edges, {from, to})
	end

	return graph
end

local function sample (graph, epsilon)

	local pool = {} for id, v in pairs (graph.vertices) do pool[v.progressive] = v end -- just prepare the pool

	local k = math.ceil (math.log (#graph.vertices) / (epsilon * epsilon))

	local V = {} for j=1, k do V[j] = table.remove (pool, math.random (#pool)) end

	local S = {} -- the sample
	for i, v in pairs(V) do
		local n = #v.inhood
		if n > 0 then S[i] = v.inhood[math.random (n)] else S[i] = v end
	end

	return S

end

local function bfs (v)

	if not v.bfs then

		local seen = {} 
		seen[v] = 0

		v.bfs = seen

		for i, w in pairs (v.outhood) do 
			local B = bfs (w)
			for r, dd in pairs (B) do 
				local d = dd + 1
				if not seen[r] then seen[r] = d 
				else seen[r] = math.min (seen[r], d) end
			end
		end
	end

	return v.bfs

end

local function diameter (S)
	local sum, count, B = 0, 0, {}

	for i, v in pairs (S) do

		if not B[v] then B[v] = bfs (v) end

		for w, d in pairs (B[v]) do
			sum = sum + d
			count = count + 1
		end
	end

	return sum / count
end

--------------------------------------------------------------------------------

local graph = parse_graph (arg[1])

--print ("Loaded graph", #graph.vertices, #graph.edges)

local S = sample (graph, 0.1)

--print ("sample", #S)

print (diameter (S))
