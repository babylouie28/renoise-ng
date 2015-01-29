local U = require 'NewFromTemplate/Utilities'

local P = {}

local preferences = nil
local template_dialog = nil
local view_template_dialog = nil


function P.templates_folder()
  P.load_preferences()
  return  preferences.templates_folder.value
end

function P.new_file_folder()
  P.load_preferences()
  return preferences.new_file_folder.value
end

function P.load_preferences()
  -- initialise default and overwrite with settings from the config file

  preferences = renoise.Document.create("NewFromTemplatePreferences") {
    templates_folder = "",
    new_file_folder = ""
  }

  preferences:load_from("config.xml")
  P.clean_loaded_data()
  return preferences 
end

function P.clean_loaded_data()
  if preferences ~= nil then

local nff = preferences.new_file_folder.value 
    print("nff = ", nff  )
    preferences.new_file_folder.value =  string.trim(nff)
    preferences.templates_folder.value =  string.trim(preferences.templates_folder.value)
    
    preferences.new_file_folder.value =  string.gsub(preferences.new_file_folder.value, "\/$", "")
    preferences.new_file_folder.value =  string.gsub(preferences.new_file_folder.value, "\\$", "")

    preferences.templates_folder.value =  string.gsub(preferences.templates_folder.value, "\/$", "")
    preferences.templates_folder.value =  string.gsub(preferences.templates_folder.value, "\\$", "")
  end
end

function P.save_preferences()
  -- FIXME
  -- Nee to do some cleaning. Make sure strings are trimmed and
  -- remove trailing slashes
  if preferences ~= nil then
    P.clean_loaded_data()

    preferences:save_as("config.xml")
  else
  end
end

function P.template_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    P.save_preferences()
    template_dialog:close()
  else
    return key
  end
end



function P.template_dialog_init()
  local vb = renoise.ViewBuilder()
  
  view_template_dialog = vb:column {
    spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
    margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

    vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "Templates folder:               ",
        tooltip = "Templates",
      },
      vb:textfield {
        value = preferences.templates_folder.value,
        width = 300,
        tooltip = "Templates folder",
        notifier = function(v)
          preferences.templates_folder.value = v
        end
      },
   },  -- ************** vb:horizontal_aligner ********************

          vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "New file folder:               ",
        tooltip = "new files",
      },
      vb:textfield {
        value = preferences.new_file_folder.value,
        width = 300,
        tooltip = "New files",
        notifier = function(v)
          preferences.new_file_folder.value = v
        end
      },
    } ,  -- ************** vb:horizontal_aligner ********************
    
    vb:horizontal_aligner {
      mode = "justify",    
      vb:button {
        text = "Save & Close",
        released = function()
          P.save_preferences()
          -- Do we need to do something with any running OSC servers?
          template_dialog:close()
          renoise.app():show_status("New from Template preferences saved.")
        end
      },
    },  -- ************** vb:horizontal_aligner ********************

  }
end



function P.display_template_dialog()
 
  -- Remove any existing dialog
  if template_dialog then
    template_dialog = nil
  end
  
  P.load_preferences()
  P.template_dialog_init()
  template_dialog = renoise.app():show_custom_dialog("New from template Preferences", view_template_dialog, P.template_dialog_keyhander)
end


return P
