--[[============================================================================
com.neurogami.Generative.xrnx/main.lua
============================================================================]]--



TOOL_NAME = "Generative"

require (TOOL_NAME .. '/Utilities')
require (TOOL_NAME .. '/Utils')
require (TOOL_NAME .. '/Core')
require (TOOL_NAME .. '/Configuration')

local script = {}

function read_comments()
  local have_script = false

  for i, v in ipairs(renoise.song().comments) do 
  if (have_script) then
    print(i, v) 
  end
    
    if ( string.find(v, "- script -") ) then
     have_script = true
     table.insert(script, v)
   end
   
  end
  
  -- `comments` is  a table of strings.
  
  
  print(script)

  -- We might want to keep the table structure but only keep script lines.
  -- Perhaps we loop over the lines and look for some demarcation string
  -- and everything after that is the script.
end



function play_script()
  read_comments()
end


renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami:Generative:Play",
  invoke = play_script
}

