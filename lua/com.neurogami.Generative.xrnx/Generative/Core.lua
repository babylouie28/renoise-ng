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
  Generative.current_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence] - 1

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
    Generative.previous_loop_start = Generative.current_range_start()
    Generative.previous_loop_end = Generative.current_range_end()
    Generative.current_loop = Generative.current_loop + 1
    print("Go get loop at index ", Generative.current_loop );
    Generative.current_pattern =  Generative.current_range_start()
    Generative.last_pattern =  Generative.current_range_start()

    Generative.loop_schedule( Generative.current_range_start(),  Generative.current_range_end())       
    Generative.loop_redefined = true
    Generative.use_current_loop_end_points = false -- OK

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
  return Generative.loop_list[Generative.current_loop][2] 
end


function Generative.current_range_start()
  --  U.rPrint(Generative.loop_list)
  return Generative.loop_list[Generative.current_loop][1]
end

-- THE TROUBLE IS HERE? ---
function Generative.process_looping()

  local pattern_pos_line = renoise.song().transport.playback_pos.line  
  local actual_loop_start = renoise.song().transport.loop_start.sequence - 1 
  local actual_loop_end = renoise.song().transport.loop_end.sequence - 2 -- ?? Why? 
  local max_loops = Generative.loop_list[Generative.current_loop][3]
  local end_function = Generative.loop_list[Generative.current_loop][4]
  local current_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence] - 1

  local renoise_curent_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence] - 1
  Generative.current_pattern = current_pattern 

  if (current_pattern  == Generative.current_range_start() ) then       
    Generative.loop_redefined = false
     print("\t\t\t Set Generative.use_current_loop_end_points = true")
    Generative.use_current_loop_end_points = true
  end
  
  
  if (current_pattern == Generative.current_range_end() ) then       
    print("\n\nWe are in the last pattern of the loop, " .. current_pattern)
    if Generative.did_we_loop() then
      print("\t\tWE LOOPED!")
      Generative.current_loop_count = Generative.current_loop_count + 1
      Generative.use_current_loop_end_points = true  -- OK
    else
      print("! ! ! WE STILL HAVE NOT LOOPED")
    end

    if Generative.current_loop_count >= max_loops then
      if end_function then
        print("Try to invoked '", end_function, "' ...")
        _G[end_function]()
      else
        Generative.set_next_loop()
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
    actual_loop_index  = actual_loop_index - 1
    max_loops = Generative.loop_list[actual_loop_index][3]
  end

   print(" - - - -     here: " .. current_pattern  .. " in loop  " .. actual_loop_start .. " to " .. actual_loop_end .. " [" .. tostring(Generative.use_current_loop_end_points) .. "] Generative.current_range_end() = " .. Generative.current_range_end() )

  -- What's the logic here?
  Generative.last_pattern = current_pattern

  --[[
  Why is this so fucking hard?

  We need to know: 
    Lines in each pattern
    Index of currently executing loop
    Number of patterns in this loop
    max_loops for this loop
    How many COMPLETE passes have we made so far
    How many patterns in the current partial loop have we COMPLETED
    On what line in the CURRENT PATTERN are we?

  --]]

  local lines_per_pattern = renoise.song().patterns[renoise_curent_pattern+1].number_of_lines
  local number_of_patterns = (actual_loop_end - actual_loop_start) + 1
  local total_lines_in_one_loop = lines_per_pattern * number_of_patterns
  local total_lines_in_complete_loop = total_lines_in_one_loop * max_loops
  print("\n\t * number_of_patterns = " .. number_of_patterns .. "; total_lines_in_one_loop * max_loops = " .. total_lines_in_one_loop .. " * " .. max_loops .. " = " .. total_lines_in_complete_loop )

  -- what is this suposed to be? 
  -- The number of lines from COMPLETED loops, so far
  -- Note that as soon as we enter a loop the count is incremented.
  -- That is, on the first pass, as we begin, loop count is alread 1
  -- So we want to decrement by one since the COMPLETED loops is going to be one less
  local completed_loop_lines_so_far = (Generative.current_loop_count-1)*total_lines_in_one_loop  
  
  -- This should tell use how many patterns in the current loop have passed.
  -- It should be 0-based. That is, if we are in pattern 1 of loop 0-3 then the offset should be 1
  -- 
  local offset_pattern_in_loop = (renoise_curent_pattern - actual_loop_start)
  print("\t * offset_pattern_in_loop = (renoise_curent_pattern - actual_loop_start) " .. offset_pattern_in_loop .. " = ( " .. renoise_curent_pattern .. " - " ..  actual_loop_start .. ")" )

  -- What is current_loop_pass_lines_so_far ? The number of *completed* pattern lines  in the current pass of the loop.
  local current_loop_pass_lines_so_far = completed_loop_lines_so_far + (offset_pattern_in_loop) * lines_per_pattern
  print("\t * 1. current_loop_pass_lines_so_far : " .. current_loop_pass_lines_so_far .. "; offset_pattern_in_loop * lines_per_pattern : " .. offset_pattern_in_loop .. " * " ..  lines_per_pattern)

  -- We now add our current-pattern line number to current_loop_pass_lines_so_far 
  current_loop_pass_lines_so_far = current_loop_pass_lines_so_far + pattern_pos_line
  print("\t * max_loops: " .. max_loops .. "; current_loop_count: " .. Generative.current_loop_count .."; total_lines_in_complete_loop: " .. total_lines_in_complete_loop .. "; we are at current_loop_pass_lines_so_far:" .. current_loop_pass_lines_so_far )

   
  print(" Loop #" .. actual_loop_index .." at pattern " .. current_pattern .. " in range  " .. actual_loop_start .. " to " .. actual_loop_end .. " [" .. tostring(Generative.use_current_loop_end_points) .. "] at line " .. pattern_pos_line )
  print("----------------------- end ---------------------------------------------------------\n")

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
  -- The main code and confg should be using the 0-based indexing the user sees in the Renoise UI
  -- but the actual values are +1
  local song = renoise.song
 
  print("/loop/schedule! ", range_start, " ", range_end)

  range_start = range_start + 1
  range_end =  range_end + 1

  song().transport:set_scheduled_sequence(U.clamp_value(range_start, 1, song().transport.song_length.sequence))
  local pos_start = song().transport.loop_start
  pos_start.line = 1; 
  pos_start.sequence = U.clamp_value(range_start, 1, song().transport.song_length.sequence)
  local pos_end = song().transport.loop_end
  pos_end.line = 1; 
  pos_end.sequence =  U.clamp_value(range_end + 1, 1, 
  song().transport.song_length.sequence + 1)
  song().transport.loop_range = {pos_start, pos_end}

  print("Just scheduled loop. renoise.song().transport.loop_end.sequence  = " .. renoise.song().transport.loop_end.sequence )
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
  -- It gets triggered when you click on the curved-arrow button, the thing
  -- for repeating the current pattern.
  --
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
