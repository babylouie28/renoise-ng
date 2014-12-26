--------------------------------------------------------------------------------
-- Code swiped from Cells!
--
-- Copyright 2012 Martin Bealby
--
-- Preferences Code
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------
preferences = nil
local template_dialog = nil
local view_template_dialog = nil
  


--------------------------------------------------------------------------------
-- Functions
--------------------------------------------------------------------------------
function load_preferences()
  -- initialise default and overwrite with settings from the config file

  preferences = renoise.Document.create("OscJumperParameters") {

    nodes = {                       -- network node connections
      node1 = {
        ip = "127.0.0.1",           -- localhost
        port = 8000,
        protocol = 2,               -- 1 = TCP, 2 = UDP
      },
      node2 = {     --- The current instance of Renoise
        ip = "0.0.0.0",
        port = 8000,
        protocol = 2,               -- 1 = TCP, 2 = UDP
        enable = false,
      },
       node3 = {             -- Do we want to be able to send info back to the remote OSC client?
         ip = "0.0.0.0",
         port = 8080,
         protocol = 2,               -- 1 = TCP, 2 = UDP
         enable = false,
       },
--       node4 = {
--         ip = "0.0.0.0",
--         port = 8000,
--         protocol = 2,               -- 1 = TCP, 2 = UDP
--         enable = false,
--       },
    },
  }
  preferences:load_from("config.xml")
end



function save_preferences()
  -- save the current settings to the config file
  if preferences ~= nil then
    preferences:save_as("config.xml")
  else
  end
end


--------------------------------------------------------------------------------
-- GUI Code
--------------------------------------------------------------------------------
function template_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    save_preferences()
    template_dialog:close()
  else
    return key
  end
end



function template_dialog_init()
  local vb = renoise.ViewBuilder()
  
  --
  -- UI
  --
  view_template_dialog = vb:column {
    spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
    margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

    vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "Localhost:               ",
        tooltip = "Localhost OSC server settings",
      },
      vb:valuebox {
        min = 4000,
        max = 65535,
        value = preferences.nodes.node1.port.value,
        tooltip = "Local OSC server port",
        notifier = function(v)
          preferences.nodes.node1.port.value = v
        end
      },
      vb:popup {
        items = {"TCP", "UDP"},
        value = preferences.nodes.node1.protocol.value,
        tooltip = "Local OSC server protocol",
        notifier = function(v)
          preferences.nodes.node1.protocol.value = v
        end
      },
    },

    vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "Available template files:                 ",
        tooltip = "Templates",
      },
      vb:popup {
        width = 300, -- ???
         -- Need to replace this with preference value.
        items = NewFromTemplate.get_file_list("/home/james/ownCloud/RenoiseSongs/templates") ,
        
        tooltip = "Template files",
        notifier = function(v)
          print("Template file ", v , " selected.")
        end
      },


    
    },
    
    vb:horizontal_aligner {
      mode = "justify",    
      vb:button {
        text = "Save & Close",
        released = function()
          save_preferences()
          -- Do we need to do something with any running OSC servers?
          template_dialog:close()
          renoise.app():show_status("OscJumper preferences saved.")
        end
      },
    },

  }
end



function display_template_dialog()
 
  -- Remove any existing dialog
  if template_dialog then
    template_dialog = nil
  end
  
  -- reload
  load_preferences()

  -- Create new dialog
  template_dialog_init()
  template_dialog = renoise.app():show_custom_dialog("New from template Preferences", view_template_dialog, template_dialog_keyhander)
end



--------------------------------------------------------------------------------
-- Menu Entries
--------------------------------------------------------------------------------

-- Is this duplicating what happens in main.lua?
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Neurogami " .. NewFromTemplate.menu_prefix() .. ":Configuration...",
  invoke = function() display_template_dialog() end
}





--------------------------------------------------------------------------------
-- Tool Startup
--------------------------------------------------------------------------------
load_preferences()

