--[[============================================================================
Track Pattern Comments
Neurogami / James Britt <james@neurogami.com>

Originally based on code swiped from the Track Comments tool, by Florian Krause <siebenhundertzehn@gmail.com>


This new version: 0.1
============================================================================]]--

require 'Utils'
require 'Core'
require 'Gui'

-- Reload the script whendever this file is saved. 
_AUTO_RELOAD_DEBUG = true

-- Read from the manifest.xml file.
class "RenoiseScriptingTool" (renoise.Document.DocumentNode)
  function RenoiseScriptingTool:__init()    
    renoise.Document.DocumentNode.__init(self) 
    self:add_property("Name", "Untitled Tool")
    self:add_property("Id", "Unknown Id") 
  end

local manifest = RenoiseScriptingTool()
local ok,err = manifest:load_from("manifest.xml")
local tool_name = manifest:property("Name").value
local tool_id = manifest:property("Id").value

renoise.tool().app_new_document_observable:add_notifier(
function()
  TPC.current_song = renoise.song()
  TPC.update_guid_count()
end
)


--------------------------------------------------------------------------------
-- Menu entry.
--------------------------------------------------------------------------------
renoise.tool():add_menu_entry {
   name = "Pattern Editor:"..tool_name.."...",
  invoke = GUI.show_dialog  
}


