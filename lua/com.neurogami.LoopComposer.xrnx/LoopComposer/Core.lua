-- Core.lua 
LoopComposer = {}

LoopComposer.current_line = 1 
LoopComposer.last_line = 1 
LoopComposer.current_pattern = 1 
LoopComposer.last_pattern = LoopComposer.current_pattern
LoopComposer.current_loop_count = 1
LoopComposer.current_loop = 1 
LoopComposer.timer_interval = 250 

LoopComposer.loop_list = {
  {5, 5, 1},
  {1, 2, 1},
  {5, 6, 1},
  {3, 4, 1},
  {1, 2, 2},
  {6, 6, 2},
  {3, 4, 1, "restart"},
} 



function LoopComposer.did_we_loop()
  -- This only works if the loop max is > 1
  -- We should assume that whenever a new loop is
  -- scheduled the loop count starts at 1

  -- If we are not in the last pattern of the loop then return false
  LoopComposer.current_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  if LoopComposer.current_pattern < LoopComposer.loop_list[LoopComposer.current_loop][2] then
    return false
  end
  LoopComposer.current_line = renoise.song().transport.playback_pos.line  
  if  LoopComposer.current_line < LoopComposer.last_line then
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

    local new_loop = LoopComposer.loop_list[LoopComposer.current_loop]
    LoopComposer.current_loop_count = 1
    LoopComposer.current_pattern = new_loop[1]
    LoopComposer.last_pattern = new_loop[1]

    LoopComposer.loop_schedule(new_loop[1], new_loop[2])       
  else
    print("There is no next loop.")
    LoopComposer.clear()
   end
end

function LoopComposer.clear()
    renoise.tool():remove_timer(LoopComposer.process_looping)
    LoopComposer.loop_clear()
end

function LoopComposer.process_looping()

  local range_start, range_end, count, num_loops
  local max_loops = LoopComposer.loop_list[LoopComposer.current_loop][3]
  local end_function = LoopComposer.loop_list[LoopComposer.current_loop][4]
  range_start = LoopComposer.loop_list[LoopComposer.current_loop][1]
  range_end = LoopComposer.loop_list[LoopComposer.current_loop][2]

  LoopComposer.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  print("Current pattern: ", LoopComposer.current_pattern, "; loop count = ",  LoopComposer.current_loop_count, "max loops ",  max_loops)

  if (LoopComposer.current_pattern == range_end ) then       
    print("We are in the last patter of the loop.")
    if LoopComposer.did_we_loop() then
      LoopComposer.current_loop_count = LoopComposer.current_loop_count + 1
    end

    if LoopComposer.current_loop_count >= max_loops then
      print("* * * * * Loop count >= max looping, so set next loop * * * * *")
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
  local song = renoise.song
  print("/loop/schedule! ", range_start, " ", range_end)
  song().transport:set_scheduled_sequence(clamp_value(range_start, 1, song().transport.song_length.sequence))
  local pos_start = song().transport.loop_start
  pos_start.line = 1; 
  pos_start.sequence = clamp_value(range_start, 1, song().transport.song_length.sequence)
  local pos_end = song().transport.loop_end
  pos_end.line = 1; 
  pos_end.sequence =  clamp_value(range_end + 1, 1, 
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


function LoopComposer.load_loop_table()
  load_loop_config() -- This is from Configuration.
  local raw_composition_text = string.trim(composition.text.value)
  local lines = string.lines(raw_composition_text)
  print("-------------- lo0p composition raw lines --------------")
  rPrint(lines)
  print("-------------- lo0p composition raw lines --------------")

  LoopComposer.loop_list = {}
  local _ = ""

  for i, line in pairs(lines) do
    _ = string.trim(line)
    if string.len(_) > 4  then
      table.insert(LoopComposer.loop_list, LoopComposer:pattern_line_to_loop_table(line)) 
    end
  end

  print("-------------- LoopComposer.loop_list --------------")
  rPrint(LoopComposer.loop_list)
  print("-------------- LoopComposer.loop_list --------------")
end

function LoopComposer.go() 

  LoopComposer.load_loop_table()

  LoopComposer.current_pattern = 1 
  LoopComposer.last_pattern = LoopComposer.current_pattern
  LoopComposer.current_loop_count = 1
  LoopComposer.current_loop = 1 

  LoopComposer.loop_schedule(LoopComposer.loop_list[LoopComposer.current_loop][1], LoopComposer.loop_list[LoopComposer.current_loop][2])
  renoise.tool():add_timer(LoopComposer.process_looping, LoopComposer.timer_interval)

end

return LoopComposer