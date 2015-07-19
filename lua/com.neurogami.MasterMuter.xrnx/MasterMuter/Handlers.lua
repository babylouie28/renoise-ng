--  Handlers.lua
--  Suggestion: do not put core logic here; try to put that in Core.lua, and
--  just invoke their functions from here.
--  That way those core functions can be used more easily elsewhere,
--  such as by a MIDI-mapping interface. 


-- Some example handlers.  They invoke methods defined in Core.lua
handlers = { 
  {
  pattern = "/master/mute",
  handler = function()
    print("/master/mute")
    MasterMuter.manage_master_mute(1)
  end 
}, 

{  
  pattern = "/master/unmute",
  handler = function()
    print("/master/unmute")
    MasterMuter.manage_master_mute(0)
  end 
} ,

{  
  pattern = "/master/set_mute",
  handler = function(mute_value)
    print("/master/set_mute")
    MasterMuter.manage_master_mute(mute_value)
  end 
} 


} -- end of handlers 

function load_handlers(osc_device)
  for i, h in ipairs(handlers) do
    osc_device:add_message_handler( h.pattern, h.handler )  
  end
end


