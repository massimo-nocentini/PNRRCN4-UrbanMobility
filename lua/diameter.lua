
-- the following script allows us to test the main algorithm over the whole file.

local function parse_graph (filename)

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

local function sample (vertices, epsilon)

	local pool = {} for i, v in ipairs (vertices) do pool[i] = v end -- just prepare the pool

	local k = math.ceil (math.log (#vertices) / (epsilon * epsilon))
	k = math.min(math.max(k, 5), #pool)

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

local filename = arg[1]
local n = arg[2] or 1
local epsilon = arg[3] or 0.1

local graph = parse_graph (filename)

local avg = 0.0
local nS = 0
for i = 1, n do
	local S = sample (graph.vertices, epsilon)
	nS = nS + #S
	avg = avg + diameter(S)
end
avg = avg / n
nS = nS / n

print (filename, #graph.vertices, #graph.edges, nS, diameter_true(graph.vertices), avg)
