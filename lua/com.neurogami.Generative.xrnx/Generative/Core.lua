-- Core.lua 
Generative = {}

Generative.current_line = 1 
Generative.last_line = 1 
Generative.current_pattern = 1 
Generative.last_pattern = Generative.current_pattern
Generative.current_loop_count = 1
Generative.current_loop = 0
Generative.timer_interval = 100 
Generative.raw_script_text = ""

Generative.previous_loop_start = 0
Generative.previous_loop_end = 0

Generative.use_current_loop_end_points = true

Generative.loop_list = {
  {5, 5, 1},
  {1, 2, 1},
  {5, 6, 1},
  {3, 4, 1},
  {1, 2, 2},
  {6, 6, 2},
  {3, 4, 1, "restart"},
} 

Generative.loop_redefined = false

function Generative.did_we_loop()
  -- This only works if the loop max is > 1
  -- We should assume that whenever a new loop is
  -- scheduled the loop count starts at 1

  -- If we are not in the last pattern of the loop then return false
  Generative.current_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  print("\n\tDid we loop? compare ", Generative.current_pattern , " < ", Generative.current_range_end() )
  if Generative.current_pattern < Generative.current_range_end() then
    print("\t\tNot in the last pattern of the loop")
    return false
  end

  Generative.current_line = renoise.song().transport.playback_pos.line  

  if Generative.current_line < Generative.last_line then
    Generative.last_line =  Generative.current_line
    return true
  else
    Generative.last_line = Generative.current_line
    return false
  end
end


function Generative.set_next_loop()
  if Generative.current_loop < #Generative.loop_list then
    print("There is a next loop. Current loop is ", Generative.current_loop )
    -- Added so that other code can refer to the loop defs for the loop currently ending
    -- even after the next loop has been set
    Generative.previous_loop_start = Generative.current_range_start()
    Generative.previous_loop_end = Generative.current_range_end()

    Generative.current_loop = Generative.current_loop + 1

    print("Go get loop at index ", Generative.current_loop );


    Generative.current_loop_count = 1
    Generative.current_pattern =  Generative.current_range_start()
    Generative.last_pattern =  Generative.current_range_start()

    Generative.loop_schedule( Generative.current_range_start(),  Generative.current_range_end())       
    Generative.loop_redefined = true
    Generative.use_current_loop_end_points = false

  else
    print("There is no next loop.")
    Generative.clear()
  end
end

function Generative.clear()
  renoise.tool():remove_timer(Generative.process_looping)
  Generative.loop_clear()
end


function Generative.current_range_end()
  -- why is 1 added?
  return Generative.loop_list[Generative.current_loop][2]+1
end


function Generative.current_range_start()
  --  U.rPrint(Generative.loop_list)
  return Generative.loop_list[Generative.current_loop][1]+1
end

-- THE TROUBLE IS HERE? ---
function Generative.process_looping()
  -- print(" playback_pos.sequence: " .. renoise.song().transport.playback_pos.sequence)
  local range_start, range_end, count, num_loops

  local actual_loop_start = renoise.song().transport.loop_start.sequence
  local actual_loop_end = renoise.song().transport.loop_end.sequence - 1 
  local max_loops = Generative.loop_list[Generative.current_loop][3]
  local end_function = Generative.loop_list[Generative.current_loop][4]

  local renoise_curent_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  Generative.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  -- print(" - - - -     here: " .. Generative.current_pattern  .. " in loop  " .. actual_loop_start .. " to " .. actual_loop_end .. " [" .. tostring(Generative.use_current_loop_end_points) .. "]" )





  --[[
  The problem: We need to know if the loop points refer to the loop we are currently following, or if
  they have been changed in preparation for leaving this loop and jumping to the next one.

  It would be ideal if we had an observable to signal when we have just started a new loop.

  The alternative: We know that the loop gets changed when we are in the last pattern of the 
  current loop and have reached max loop count.
  --]]



  if (Generative.current_pattern == Generative.current_range_start() ) then       
    Generative.loop_redefined = false
    print("\t\t\t Set Generative.use_current_loop_end_points = true")
    Generative.use_current_loop_end_points = true
  end

  if (Generative.current_pattern == Generative.current_range_end() ) then       

    print("\n\nWe are in the last pattern of the loop.")

    if Generative.did_we_loop() then
      print("\t\tWE LOOPED!")
      Generative.current_loop_count = Generative.current_loop_count + 1
    else
      print("! ! ! WE STILL HAVE NOT LOOPED")
    end


    if Generative.current_loop_count >= max_loops then

  --    print("* * * * * Loop count >= max looping, so set next loop * * * * *")
   --   print("* * * * * end_function = ", end_function, " Generative.current_loop = ", Generative.current_loop, " * * * * *")
      if end_function then
        print("Try to invoked '", end_function, "' ...")
        _G[end_function]()
      else
        Generative.set_next_loop()
        Generative.use_current_loop_end_points = false
        Generative.loop_redefined = true
      end
    else
      -- Generative.use_current_loop_end_points = true
      ---- Do nothing since we have loop counts to go
    end
  end
   local actual_loop_index = Generative.current_loop 

  if not Generative.use_current_loop_end_points then
   -- print(" = = = Use the previous  loop end points  = = = ")
    actual_loop_start = Generative.previous_loop_start
    actual_loop_end = Generative.previous_loop_end
    actual_loop_index  = actual_loop_index  - 1
  end


  -- What's the logic here?
  Generative.last_pattern = Generative.current_pattern 

  ------- Something is getting reset to zero when a new pass of the loop occurs -----
 -- We seem to start a new loop bu we have not incremented the loop count  HERE
  local lines_per_pattern = renoise.song().patterns[renoise_curent_pattern].number_of_lines
  local number_of_patterns = (actual_loop_end - actual_loop_start) + 1

  local total_lines_in_one_loop = lines_per_pattern * number_of_patterns
  local total_lines_in_complete_loop = total_lines_in_one_loop * max_loops

  local pattern_lines_so_far = (Generative.current_loop_count-1)*total_lines_in_one_loop 
  local offset_pattern_in_loop = (renoise_curent_pattern - actual_loop_start)

  local current_loop_pass_lines_so_far = offset_pattern_in_loop * lines_per_pattern

  current_loop_pass_lines_so_far = current_loop_pass_lines_so_far +  renoise.song().transport.playback_pos.line  
  print("max_loops: " .. max_loops .. "; current_loop_count: " .. Generative.current_loop_count .."; total_lines_in_complete_loop: " .. total_lines_in_complete_loop .. "; we are at " .. current_loop_pass_lines_so_far )


    -- Clue: It seems that the current_pattern is always one off. But simply decrementing the end sequence is always correct.
   if Generative.current_pattern  < actual_loop_start then
     print("*****************  Generative.current_pattern  < actual_loop_start  ********************")
   end
   
   print(   " Loop " .. actual_loop_index .." at pattern " .. Generative.current_pattern  .. " in range  " .. actual_loop_start .. " to " .. actual_loop_end .. " [" .. tostring(Generative.use_current_loop_end_points) .. "]" )

  -------
end

function Generative.loop_clear()
  local song = renoise.song
  local pos_start = song().transport.loop_start
  pos_start.line = 1; 
  pos_start.sequence = Generative.current_pattern
  local pos_end = song().transport.loop_end
  pos_end.line = 1; 
  pos_end.sequence  = Generative.current_pattern
  song().transport.loop_range = {pos_start, pos_end}
end

function Generative.loop_schedule(range_start, range_end)
  -- The main code and config should be using the 0-based indexing the user sees in the Renoise UI
  -- but the actual values are +1
  local song = renoise.song

  -- Why do this if we are passing in values? 
  -- range_start = Generative.current_range_start() 
  -- range_end = Generative.current_range_end() 

  print("/loop/schedule! ", range_start, " ", range_end)
  -- What exactly des this do, and with what?
  song().transport:set_scheduled_sequence( U.clamp_value(range_start, 1, song().transport.song_length.sequence) )

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

Sun Feb 14 20:07:27 MST 2016

New ideas for Generative:

Curently we expect

start end count
start end FUNCTION
start end count FUNCTION




--]]
function Generative:pattern_line_to_loop_table(s)
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


function Generative.load_loop_table()

  load_loop_config() -- This is from Configuration.  It grabs text from disk.

  local raw_composition_text = Generative.raw_script_text -- string.trim(composition.text.value)
  print("raw_composition_text = " .. raw_composition_text)

  local lines = string.lines(raw_composition_text)
  print("-------------- lo0p composition raw lines --------------")
  U.rPrint(lines)
  print("-------------- end lo0p composition raw lines --------------")

  Generative.loop_list = {}
  local _ = ""

  for i, line in pairs(lines) do
    _ = string.trim(line)
    if string.len(_) > 4  and not _:match('^#') then
      table.insert(Generative.loop_list, Generative:pattern_line_to_loop_table(line)) 
    end
  end

  --  Generative.loop_list = script 

  print("-------------- Generative.loop_list --------------")
  U.rPrint(Generative.loop_list)
  print("-------------- Generative.loop_list --------------")
end


function loop_trigger() 
  print("************************************************************************************ ")
  print("************************************************************************************ ")
  print("*********************************** LOOP TRIGGER *********************************** ")
  print("************************************************************************************ ")
  print("************************************************************************************ ")
end

function Generative.go() 

  pcall(Generative.unreg_timer_function)

  -- This doesn't get triggered. Why not?
  renoise.song().transport.loop_pattern_observable:add_notifier(loop_trigger)

  Generative.load_loop_table()
  Generative.current_pattern = 1 
  Generative.last_pattern = Generative.current_pattern
  Generative.current_loop_count = 1
  Generative.current_loop = 1 

  Generative.loop_schedule(Generative.current_range_start(), Generative.current_range_end())

  renoise.tool():add_timer(Generative.process_looping, Generative.timer_interval)


end

-- A function with code that might asplode,
-- so we wrapped that part and we call this function with pcall
function Generative.unreg_timer_function()
  renoise.song().transport.loop_pattern_observable:remove_notifier(loop_trigger)
  renoise.tool():remove_timer(Generative.process_looping)

end


return Generative
