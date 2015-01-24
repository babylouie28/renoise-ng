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
  {3, 4, 1},
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


-- We never use this. What was the intention?
function LoopComposer.are_we_in_this_loop(loop_index) 
  local pos_start = song().transport.loop_start
  local pos_end = song().transport.loop_end

  local range_start = LoopComposer.loop_list[loop_index][1]
  local range_end = LoopComposer.loop_list[loop_index][2]

  if (pos_start  == range_start ) and (pos_end == range_end ) then
    return true
  else
    return false
  end
end


-- We never use this. What was the intention?
function LoopComposer.are_we_at_the_end_of_loop_count()
  -- Find the current pattern
  -- See if it the same as the last pattern for loop
  -- See if we are near the end of the pattern
  -- See if the loop count is at the max
  -- If so, return true

  local song_pos_line = renoise.song().transport.playback_pos.line
  local pattern_num_lines = renoise.song().patterns[LoopComposer.current_pattern].number_of_lines
  print("Current line: ", song_pos_line , " of max ", pattern_num_lines )

  -- song_pos.line
end

function set_next_loop()
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
    print("There is no next loop. Now what?")
    -- Clear all schedulated loops and let the song play out.
    renoise.tool():remove_timer(process_looping)
    LoopComposer.loop_clear()
  end
end

--[[


NOTE: THE ASSUMPTION IS THAT ALL LOOP ARE MORE THAN ONE PATTERN LONG.


This function needs a way to know when it is approaching the end of
a loop.

We know the first and last loop pattern numbers.  The timer needs to track current
pattern and last pattern.  When they differ, and the current pattern is the end
pattern of the loop, then we know we have (or are about to) complete a loop. So, up
the loop count.

If the current loop count equals the max loop number then it's time to schedule a new loop.

We need something to track that this transistion is going to occur so that the current pattern
tracking stuff isn't confused.


Posible states:

The start, in loop N 
In loop N, and not at the last pattern
In loop N, and at the last pattern, but not at the last loop count
In loop N, and at the last pattern, and at the last loop count
Just moved from loop N to N+1


--]]
function process_looping()

  local range_start, range_end, count, num_loops
  local max_loops = LoopComposer.loop_list[LoopComposer.current_loop][3]
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
        set_next_loop()
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


function LoopComposer:ppatern_line_to_number_table(s)
  local t = {}
   for w in s:gmatch("%S+") do
      table.insert(t, tonumber(w))
   end
  return t
end


function LoopComposer.load_loop_table()
  load_loop_config()
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
    table.insert(LoopComposer.loop_list, LoopComposer:ppatern_line_to_number_table(line)) 
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
  renoise.tool():add_timer(process_looping, LoopComposer.timer_interval)

end

return LoopComposer
