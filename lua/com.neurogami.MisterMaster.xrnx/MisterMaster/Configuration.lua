-- Configuration.lua

configuration = nil
local configuration_dialog = nil
local view_osc_config_dialog = nil
local config_file_name = "config.xml"


function song_slug()
  local name = renoise.song().name:gsub(" ", "_")
  print("Have song slug " .. name )
  return name
end


function have_config_file() 
  print("MisterMaster: Look for file ...")
  local file_name = os.currentdir() .. "../../UserConfig/" .. song_slug() .. ".lua"
  print(file_name)
  local f=io.open(file_name,"r")
  if f~=nil then io.close(f) return true else return false end
end



function load_osc_config()
  
  -- How would you generate this?
  -- Should we just auto-generate it? Every song gets it's own config file?
  -- Add a button to create it?
  if have_config_file() then
    config_file_name = song_slug() .. ".xml"
  end

  configuration = renoise.Document.create(TOOL_NAME .. "Configuration") {

    osc_settings = {
      -- This is the OSC server so we can talk to the tool
      internal = { 
        ip = "0.0.0.0",    
        port = 8001,
        protocol = 2,               -- 1 = TCP, 2 = UDP
      },
      --- This should match what is used by Renoise 
      --  so the tool can pass along messages using 
      --  its own OSC client
      renoise = {     
        ip = "0.0.0.0",
        port = 8000,
        protocol = 2,               
      },

    },
  }
-- See if 
  configuration:load_from(config_file_name)
end


function save_osc_custom_config()
 config_file_name = song_slug() .. ".xml"
  if configuration ~= nil then
    configuration:save_as(config_file_name)
  end
end

function save_osc_config()
  if configuration ~= nil then
    configuration:save_as(config_file_name)
  end
end

function configuration_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    save_osc_config()
    configuration_dialog:close()
  else
    return key
  end
end

function init_osc_config_dialog()
  local vb = renoise.ViewBuilder()
  
  view_osc_config_dialog = vb:column {
    spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
    margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

    vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = TOOL_NAME .. ":               ",
        tooltip = TOOL_NAME .. " OSC server settings",
      },
      vb:textfield {
        text = configuration.osc_settings.internal.ip.value,
        tooltip = TOOL_NAME .. " server IP",
        notifier = function(v)
          configuration.osc_settings.internal.ip.value = v
        end
      },

      vb:valuebox {
        min = 4000,
        max = 65535,
        value = configuration.osc_settings.internal.port.value,
        tooltip = TOOL_NAME .. " server port",
        notifier = function(v)
          configuration.osc_settings.internal.port.value = v
        end
      },
      vb:popup {
        items = {"TCP", "UDP"},
        value = configuration.osc_settings.internal.protocol.value,
        tooltip = TOOL_NAME .. " server protocol",
        notifier = function(v)
          configuration.osc_settings.internal.protocol.value = v
        end
      },
    },

    vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "Renoise:                 ",
        tooltip = "Renoise OSC server settings",
      },
      vb:textfield {
        text = configuration.osc_settings.renoise.ip.value,
        tooltip = "Renoise OSC server IP",
        notifier = function(v)
          configuration.osc_settings.renoise.ip.value = v
        end
      },

      vb:valuebox {
        min = 4000,
        max = 65535,
        value = configuration.osc_settings.renoise.port.value,
        tooltip = "Renoise OSC server port",
        notifier = function(v)
          configuration.osc_settings.renoise.port.value = v
        end
      },
      vb:popup {
        items = {"TCP", "UDP"},
        value = configuration.osc_settings.renoise.protocol.value,
        tooltip = "Renoise OSC server protocol",
        notifier = function(v)
          configuration.osc_settings.renoise.protocol.value = v
        end
      },
    
    },
--[[
   vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "Controller:                 ",
        tooltip = "Controller OSC server settings",
      },
      vb:textfield {
        text = configuration.osc_settings.controller.ip.value,
        tooltip = "Controller OSC server IP",
        notifier = function(v)
          configuration.osc_settings.controller.ip.value = v
        end
      },

      vb:valuebox {
        min = 4000,
        max = 65535,
        value = configuration.osc_settings.controller.port.value,
        tooltip = "Controller OSC server port",
        notifier = function(v)
          configuration.osc_settings.controller.port.value = v
        end
      },
      vb:popup {
        items = {"TCP", "UDP"},
        value = configuration.osc_settings.controller.protocol.value,
        tooltip = "Controller OSC server protocol",
        notifier = function(v)
          configuration.osc_settings.controller.protocol.value = v
        end
      },
    
    },
--]]
    vb:horizontal_aligner {
      mode = "justify",    
      vb:button {
        text = "Save & close",
        released = function()
          save_osc_config()
          configuration_dialog:close()
          renoise.app():show_status(TOOL_NAME .. " configuration saved.")
        end
      },
    },
    vb:horizontal_aligner {
      mode = "justify",    
      vb:button {
        text = "Save for this song & close",
        released = function()
          save_osc_custom_config()
          configuration_dialog:close()
          renoise.app():show_status(TOOL_NAME .. " configuration saved.")
        end
      },
    },

  }
end

function display_osc_config_dialog()
  if configuration_dialog then
    configuration_dialog = nil
  end
  
  load_osc_config()
  init_osc_config_dialog()
  configuration_dialog = renoise.app():show_custom_dialog(TOOL_NAME .. " Preferences", view_osc_config_dialog, configuration_dialog_keyhander)
end

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Neurogami " .. TOOL_NAME .. ":Configuration...",
  invoke = function() display_osc_config_dialog() end
}

load_osc_config()


