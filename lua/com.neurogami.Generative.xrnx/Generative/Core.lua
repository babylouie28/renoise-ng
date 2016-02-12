-- Core.lua 
Generative = {}

Generative.current_line = 1 
Generative.last_line = 1 
Generative.current_pattern = 1 
Generative.last_pattern = Generative.current_pattern
Generative.current_loop_count = 1
Generative.current_loop = 0
Generative.timer_interval = 100 

Generative.loop_list = {
  {5, 5, 1},
  {1, 2, 1},
  {5, 6, 1},
  {3, 4, 1},
  {1, 2, 2},
  {6, 6, 2},
  {3, 4, 1, "restart"},
} 


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
    Generative.last_line =  Generative.current_line
    return false
  end
end


function Generative.set_next_loop()
  if Generative.current_loop < #Generative.loop_list then
    print("There is a next loop. Current loop is ", Generative.current_loop )
    Generative.current_loop = Generative.current_loop + 1

    print("Go get loop at index ", Generative.current_loop );

    Generative.current_loop_count = 1
    Generative.current_pattern =  Generative.current_range_start()
    Generative.last_pattern =  Generative.current_range_start()

    Generative.loop_schedule( Generative.current_range_start(),  Generative.current_range_end())       
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
  return Generative.loop_list[Generative.current_loop][2]+1
end


function Generative.current_range_start()
  return Generative.loop_list[Generative.current_loop][1]+1
end

function Generative.process_looping()

  local range_start, range_end, count, num_loops
  local max_loops = Generative.loop_list[Generative.current_loop][3]
  local end_function = Generative.loop_list[Generative.current_loop][4]
  range_start = Generative.current_range_start()
  range_end = Generative.current_range_end()

  Generative.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  print("Current pattern: ", Generative.current_pattern, "; loop count = ",  Generative.current_loop_count, "max loops ",  max_loops)

  if (Generative.current_pattern == range_end ) then       
    
    print("We are in the last pattern of the loop.")

    if Generative.did_we_loop() then
      print("\t\tWE LOOPED!")
      Generative.current_loop_count = Generative.current_loop_count + 1
    else
        print("! ! ! WE STILL HAVE NOT LOOPED")
    end

    if Generative.current_loop_count >= max_loops then
      print("* * * * * Loop count >= max looping, so set next loop * * * * *")
      print("* * * * * end_function = ", end_function, " Generative.current_loop = ", Generative.current_loop, " * * * * *")
      if end_function then
        print("Try to invoked '", end_function, "' ...")
        _G[end_function]()
      else
        Generative.set_next_loop()
      end
    else
      ---- Do nothing since we have loop counts to go
    end
  end

  Generative.last_pattern = Generative.current_pattern 

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
  
  range_start = Generative.current_range_start() 
  range_end = Generative.current_range_end() 

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
  load_loop_config() -- This is from Configuration.
  local raw_composition_text = string.trim(composition.text.value)

  local lines = string.lines(raw_composition_text)
  print("-------------- lo0p composition raw lines --------------")
  U.rPrint(lines)
  print("-------------- lo0p composition raw lines --------------")

  Generative.loop_list = {}
  local _ = ""

  for i, line in pairs(lines) do
    _ = string.trim(line)
    if string.len(_) > 4  and not _:match('^#') then
      table.insert(Generative.loop_list, Generative:pattern_line_to_loop_table(line)) 
    end
  end

  print("-------------- Generative.loop_list --------------")
  U.rPrint(Generative.loop_list)
  print("-------------- Generative.loop_list --------------")
end

function Generative.go() 

  Generative.load_loop_table()

  Generative.current_pattern = 1 
  Generative.last_pattern = Generative.current_pattern
  Generative.current_loop_count = 1
  Generative.current_loop = 1 

  Generative.loop_schedule(Generative.current_range_start(), Generative.current_range_end())
  renoise.tool():add_timer(Generative.process_looping, Generative.timer_interval)

end

return Generative
