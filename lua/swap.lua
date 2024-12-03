
local filename = arg[1]

for l in io.lines (filename) do
	local i = string.find (l, '\t')
	local from = string.sub (l, 1, i - 1)
	local to = string.sub (l, i + 1)

	print (to, from)
end

