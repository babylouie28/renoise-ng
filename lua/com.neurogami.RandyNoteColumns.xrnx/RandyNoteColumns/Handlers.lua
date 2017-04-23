--  Handlers.lua
--  Suggestion: do not put core logic here; try to put that in Core.lua, and
--  just invoke their functions from here.
--  That way those core functions can be used more easily elsewhere,
--  such as by a MIDI-mapping interface. 

handlers = { 
  {  
    pattern = "/track/notes/solo_column_timer",
    handler = function(track_index, column_index)
      print(" ***** Call RandyNoteColumns.solo_vol_timer(track_index, column_index) ********")
      RandyNoteColumns.solo_vol_timer(track_index, column_index)
    end 
  }, 

  {  
    pattern = "/track/notes/solo_column",
    handler = function(track_index, column_index)
      RandyNoteColumns.solo_vol(track_index, column_index)
    end 
  }, 

  {
    pattern = "/add_poll",
    handler = function(poll_id, code, interval)
      interval = interval or 500 
      print("Handler /add_poll has '" .. poll_id .. "', '" .. code .. "' " .. interval) 
      Status.add_poll(poll_id, code, interval)
    end 
  }, 

  {
    pattern = "/remove_poll",
    handler = function(poll_id)
      Status.remove_poll(poll_id)
    end 
  }, 

} -- end of handlers 

function load_handlers(osc_device)
  for i, h in ipairs(handlers) do
    osc_device:add_message_handler( h.pattern, h.handler )  
  end
end


