--- Common util funcitons
function clamp_value(value, min_value, max_value)
    return math.min(max_value, math.max(value, min_value))
  end


 --[[ rPrint(struct, [limit], [indent])   Recursively print arbitrary data. 
	Set limit (default 100) to stanch infinite loops.
	Indents tables as [KEY] VALUE, nested tables as [KEY] [KEY]...[KEY] VALUE
	Set indent ("") to prefix each line:    Mytable [KEY] [KEY]...[KEY] VALUE
--]]
 function rPrint(s, l, i) -- recursive Print (structure, limit, indent)
	l = (l) or 100; i = i or "";	-- default item limit, indent string
	if (l<1) then print "ERROR: Item limit reached."; return l-1 end;
	local ts = type(s);
	if (ts ~= "table") then print (i,ts,s); return l-1 end
	print (i,ts);           -- print "table"
	for k,v in pairs(s) do  -- print "[KEY] VALUE"
		l = rPrint(v, l, i.."\t["..tostring(k).."]");
		if (l < 0) then break end
	end
	return l
end	


function base_file_name()
  local fname = renoise.song().file_name
  local parts = string.split(fname, "/")
  local xname = parts[#parts]
  return xname
end

string.lpad = function(str, len, char)
  if char == nil then char = ' ' end
  return str .. string.rep(char, len - #str)
end


function string.trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function string.lines(s)
  local t = {}
  local function add(line) table.insert(t, line) return "" end
  add((s:gsub("(.-)\r?\n", add)))
  return t
end


function string:words(s)
  local t = {}
   for w in s:gmatch("%S+") do
      table.insert(t, w)
   end
  return t
end

function string:words(s)
  local t = {}
   for w in s:gmatch("%S+") do
      table.insert(t, w)
   end
  return t
end


-- https://helloacm.com/split-a-string-in-lua/
function string.split(s, delimiter)
    local result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end
