--[[============================================================================
com.neurogami.NewFromTemplate.xrnx/main.lua
============================================================================]]--


require 'NewFromTemplate/Utils'
require 'NewFromTemplate/Core'
require 'NewFromTemplate/Preferences'


function intitialize_tool()
  NewFromTemplate.get_file_list("/home/james/ownCloud/RenoiseSongs/")
end

renoise.tool():add_menu_entry {
  name = ("--- Main Menu:Tools:Neurogami " .. NewFromTemplate.menu_prefix() .. ":Intitialize .."),
  invoke = intitialize_tool
}

