--  Handlers.lua
--  Suggestion: do not put core logic here; try to put that in Core.lua, and
--  just invoke their functions from here.
--  That way those core functions can be used more easily elsewhere,
--  such as by a MIDI-mapping interface. 


-- Some example handlers.  They invoke methods defined in Core.lua
handlers = { 
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
  pattern = "/pattern/rotate ",
  handler = function(track_num, num_lines)
    BeatMasher.pattern_rotate(track_num, num_lines)
  end 
},

    
{
  pattern = "/song/load_by_id",
  handler = function(id_number)
    BeatMasher.song_load_by_id(id_number)
  end 
},

{
  pattern = "/speak/bpm",
  handler = function()
    BeatMasher.speak_bpm()
  end 
},


} -- end of handlers 

function load_handlers(osc_device)
  for i, h in ipairs(handlers) do
    osc_device:add_message_handler( h.pattern, h.handler )  
  end
end


