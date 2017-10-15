--[[============================================================================
com.neurogami.Retempo.xrnx/main.lua

============================================================================]]--

TOOL_NAME = "Retempo"

-- U  = require (TOOL_NAME .. '/Utilities')

require (TOOL_NAME .. '/Core')

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
Core.tool_name = manifest:property("Name").value
Core.tool_id = manifest:property("Id").value
Core.tool_version = manifest:property("Version").value

print("Retempo has version: " .. Core.tool_version)

local function retempo_track()
 local new_note = Core.note_for_bpm()

print("* * * Have new note value of " .. new_note .. " * * * ")

 Core.set_notes_in_track_pattern_to(new_note, 2)
end

renoise.tool():add_menu_entry {
  name = "Pattern Editor:Neurogami " .. TOOL_NAME,
  invoke = retempo_track
}


------- keys --------------------------
renoise.tool():add_keybinding {
  name = "Global:Tools:Neurogami " .. TOOL_NAME,
  invoke = retempo_track
}  


