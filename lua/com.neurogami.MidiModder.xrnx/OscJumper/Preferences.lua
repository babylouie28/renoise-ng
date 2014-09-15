--------------------------------------------------------------------------------
-- Cells!
--
-- Copyright 2012 Martin Bealby
--
-- Preferences Code
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------
-- RENDER_SAMPLE_RATES = {"22050", "44100", "48000", "88200", "96000"}
-- RENDER_BIT_DEPTHS   = {"16", "24", "32"}
-- RENDER_PRIORITY     = {"low", "realtime", "high"}



--------------------------------------------------------------------------------
-- Variables
--------------------------------------------------------------------------------
preferences = nil
local pref_dialog = nil
local view_pref_dialog = nil
  


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
function pref_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    save_preferences()
    pref_dialog:close()
  else
    return key
  end
end



function pref_dialog_init()
  local vb = renoise.ViewBuilder()
  
  --
  -- populate output devices table
  --
  local output_devices = {}
  
  output_devices = renoise.song().tracks[1].available_output_routings
  table.remove(output_devices, 1) -- remove master routing
  
  -- Assign devices if only a single item is present
  rprint(output_devices)
  print('---')
  
  --
  -- UI
  --
  view_pref_dialog = vb:column {
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
        text = "Renoise:                 ",
        tooltip = "Renoise OSC server settings",
      },
      vb:valuebox {
        min = 4000,
        max = 65535,
        value = preferences.nodes.node2.port.value,
        tooltip = "Renoise OSC server port",
        notifier = function(v)
          preferences.nodes.node2.port.value = v
        end
      },
      vb:popup {
        items = {"TCP", "UDP"},
        value = preferences.nodes.node2.protocol.value,
        tooltip = "Renoise OSC server protocol",
        notifier = function(v)
          preferences.nodes.node2.protocol.value = v
        end
      },
    },



  }
end



function display_pref_dialog()
  -- Show the preferences dialog
 
  -- Remove any existing dialog
  if pref_dialog then
    pref_dialog = nil
  end
  
  -- reload
  load_preferences()

  -- Create new dialog
  pref_dialog_init()
  pref_dialog = renoise.app():show_custom_dialog("Osc Jumper Preferences", view_pref_dialog, pref_dialog_keyhander)
end



--------------------------------------------------------------------------------
-- Menu Entries
--------------------------------------------------------------------------------


renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Neurogami OSC Jumper:Configuration...",
  invoke = function() display_pref_dialog() end
}





--------------------------------------------------------------------------------
-- Tool Startup
--------------------------------------------------------------------------------
load_preferences()

