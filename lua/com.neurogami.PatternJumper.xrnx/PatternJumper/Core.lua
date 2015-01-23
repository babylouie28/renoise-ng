-- Core.lua 
PatternJumper = {}

PatternJumper.current_line = 1 
PatternJumper.last_line = 1 
PatternJumper.current_pattern = 1 
PatternJumper.last_pattern = PatternJumper.current_pattern
PatternJumper.current_loop_count = 1
PatternJumper.current_loop = 1 
PatternJumper.timer_interval = 250 

PatternJumper.loop_list = {
  {5, 5, 1},
  {1, 2, 1},
  {5, 6, 1},
  {3, 4, 1},
  {1, 2, 2},
  {6, 6, 2},
  {3, 4, 1},
} 

function PatternJumper.did_we_loop()
  -- This only works if the loop max is > 1
  -- We should assume that whenever a new loop is
  -- scheduled the loop count starts at 1

  -- If we are not in the last pattern of the loop then return false
  PatternJumper.current_pattern = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  if PatternJumper.current_pattern < PatternJumper.loop_list[PatternJumper.current_loop][2] then
    return false
  end
  PatternJumper.current_line = renoise.song().transport.playback_pos.line  
  if  PatternJumper.current_line < PatternJumper.last_line then
    PatternJumper.last_line =  PatternJumper.current_line
    return true
  else
    PatternJumper.last_line =  PatternJumper.current_line
    return false
  end
end


-- We never use this. What was the intention?
function PatternJumper.are_we_in_this_loop(loop_index) 
  local pos_start = song().transport.loop_start
  local pos_end = song().transport.loop_end

  local range_start = PatternJumper.loop_list[loop_index][1]
  local range_end = PatternJumper.loop_list[loop_index][2]

  if (pos_start  == range_start ) and (pos_end == range_end ) then
    return true
  else
    return false
  end
end


-- We never use this. What was the intention?
function PatternJumper.are_we_at_the_end_of_loop_count()
  -- Find the current pattern
  -- See if it the same as the last pattern for loop
  -- See if we are near the end of the pattern
  -- See if the loop count is at the max
  -- If so, return true

  local song_pos_line = renoise.song().transport.playback_pos.line
  local pattern_num_lines = renoise.song().patterns[PatternJumper.current_pattern].number_of_lines
  print("Current line: ", song_pos_line , " of max ", pattern_num_lines )

  -- song_pos.line
end

function set_next_loop()
  if PatternJumper.current_loop < #PatternJumper.loop_list then
    print("There is a next loop. Current loop is ", PatternJumper.current_loop )
    PatternJumper.current_loop = PatternJumper.current_loop + 1


    print("Go get loop at index ", PatternJumper.current_loop );

    local new_loop = PatternJumper.loop_list[PatternJumper.current_loop]
    PatternJumper.current_loop_count = 1
    PatternJumper.current_pattern = new_loop[1]
    PatternJumper.last_pattern = new_loop[1]

    PatternJumper.loop_schedule(new_loop[1], new_loop[2])       
  else
    print("There is no next loop. Now what?")
    -- Clear all schedulated loops and let the song play out.
    renoise.tool():remove_timer(process_looping)
    PatternJumper.loop_clear()
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
  local max_loops = PatternJumper.loop_list[PatternJumper.current_loop][3]
  range_start = PatternJumper.loop_list[PatternJumper.current_loop][1]
  range_end = PatternJumper.loop_list[PatternJumper.current_loop][2]


  PatternJumper.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  print("Current pattern: ", PatternJumper.current_pattern, "; loop count = ",  PatternJumper.current_loop_count, "max loops ",  max_loops)

    if (PatternJumper.current_pattern == range_end ) then       
      print("We are in the last patter of the loop.")
       if PatternJumper.did_we_loop() then
        PatternJumper.current_loop_count = PatternJumper.current_loop_count + 1
      end

      if PatternJumper.current_loop_count >= max_loops then
        print("* * * * * Loop count >= max looping, so set next loop * * * * *")
        set_next_loop()
      else

        ---- Do nothing since we have loop counts to go
      end
    end


  
  PatternJumper.last_pattern = PatternJumper.current_pattern 

end

function PatternJumper.loop_clear()
  local song = renoise.song
  local pos_start = song().transport.loop_start
  pos_start.line = 1; 
  pos_start.sequence = PatternJumper.current_pattern
  local pos_end = song().transport.loop_end
  pos_end.line = 1; 
  pos_end.sequence  = PatternJumper.current_pattern
  song().transport.loop_range = {pos_start, pos_end}
end

function PatternJumper.loop_schedule(range_start, range_end)
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

function PatternJumper.go() 

  PatternJumper.current_pattern = 1 
  PatternJumper.last_pattern = PatternJumper.current_pattern
  PatternJumper.current_loop_count = 1
  PatternJumper.current_loop = 1 

  PatternJumper.loop_schedule(PatternJumper.loop_list[PatternJumper.current_loop][1], PatternJumper.loop_list[PatternJumper.current_loop][2])
  renoise.tool():add_timer(process_looping, PatternJumper.timer_interval)

end

return PatternJumper
