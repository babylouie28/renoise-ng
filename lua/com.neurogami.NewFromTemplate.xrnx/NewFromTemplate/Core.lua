local Utils = require 'NewFromTemplate/Utils'
local Prefs = require 'NewFromTemplate/Preferences'

local preferences = Prefs.load_preferences()

NewFromTemplate = {}

local template_dialog = nil
local view_template_dialog = nil
local default_extension = '*.xrns'
local selected_template = nil

local template_folder =  "" -- preferences.templates_folder.value
local new_file_folder = "" --  preferences.templates_folder.new_file_folder.value

local new_file_name = ""

local path_slash = "/"

if (os.platform() == "WINDOWS") then
  path_slash = "\\"
end



-- TODO: THink about how ot better partition the code.
-- OTOH, there's not much happeneing other than prompting for a temaplte and new file name,
-- but perhaps the file-copying code could be placed into another module or file of some kind.



-- https://github.com/davidm/lua-glob-pattern
-- http://lua-users.org/wiki/DirTreeIterator
function NewFromTemplate.get_file_list(folder_path) 
  print("NewFromTemplate.get_file_list using ", folder_path )

  local files = os.filenames(folder_path, default_extension )
  rprint(files)
  return files
end

function NewFromTemplate.template_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    save_preferences()
    template_dialog:close()
  else
    return key
  end
end

function NewFromTemplate.load_preferences()
    preferences = Prefs.load_preferences()
    print("preferences  = ", preferences )
   template_folder = Prefs.templates_folder()
 print("template_folder  = ", template_folder )
   new_file_folder = Prefs.new_file_folder()
 print("new_file_folder  = ", new_file_folder )
end

-- Issue: This code needs the preferences data,
-- but that is handled elsewhere
-- FIXME
function NewFromTemplate.prompt_user()

  -- Remove any existing dialog
  if template_dialog then
    template_dialog = nil
  end

  -- reload
  NewFromTemplate.load_preferences() -- FIXME need to make real

  -- Create new dialog
  NewFromTemplate.template_dialog_init()
  template_dialog = renoise.app():show_custom_dialog("New from template", view_template_dialog, NewFromTemplate.template_dialog_keyhander)
end

function NewFromTemplate.template_dialog_init()

  NewFromTemplate.load_preferences()

  local vb = renoise.ViewBuilder()
  -- Need to replace this with preference value for template folder.
  local template_files = NewFromTemplate.get_file_list(template_folder) 
  local default_template_index = 1
  selected_template = template_files[default_template_index] 

  view_template_dialog = vb:column {
    spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
    margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

    vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "Available templates:                 ",
        tooltip = "Templates",
      },
      vb:popup {
        width = 300, -- ???

        items = template_files,
        tooltip = "Template files",
        value = default_template_index,

        -- Notifoer is only called if the user selects something on purpose.
        notifier = function(idx)
          print("Template file  ", template_files[idx] , " selected.")
          selected_template = template_files[idx]
        end
      },
    },  -- ******************** end aligner ******************** 
    vb:horizontal_aligner {
      mode = "justify",    
      vb:text {
        text = "New file name:",
      },

      vb:textfield {
        text = "New file name:",
        value = "",
        width = 390,
        notifier = function(v)
          new_file_name = v
          print("* * new_file_name = ", new_file_name)
        end

      },

    },  -- ******************** end aligner ******************** 
    vb:horizontal_aligner {
      mode = "justify",    
      vb:button {
        text = "Create & Close",
        released = function()
          -- Do we need to do something with any running OSC servers?
          template_dialog:close()
          NewFromTemplate.generate_new_file(selected_template, new_file_name)
        end
      },

    } -- ******************** end aligner ******************** 

  } 


end

function NewFromTemplate.generate_new_file(template_name, new_file_name) 
  print("Create a new song by copying ", template_name, " to ", new_file_name, " (we hope)" )
  print(" We have new_file_folder = ", new_file_folder )

  new_file_name = Utils.trim(new_file_name)
  new_file_name = string.gsub(new_file_name, "\.xrns$", "")
  new_file_name  = (new_file_name .. ".xrns")
  
  local from_file = template_folder .. path_slash .. template_name
  local to_file   = new_file_folder .. path_slash .. new_file_name

  print("Copy '" .. from_file .. "' to '" .. to_file .. "'" )
  local ok, err, code =  Utils.copy_file_to( from_file, to_file )

  if (err and code ~= ERROR.USER) then 
    renoise.app():show_error(err)  
    return
  end
  renoise.app():show_message("Your new song has been created: \n\n" .. to_file)
  renoise.app():load_song(to_file)
end


function NewFromTemplate.menu_prefix()
  return "New from Template"
end


return NewFromTemplate 
