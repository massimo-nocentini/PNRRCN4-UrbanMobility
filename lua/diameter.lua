
-- the following script allows us to test the main algorithm over the whole file.


local function sample_size (vertices, epsilon)
	local n = #vertices
	return math.min(math.ceil (math.log (n) / (epsilon * epsilon)), n)
end

local function sample (vertices, k)

	local pool = {} for i, v in ipairs (vertices) do pool[i] = v end -- just prepare the pool

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

		local queue = {} for i, w in pairs (v.outhood) do queue[i] = {vertex = w, distance = 1} end

		while #queue > 0 do
			local meta = table.remove (queue, 1)
			local vertex = meta.vertex
			local distance = meta.distance
			if not seen[vertex] then
				seen[vertex] = distance
				local d = distance + 1
				for i, w in pairs (vertex.outhood) do table.insert (queue, {vertex = w, distance = d}) end
			end
		end

		v.bfs = seen
	end

	return v.bfs

end

local function bfs_rec (v)

	if not v.bfs then

		local seen = {} 
		seen[v] = 0

		v.bfs = seen

		for i, w in pairs (v.outhood) do 
			for r, dd in pairs (bfs (w)) do 
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

	for i, v in ipairs (S) do

		for w, d in pairs (bfs (v)) do
			sum = sum + d
			count = count + 1
		end
	end

	return sum / count
end

local function diameter_true (V)

	local d = 0

	for i, v in ipairs (V) do
		for w, dist in pairs (bfs (v)) do d = math.max(d, dist) end
	end

	return d
end

--------------------------------------------------------------------------------

local module = {}

function module.parse_graph (filename)

	local graph = { vertices = {}, edges = {} }

	local function vertex_of (id)
		local vs = graph.vertices
		if not vs[id] then 
			local v = {id = id, progressive = #vs + 1, outhood = {}, inhood = {}} -- a very simple table that represents a vertex.
			vs[v.progressive] = v -- to allow access by position
			vs[id] = v -- and by id.
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

function module.diameter (filename, graph, n, epsilon)

	local t = os.time ()
	local avg = 0.0
	local k = sample_size (graph.vertices, epsilon) 
	for i = 1, n do
		local S = sample (graph.vertices, k)
		avg = avg + diameter(S)
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
		diameter_true(graph.vertices),
		avg,
	}
end

return module
