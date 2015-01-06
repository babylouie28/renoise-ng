--  Handlers.lua
--  Suggestion: do not put core logic here; try to put that in Core.lua, and
--  just invoke their functions from here.
--  That way those core functions can be used more easily elsewhere,
--  such as by a MIDI-mapping interface. 


-- Some example handlers.  They invoke methods defined in Core.lua
handlers = { 
{
    pattern = "/set_status_polling",
    handler = function(bool)
      print("Handler for /set_status_polling is being passed type ", type(bool) )
      BeatMasher.set_status_polling(bool)
    end 
  }, 

  {
    pattern = "/song/reset",
    handler = function()
      BeatMasher.song_reset()
    end 
  }, 

  {
    pattern = "/song/undo",
    handler = function()
      BeatMasher.song_undo()
    end 
  },

{
    pattern = "/track/select",
    handler = function(track_number)
      BeatMasher.track_select(track_number)
    end 
  },
  {
    pattern = "/song/track/clear",
    handler = function(track_number)
      BeatMasher.song_track_clear(track_number)
    end 
  },



  {
    pattern = "/song/save_version",
    handler = function()
      BeatMasher.song_save_version()
    end 
  },

  {
    pattern = "/song/load_by_id",
    handler = function(id_number)
      BeatMasher.song_load_by_id(id_number)
    end 
  },

    {
    pattern = "/trigger/note",
    handler = function(instrument, track, note,  velocity)
      BeatMasher.trigger_note(RENOISE_OSC, instrument, track, note,  velocity)
    end 
  },

  {
    pattern = "/speak/bpm",
    handler = function()
      local instrument_index = 6  -- Would ne nice if this was calculated at runtime
      local track_index = 6    
      -- To keep the core code from having to know too much about creating OSC devices,
      -- pass an existing device into the function.
      --See if this plays out in practice as well as you hope.
      BeatMasher.speak_bpm(RENOISE_OSC, track_index, instrument_index)
    end 
  },


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


