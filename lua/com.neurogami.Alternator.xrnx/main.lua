--[[============================================================================
com.neurogami.Alternator.xrnx/main.lua

============================================================================]]--

require 'Utils'
require 'Core'
require 'Gui'

-- Reload the script whendever this file is saved. 
_AUTO_RELOAD_DEBUG = true

local function swap_columns_gui()
  GUI.current_text = ""
  GUI.show_dialog() 
--   local text = string.trim(GUI.current_text)
end



renoise.tool():add_menu_entry {
  name = "Pattern Editor:Neurogami Alternator",
  invoke = swap_columns_gui
}


------- keys --------------------------
renoise.tool():add_keybinding {
  name = "Global:Tools:Neurogami Alternator",
  invoke = swap_columns_gui
}  



