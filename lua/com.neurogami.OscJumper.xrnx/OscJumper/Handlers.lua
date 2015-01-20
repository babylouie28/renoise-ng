--  Handlers.lua
--  Suggestion: do not put core logic here; try to put that in Core.lua, and
--  just invoke their functions from here.
--  That way those core functions can be used more easily elsewhere,
--  such as by a MIDI-mapping interface. 


handlers = { 

  { 
  pattern = "/loop/schedule",
  docs = [[ Marks a pattern loop range and  then sets the start of the loop as the next pattern to play. 
            Args: range_start, range_end ]],
  handler = function(range_start, range_end)
    OscJumper.loop_schedule(range_start, range_end)
  end 
}, 

{  
  pattern = "/pattern/into",
  docs = [[ Instantly jumps from the current pattern/line to given pattern and relative next line.
  If the second arg  (stick_to) is greater than -1 it schedules that as the next pattern to play, and turns on
  block loop for that pattern.
  Args: pattern_index,  stick_to ]],
  handler = function(pattern_index,  stick_to )
    OscJumper.pattern_into(pattern_index, stick_to)
  end 
} ,

{
  pattern = "/sequence_pos",
  docs = [[ Supposedly sends back to the OSC the current sequence position, but does not seem to be implemented.
  Args: none ]],
  handler = function()
    OscJumper.sequence_pos()
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

  if (have_randy) then
    for i, h in ipairs(randy_handlers) do
      osc_device:add_message_handler( h.pattern, h.handler )  
    end
    print("        ADDED RANDY HANDLERS")
  else
    print("Cannot add randy handlers because have_randy is false")
  end

end
