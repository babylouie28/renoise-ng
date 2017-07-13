--[[============================================================================
com.neurogami.Alternator.xrnx/main.lua

============================================================================]]--

TOOL_NAME = "Alternator"

U  = require (TOOL_NAME .. '/Utilities')

require (TOOL_NAME .. '/Core')
require (TOOL_NAME .. '/Gui')

-- Reload the script whendever this file is saved. 
_AUTO_RELOAD_DEBUG = true



-- Read from the manifest.xml file.
class "RenoiseScriptingTool" (renoise.Document.DocumentNode)
  function RenoiseScriptingTool:__init()    
    renoise.Document.DocumentNode.__init(self) 
    self:add_property("Name", "Untitled Tool")
    self:add_property("Id", "Unknown Id") 
    self:add_property("Version", "Unknown version") 
  end

local manifest = RenoiseScriptingTool()
local ok,err = manifest:load_from("manifest.xml")
GUI.tool_name = manifest:property("Name").value
GUI.tool_id = manifest:property("Id").value
GUI.tool_version = manifest:property("Version").value

print("Alternator has version: " .. GUI.tool_version)



local function alternator_gui()
  GUI.current_text = ""
  GUI.show_dialog() 
end



renoise.tool():add_menu_entry {
  name = "Pattern Editor:Neurogami  " .. TOOL_NAME,
  invoke = alternator_gui
}


------- keys --------------------------
renoise.tool():add_keybinding {
  name = "Global:Tools:Neurogami " .. TOOL_NAME,
  invoke = alternator_gui
}  



