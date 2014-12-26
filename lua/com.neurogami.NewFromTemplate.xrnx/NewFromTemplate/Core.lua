NewFromTemplate = {}

local template_dialog = nil
local view_template_dialog = nil

local selected_template = nil
      
-- https://github.com/davidm/lua-glob-pattern
-- http://lua-users.org/wiki/DirTreeIterator
function NewFromTemplate.get_file_list(folder_path) 

  local extension = '*.xrns'
  local files = os.filenames(folder_path, extension)
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
print("NEED TO LOAD PREFERENCES")
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

  local vb = renoise.ViewBuilder()
  -- Need to replace this with preference value for template folder.
  local template_files = NewFromTemplate.get_file_list("/home/james/ownCloud/RenoiseSongs/templates") 
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
        width = 300, -- ??? What's a good width?

        items = template_files,
        tooltip = "Template files",
        value = default_template_index,

        -- Notifoer is only called if the user selects something on purpose.
        notifier = function(idx)
          print("Template file  ", template_files[idx] , " selected.")
          selected_template = template_files[idx]
        end
      },
  },  -- end aligner
    vb:horizontal_aligner {
      mode = "justify",    
      vb:button {
        text = "Create & Close",
        released = function()
          -- Do we need to do something with any running OSC servers?
          template_dialog:close()
          NewFromTemplate.generate_new_file(selected_template)
        end
      },
    } -- end aligner
  
  } 


end

function NewFromTemplate.generate_new_file(template_name) 
  print("Create a new song by copying ", template_name )
end


function NewFromTemplate.menu_prefix()
  return "New from Template"
end


return NewFromTemplate 
