


--  String stuff
--

-- *********************************************************************
function string.to_word_table(s)
  local words = {}
  for w in s:gmatch("%S+") do table.insert(words, w) end
  return words
end


-- *********************************************************************
function string.int_list_to_numeric(s)
  local ints = {}
  for w in s:gmatch("%S+") do table.insert( ints, tonumber(w) ) end
  return ints
end



function string.lpad(str, len, char)
  if char == nil then char = ' ' end
  return str .. string.rep(char, len - #str)
end

function string.trim(s)
  if s == nil then
    return "" -- Is this a good idea?  TODO Think if silently converting nil to an empty string is a Good Thing
  else
    return (s:gsub("^%s*(.-)%s*$", "%1"))
  end
end

function string.lines(s)
  local t = {}
  local function add(line) table.insert(t, line) return "" end
  add((s:gsub("(.-)\r?\n", add)))
  return t
end


function string:words(str)
  if str == nil then
    print("string:words(str) has been given a nil value.")
    return nil
  end

  print(str)

  local s = string.trim(str)
  print("string:words has '" .. s .. "'" )
  local t = {}
  for w in s:gmatch("%S+") do
    table.insert(t, w)
  end
  return t
end


function string:segs(str)
  if str == nil then
    print("string:segments(str) has been given a nil value.")
    return nil
  end

  print(str)

  local s = string.trim(str)
  print("string:segments has '" .. s .. "'" )
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

-- Other stuff
U = {}


PATH_SEP = "/"
if (os.platform() == "WINDOWS") then
  PATH_SEP = "\\"
end




--- Common util funcitons

-- From https://stackoverflow.com/questions/22185684/how-to-shift-all-elements-in-a-table
function U.wrap( t, l )
  for i = 1, l do
    table.insert( t, 1, table.remove( t, #t ) )
  end
  return t
end



-- *********************************************************************
function U.i2hex(i)
  return string.format("%02x", i)
end


function U.clamp_value(value, min_value, max_value)
  return math.min(max_value, math.max(value, min_value))
end


--[[ rPrint(struct, [limit], [indent])   Recursively print arbitrary data. 
Set limit (default 100) to stanch infinite loops.
Indents tables as [KEY] VALUE, nested tables as [KEY] [KEY]...[KEY] VALUE
Set indent ("") to prefix each line:    Mytable [KEY] [KEY]...[KEY] VALUE
--]]
function U.rPrint(s, l, i) -- recursive Print (structure, limit, indent)
  l = (l) or 100; i = i or "";	-- default item limit, indent string
  if (l<1) then print "ERROR: Item limit reached."; return l-1 end;
  local ts = type(s);
  if (ts ~= "table") then print (i,ts,s); return l-1 end
  print (i,ts);           -- print "table"
  for k,v in pairs(s) do  -- print "[KEY] VALUE"
    l = U.rPrint(v, l, i.."\t["..tostring(k).."]");
    if (l < 0) then break end
  end
  return l
end	

-- http://lua-users.org/wiki/SleepFunction
local clock = os.clock
function U.sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end



function U.base_file_name()
  local fname = renoise.song().file_name
  local parts = string.split(fname, PATH_SEP )
  local xname = parts[#parts]
  return xname
end


-- Taken from the CreateTool tool.
-- Why does Renoise Lua not have os.copyfile?

ERROR = {OK=1, FATAL=2, USER=3}

-- Reads entire file into a string
-- (this function is binary safe)
function U.file_get_contents(file_path)
  local mode = "rb"  
  local file_ref,err = io.open(file_path, mode)
  if not err then
    local data=file_ref:read("*all")        
    io.close(file_ref)    
    return data
  else
    return nil,err;
  end
end

-- Writes a string to a file
-- (this function is binary safe)
function U.file_put_contents(file_path, data)
  local mode = "w+b" -- all previous data is erased
  local file_ref,err = io.open(file_path, mode)
  if not err then
    local ok=file_ref:write(data)
    io.flush(file_ref)
    io.close(file_ref)    
    -- print("file_ref returned ", ok ) -- DEBUG
    return ok
  else
    return nil,err;
  end
end


-- Copies the contents of one file into another file.
function U.copy_file_to(source, target)      
  local error = nil
  local code = ERROR.OK
  local ok = nil
  local err = true

  if (not io.exists(source)) then    
    error = "The source file\n\n" .. source .. "\n\ndoes not exist"
    code = ERROR.FATAL
  end
  if (not error and U.may_overwrite(target)) then
    local source_data = U.file_get_contents(source, true)    
    ok,err = U.file_put_contents(target, source_data)        
    error = err          
    -- print("file_put_contents returned ok = ", ok )
  else 
    print("There was an error: ", error )
    code = ERROR.USER
  end
  return ok, error, code
end


-- *********************************************************************
function U.is_empty_string(str)
  local _s = string.trim(str)
  return _s == ''
end


function U.is_empty(s)
  return s == nil or s == ''
end


-- If file exists, popup a modal dialog asking permission to overwrite.
function U.may_overwrite(path)
  local overwrite = true
  if (io.exists(path) ) then
    local buttons = {"Overwrite", "Keep existing file"}
    local choice = renoise.app():show_prompt("File exists", "The file\n\n " ..path .. " \n\n"
    .. "already exists. Overwrite existing file?", buttons)

    overwrite = (choice~=buttons[2])
  end  
  return overwrite
end


-- *********************************************************************
-- Split string into array (split at newline)
-- TODO decide on one util/helper function to do this. This one or string.lines(s)
function U.lines(str)
  local t = {}
  local function helper(line)
    table.insert(t, line)
    return ""
  end
  helper((str:gsub("(.-)\r?\n", helper))) 
  return t  
end


-- *********************************************************************
-- If file exists, popup a modal dialog asking permission to overwrite.
function U.error_message(message)
  local buttons = {"OK"}
  renoise.app():show_prompt(message, buttons)
end

-- *********************************************************************
function U.str_table_to_int(t)
  for k,s in pairs(t) do 
    t[k] = tonumber(s)
  end
end


-- Renoise stuff
--



function U.master_track_index()
  local master_idx = 0
  for i=1, #renoise.song().tracks do
    if renoise.song().tracks[i].type == renoise.Track.TRACK_TYPE_MASTER then
      master_idx = i
    end
  end
  return master_idx
end


-- *********************************************************************
function U.copy_device_chain(src_track, target_track)

  --rprint (song.tracks[ sti ].available_devices)
  local device_path

  -- This seems to do OK to copy devices but not device settings
  for dev = 1, #src_track.devices do
    device_path = src_track:device( dev ).device_path
    if ( dev > 1 ) then
      target_track:insert_device_at( device_path, dev )
    end

    target_track.devices[ dev ].active_preset_data = src_track.devices[ dev ].active_preset_data
    target_track.devices[ dev ].is_active = src_track.devices[ dev ].is_active
    target_track.devices[ dev ].active_preset = src_track.devices[ dev ].active_preset
    target_track.devices[ dev ].active_preset_data = src_track.devices[ dev ].active_preset_data

  end
end

-- *********************************************************************
function U.clone_pattern_track_to_end(src_pattern_index, src_track_index)
  print( "U.clone_pattern_track_to_end(" .. src_pattern_index .. ", "  ..  src_track_index .. ")" )

  local src_pattern_track   = renoise.song().patterns[src_pattern_index].tracks[src_track_index]
  local last_seq_pos = #renoise.song().sequencer.pattern_sequence + 1
  local new_pattern_index = renoise.song().sequencer:insert_new_pattern_at(last_seq_pos)  --  -> [number, new pattern index]
  renoise.song().patterns[new_pattern_index]:copy_from(renoise.song().patterns[src_pattern_index])

  local mti = U.master_track_index()

  for ti=1, mti-1 do
    if ti ~= src_track_index then
      renoise.song().patterns[new_pattern_index].tracks[ti]:clear()
    end
  end

  return(new_pattern_index)
end



-- *********************************************************************
function U.clone_track(track_number, new_track_index)

  local new_track = renoise.song():insert_track_at(new_track_index ) 
  local src_track = renoise.song():track(track_number) 

  -- Iterate over all patterns in song
  for _p =1, #renoise.song().sequencer.pattern_sequence do
    renoise.song().patterns[_p].tracks[new_track_index]:copy_from( renoise.song().patterns[_p].tracks[track_number])
  end

  -- expose the note columns:
  new_track.visible_note_columns  = src_track.visible_note_columns

  -- Also need to copy over devices 
  U.copy_device_chain(src_track, new_track)
  new_track.name = src_track.name

end

-- **********************************************************************

return U
