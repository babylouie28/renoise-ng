-- Core.lua 
LoopComposer = {}

LoopComposer.current_line = 1 
LoopComposer.last_line = 1 
LoopComposer.current_pattern = 1 
LoopComposer.last_pattern = LoopComposer.current_pattern
LoopComposer.current_loop_count = 1
LoopComposer.current_loop = 0
LoopComposer.timer_interval = 100 

LoopComposer.loop_list = {
  {5, 5, 1},
  {1, 2, 1},
  {5, 6, 1},
  {3, 4, 1},
  {1, 2, 2},
  {6, 6, 2},
  {3, 4, 1, "restart"},
} 


function LoopComposer.read_script_from_comments()
print("SEE IF WE CAN READ ALL THE LINES OF THE COMMENTS ...")

  local script_lines = {}
  local script_text = ""
  local comments = renoise.song().comments
 
  for idx, line in ipairs(comments) do
    print(line)
     local _ = string.trim(line)
     -- Not sure if this is useful, but allow the option 
     -- to ignore comment lines that begin with a semicolon.
    if (not _:match('^;') ) then
      table.insert(script_lines, line )
    end
    script_text = table.concat(script_lines,"\n")
  end

  return script_text
end

function LoopComposer.read_script_from_track()
  print("SEE IF WE CAN READ ALL THE LINES OF A TRACK ...")

  -- Need to:
  -- Find a track named LC_SCRIPT

  local song = renoise.song()
  local script_track = nil
  local script_track_index = 0
  local tracks = song.tracks

  for idx, tr in ipairs(tracks) do
    print(idx, tr.name) 
    if (tr.name == "LC_SCRIPT") then
      script_track = tr
      script_track_index = idx
    end
  end

  if (script_track ~= nil) then
    print("We found the script track")
    local lines = song.patterns[1].tracks[script_track_index].lines

    for idx, l in ipairs(lines) do
      print(idx, l.note_columns[1].note_string) 
    end


  end

end


function LoopComposer.did_we_loop()
  -- This only works if the loop max is > 1
  -- We should assume that whenever a new loop is
  -- scheduled the loop count starts at 1

  -- If we are not in the last pattern of the loop then return false
  LoopComposer.current_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  print("\n\tDid we loop? compare ", LoopComposer.current_pattern , " < ", LoopComposer.current_range_end() )
  if LoopComposer.current_pattern < LoopComposer.current_range_end() then
    print("\t\tNot in the last pattern of the loop")
    return false
  end

  LoopComposer.current_line = renoise.song().transport.playback_pos.line  


  if LoopComposer.current_line < LoopComposer.last_line then
    LoopComposer.last_line =  LoopComposer.current_line
    return true
  else
    LoopComposer.last_line =  LoopComposer.current_line
    return false
  end
end


function LoopComposer.set_next_loop()
  if LoopComposer.current_loop < #LoopComposer.loop_list then
    print("There is a next loop. Current loop is ", LoopComposer.current_loop )
    LoopComposer.current_loop = LoopComposer.current_loop + 1

    print("Go get loop at index ", LoopComposer.current_loop );

    LoopComposer.current_loop_count = 1
    LoopComposer.current_pattern =  LoopComposer.current_range_start()
    LoopComposer.last_pattern =  LoopComposer.current_range_start()

    LoopComposer.loop_schedule( LoopComposer.current_range_start(),  LoopComposer.current_range_end())       
  else
    print("There is no next loop.")
    LoopComposer.clear()
  end
end

function LoopComposer.clear()
  renoise.tool():remove_timer(LoopComposer.process_looping)
  LoopComposer.loop_clear()
end


function LoopComposer.current_range_end()
  return LoopComposer.loop_list[LoopComposer.current_loop][2]+1
end


function LoopComposer.current_range_start()
  return LoopComposer.loop_list[LoopComposer.current_loop][1]+1
end

function LoopComposer.process_looping()

  local range_start, range_end, count, num_loops
  local max_loops = LoopComposer.loop_list[LoopComposer.current_loop][3]
  local end_function = LoopComposer.loop_list[LoopComposer.current_loop][4]
  range_start = LoopComposer.current_range_start()
  range_end = LoopComposer.current_range_end()

  LoopComposer.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  print("Current pattern: ", LoopComposer.current_pattern, "; loop count = ",  LoopComposer.current_loop_count, "max loops ",  max_loops)

  if (LoopComposer.current_pattern == range_end ) then       

    print("We are in the last pattern of the loop.")

    if LoopComposer.did_we_loop() then
      print("\t\tWE LOOPED!")
      LoopComposer.current_loop_count = LoopComposer.current_loop_count + 1
    else
      print("! ! ! WE STILL HAVE NOT LOOPED")
    end

    if LoopComposer.current_loop_count >= max_loops then
      print("* * * * * Loop count >= max looping, so set next loop * * * * *")
      print("* * * * * end_function = ", end_function, " LoopComposer.current_loop = ", LoopComposer.current_loop, " * * * * *")
      if end_function then
        print("Try to invoked '", end_function, "' ...")
        _G[end_function]()
      else
        LoopComposer.set_next_loop()
      end
    else
      ---- Do nothing since we have loop counts to go
    end
  end

  LoopComposer.last_pattern = LoopComposer.current_pattern 

end

function LoopComposer.loop_clear()
  local song = renoise.song
  local pos_start = song().transport.loop_start
  pos_start.line = 1; 
  pos_start.sequence = LoopComposer.current_pattern
  local pos_end = song().transport.loop_end
  pos_end.line = 1; 
  pos_end.sequence  = LoopComposer.current_pattern
  song().transport.loop_range = {pos_start, pos_end}
end

function LoopComposer.loop_schedule(range_start, range_end)
  -- The main code and confg should be using the 0-based indexing the user sees in the Renoise UI
  -- but the actual values are +1
  local song = renoise.song

  range_start = LoopComposer.current_range_start() 
  range_end = LoopComposer.current_range_end() 

  print("/loop/schedule! ", range_start, " ", range_end)
  song().transport:set_scheduled_sequence(U.clamp_value(range_start, 1, song().transport.song_length.sequence))
  local pos_start = song().transport.loop_start
  pos_start.line = 1; 
  pos_start.sequence = U.clamp_value(range_start, 1, song().transport.song_length.sequence)
  local pos_end = song().transport.loop_end
  pos_end.line = 1; 
  pos_end.sequence =  U.clamp_value(range_end + 1, 1, 
  song().transport.song_length.sequence + 1)
  song().transport.loop_range = {pos_start, pos_end}
end

--[[ 

New plan:

A loop row must start with 2 numbers that define the loop range
The next item can be a number or a string
if a number it is the number of times to run the loop
  if a string it is a function to execute after the loop has run.

    If the third item is a number then there can be a fourth item,
    a string. This will be a function name.

    To make things easier we can require that there always be a loop
    number; this makes it easier to parse for the optional function
    name.  

    --]]
    function LoopComposer:pattern_line_to_loop_table(s)
      local t = {}
      local count = 1

      for w in s:gmatch("%S+") do
        if count < 4 then
          table.insert(t, tonumber(w))
        else
          table.insert(t, w)
        end
        count = count + 1
      end

      return t
    end

    function LoopComposer.load_loop_table_from_text(text)

      local lines = string.lines(text)

      print("-------------- loop composition raw lines --------------")
      U.rPrint(lines)
      print("-------------- loop composition raw lines --------------")


      LoopComposer.loop_list = {}
      local _ = ""

      for i, line in pairs(lines) do
        _ = string.trim(line)
        if string.len(_) > 4  and not _:match('^#') then
          table.insert(LoopComposer.loop_list, LoopComposer:pattern_line_to_loop_table(line)) 
        end
      end

      print("-------------- LoopComposer.loop_list --------------")
      U.rPrint(LoopComposer.loop_list)
      print("-------------- LoopComposer.loop_list --------------")
    end

    function LoopComposer.load_loop_table()
      load_loop_config() -- This is from Configuration.
      local raw_composition_text = string.trim(composition.text.value)
      LoopComposer.load_loop_table_from_text(raw_composition_text)
    end

    function LoopComposer.go() 
-- We have the option of storing the script in comments.
-- How do we handle this?
-- Currently, there is a menu option to compose a script.
--Is there anything that autoloads from disk?
-- Yes: load_loop_config() is called when you open that
-- compostion thing. 
-- If there is  ascript in the comments should that get auto-loaded?
-- Idea:  'go' should check to see if there is a comment script
-- If so, it gets loaed and executed
-- If not, then it looks to see if there is an existing script loaded.
-- If so, run it. If not, ope the composer window, auto-loadng any
-- existing script file.
-- Or just look for a script file and run that right away.
--

      local comment_script = LoopComposer.read_script_from_comments()
      if not U.is_empty(comment_script) then
         LoopComposer.load_loop_table_from_text(comment_script)
      else
        LoopComposer.load_loop_table()
      end

      LoopComposer.current_pattern = 1 
      LoopComposer.last_pattern = LoopComposer.current_pattern
      LoopComposer.current_loop_count = 1
      LoopComposer.current_loop = 1 

      LoopComposer.loop_schedule(LoopComposer.current_range_start(), LoopComposer.current_range_end())
      renoise.tool():add_timer(LoopComposer.process_looping, LoopComposer.timer_interval)

    end

    return LoopComposer
