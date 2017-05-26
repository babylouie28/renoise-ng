--[[============================================================================
com.neurogami.NewFromTemplate.xrnx/main.lua
============================================================================]]--


U = require 'NewFromTemplate/Utilities'
require 'NewFromTemplate/Core'
local Prefs = require 'NewFromTemplate/Preferences'

local pref_values = Prefs.load_preferences()

function create_new_song()
 NewFromTemplate.prompt_user()
end


--[[
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Neurogami " .. NewFromTemplate.menu_prefix() .. ":Configuration...",
  invoke = function() Prefs.display_template_dialog() end
}


renoise.tool():add_menu_entry {
  name = ("--- Main Menu:Tools:Neurogami " .. NewFromTemplate.menu_prefix() .. ":Create new song"),
  invoke = create_new_song
}
]]--


renoise.tool():add_menu_entry {
  name = "Main Menu:File:Neurogami " .. NewFromTemplate.menu_prefix() .. ":Configuration...",
  invoke = function() Prefs.display_template_dialog() end
}

renoise.tool():add_menu_entry {
  name = ("--- Main Menu:File:Neurogami " .. NewFromTemplate.menu_prefix() .. ":Create new song"),
  invoke = create_new_song
}


