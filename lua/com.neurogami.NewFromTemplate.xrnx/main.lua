--[[============================================================================
com.neurogami.NewFromTemplate.xrnx/main.lua
============================================================================]]--


require 'NewFromTemplate/Utils'
require 'NewFromTemplate/Core'
require 'NewFromTemplate/Preferences'


function create_new_song()
 NewFromTemplate.prompt_user()
end

renoise.tool():add_menu_entry {
  name = ("--- Main Menu:Tools:Neurogami " .. NewFromTemplate.menu_prefix() .. ":Create new song"),
  invoke = create_new_song
}



