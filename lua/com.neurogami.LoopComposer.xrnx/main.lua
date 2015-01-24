--[[============================================================================
com.neurogami.PatternJumper.xrnx/main.lua
============================================================================]]--



TOOL_NAME = "LoopComposer"

require 'LoopComposer/Utils'
require 'LoopComposer/Core'
require 'LoopComposer/Dumper'
require 'LoopComposer/Configuration'


function do_something()
LoopComposer.go() 
end

renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami:" .. TOOL_NAME  .. ":Run",
  invoke = do_something
}


