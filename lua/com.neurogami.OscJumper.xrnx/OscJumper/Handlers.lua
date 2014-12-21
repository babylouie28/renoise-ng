--  Handlers.lua
--  Suggestion: do not put core logic here; try to put that in Core.lua, and
--  just invoke their functions from here.
--  That way those core functions can be used more easily elsewhere,
--  such as by a MIDI-mapping interface. 


-- Some example handlers.  They invoke methods defined in Core.lua
handlers = { 
  { -- Marks a pattern loop range and  then sets the start of the loop as  the next pattern to play
  pattern = "/loop/schedule",
  handler = function(range_start, range_end)
    OscJumper.loop_schedule(range_start, range_end)
  end 
}, 

{  
  -- Instantly jumps from the current pattern/line to given pattern and relative next line.
  -- If the second arg is greater than -1 it schedules that as the next pattern to play, and turns on
  -- block loop for that pattern.
  pattern = "/pattern/into",
  handler = function(pattern_index,  stick_to )
--    local pattern_index,  stick_to  = unpack(args)
    OscJumper.pattern_into(pattern_index, stick_to)
  end 
} 

} -- end of handlers 

function load_handlers(osc_device)
  for i, h in ipairs(handlers) do
    osc_device:add_message_handler( h.pattern, h.handler )  
  end

  if (have_rotator) then
    for i, h in ipairs(rotate_handlers) do
      osc_device:add_message_handler( h.pattern, h.handler )  
    end
      print("        ADDED ROTATE HANDLERS")
    else
      print("Cannot add roate handlers because have_rotator is false")
    end
end


