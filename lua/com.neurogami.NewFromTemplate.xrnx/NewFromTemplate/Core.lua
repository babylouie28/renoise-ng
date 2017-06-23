local U = require 'NewFromTemplate/Utilities'
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
  -- print("NewFromTemplate.get_file_list using ", folder_path ) -- DEBUG
  local files = os.filenames(folder_path, default_extension )
  -- rprint(files) -- DEBUG
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
  template_folder = Prefs.templates_folder()
  new_file_folder = Prefs.new_file_folder()
end



function NewFromTemplate.prompt_user()

  -- Remove any existing dialog
  if template_dialog then
    template_dialog = nil
  end

  NewFromTemplate.load_preferences() 

  -- Validate the current config settings.  If either path is
  -- invalid, tell the user and do not allow them to continue to
  -- create a song from a template

  local paths_are_valid = Prefs.validate_paths()

  if paths_are_valid then
    NewFromTemplate.template_dialog_init()
    template_dialog = renoise.app():show_custom_dialog("New from template", view_template_dialog, NewFromTemplate.template_dialog_keyhander)
  end
end

function NewFromTemplate.template_dialog_init()

  NewFromTemplate.load_preferences()

  local vb = renoise.ViewBuilder()

  local template_files = NewFromTemplate.get_file_list(template_folder) 
  
  local default_template_index = 1
  
  if next (template_files) == nil then
    selected_template = ""
    renoise.app():show_message("There are no templates in '"..template_folder.."'")
  else
    selected_template = template_files[default_template_index] 
  end 

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
        
        notifier = function(idx)
          if next (template_files) == nil then
            selected_template = ""
            renoise.app():show_message("There are no templates in '", template_folder, "'")
          else
            selected_template = template_files[idx]
          end 

          print("Template file  ", template_files[idx] , " selected.") -- DEBUG

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
          -- print("* * new_file_name = ", new_file_name) -- DEBUG
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

          new_file_name = string.trim(new_file_name)
          selected_template = string.trim(selected_template)
          print("* * * * * Working with new file name '" .. new_file_name .. "'")
          print("* * * * *  Working with selected_template '" .. selected_template .. "'")
          if (U.is_empty(selected_template)) then
            renoise.app():show_message("There seems to be no template selected.\nPlease be sure your template folder has \ntemplates and that you select one of them.") 
          else
            if (U.is_empty(new_file_name)) then
              renoise.app():show_message("There seems to be no name for the new song.\nPlease be sure you enter a new song name.") 
            else
              NewFromTemplate.generate_new_file(selected_template, new_file_name)
            end
          end
        end
      },
    } -- ******************** end aligner ******************** 
  } 


end

function NewFromTemplate.generate_new_file(template_name, new_file_name) 
  print("Create a new song by copying ", template_name, " to ", new_file_name, " (we hope)" ) -- DEBUG
  print(" We have new_file_folder = ", new_file_folder ) -- DEBUG

  new_file_name = string.trim(new_file_name)
  new_file_name = string.gsub(new_file_name, "\.xrns$", "")
  new_file_name  = (new_file_name .. ".xrns")

  local from_file = template_folder .. path_slash .. template_name
  local to_file   = new_file_folder .. path_slash .. new_file_name

  print("Copy '" .. from_file .. "' to '" .. to_file .. "'" ) -- DEBUG
  local ok, err, code =  U.copy_file_to( from_file, to_file )

  if (err and code ~= ERROR.USER) then 
    renoise.app():show_error(err)  
    return
  end

  print("copy_file_to OK  = ", ok) -- DEBUG

  if (ok) then
    renoise.app():show_message("Your new song has been created: \n\n" .. to_file)
    renoise.app():load_song(to_file)
  else
    renoise.app():show_message("No new song was created.")
  end
end


function NewFromTemplate.menu_prefix()
  return "New from Template"
end


return NewFromTemplate 
