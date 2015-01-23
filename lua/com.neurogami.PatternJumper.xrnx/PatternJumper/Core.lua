-- Core.lua 
PatternJumper = {}

PatternJumper.current_pattern = 1 
PatternJumper.last_pattern = PatternJumper.current_pattern
PatternJumper.current_loop_count = 0
PatternJumper.current_loop = 1 

PatternJumper.loop_list = {
   {1, 2, 4},
   {3, 4, 2 },
   {1, 2, 2},
   {5, 6, 2},
   {3, 4, 4 },
} 


function set_next_loop()
  if PatternJumper.current_loop < #PatternJumper.loop_list then
     print("There is a next loop")
    PatternJumper.current_loop = PatternJumper.current_loop + 1
     PatternJumper.loop_schedule(PatternJumper.loop_list[PatternJumper.current_loop][1], PatternJumper.loop_list[PatternJumper.current_loop][2])       
  else
    print("There is no next loop. Now what?")
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


--]]
function process_looping()

  local range_start, range_end, count, num_loops

  PatternJumper.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]

  set_next_loop()

  for i, v in ipairs(PatternJumper.loop_list) do

   rPrint(v)
   range_start = v[1]
   range_end = v[2]
   num_loops = v[3]
 end

end


function PatternJumper.loop_schedule(range_start, range_end)
    local song = renoise.song
    print("/loop/schedule! ", range_start, " ", range_end)
    song().transport:set_scheduled_sequence(clamp_value(range_start, 1, song().transport.song_length.sequence))
    local pos_start = song().transport.loop_start
    pos_start.line = 1; pos_start.sequence = clamp_value(range_start, 1, song().transport.song_length.sequence)
    local pos_end = song().transport.loop_end
    pos_end.line = 1; pos_end.sequence =  clamp_value(range_end + 1, 1, 
    song().transport.song_length.sequence + 1)
    song().transport.loop_range = {pos_start, pos_end}
end



function PatternJumper.go() 


  local range_start, range_end, count, num_loops

  renoise.tool():add_timer(process_looping, 1000)
  
  

end


--[[

The idea:  Specify, using some sort of magic syntax, a set of pattern loops
and conditions for moving fomr one to another.

Possibles:

Tables, of course, of some kind


[start, end, loop_count]
...


A list of loop defs.  

The tool has a timer that kicks each .5 seconds or so.

It looks at the current loop settings, and makes a note of the number of times it
loops (either by counting entry of  first or last pattern).

When it sees that the current loop has reached it stop time it schedules
the next loop and prepares to reset the counter.

It repeats that process so long as the loop list has items.

If you want to be clever, you could define loops ranges, assign them numbers,
then the loop list can have those numbers; loop defs can be reused.

If you wanted to be super clever you could have a means of allowing a loop def
to modify the loop list.

But the simplest approach is a list of tables.



--]]

return PatternJumper
