-- Configuration.lua

configuration = nil
local configuration_dialog = nil
local view_osc_config_dialog = nil
  
function load_osc_config()
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

      controller = {     
        ip = "0.0.0.0",
        port = 8010,
        protocol = 2,               
      },
    },
  }

  configuration:load_from("config.xml")
end

function save_osc_config()
  if configuration ~= nil then
    configuration:save_as("config.xml")
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

    vb:horizontal_aligner {
      mode = "justify",    
      vb:button {
        text = "Save & Close",
        released = function()
          save_osc_config()
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

