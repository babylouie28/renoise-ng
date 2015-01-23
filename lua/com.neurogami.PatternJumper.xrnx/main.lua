--[[============================================================================
com.neurogami.PatternJumper.xrnx/main.lua
============================================================================]]--



TOOL_NAME = "Patern_Jumper"

require 'PatternJumper/Utils'
require 'PatternJumper/Core'
require 'PatternJumper/Configuration'


function do_something()
PatternJumper.go() 
end

renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami " .. TOOL_NAME  .. ":Do seomthing ..",
  invoke = do_something
}


