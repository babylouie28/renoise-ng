NewFromTemplate = {}

local template_dialog = nil
local view_template_dialog = nil

local selected_template = nil

local template_folder = "/home/james/ownCloud/RenoiseSongs/templates"
local new_file_folder = "/home/james/ownCloud/RenoiseSongs"
local new_file_name = ""


-- Taken fro m the CreateTool tool.
-- Why does Renoise Lua not have os.copyfile?
local ERROR = {OK=1, FATAL=2, USER=3}


-- Reads entire file into a string
-- (this function is binary safe)
local function file_get_contents(file_path)
  local mode = "rb"  
  local file_ref,err = io.open(file_path, mode)
  if not err then
    local data=file_ref:read("*all")        
    io.close(file_ref)    
    return data
  else
    return nil,err;
  end
end

-- Writes a string to a file
-- (this function is binary safe)
local function file_put_contents(file_path, data)
  local mode = "w+b" -- all previous data is erased
  local file_ref,err = io.open(file_path, mode)
  if not err then
    local ok=file_ref:write(data)
    io.flush(file_ref)
    io.close(file_ref)    
    return ok
  else
    return nil,err;
  end
end


-- Copies the contents of one file into another file.
local function copy_file_to(source, target)      
  local error = nil
  local code = ERROR.OK
  if (not io.exists(source)) then    
    error = "The source file\n\n" .. source .. "\n\ndoes not exist"
    code = ERROR.FATAL
  end
  -- if (not error and may_overwrite(target)) then
  if (not error) then
    local source_data = file_get_contents(source, true)    
    local ok,err = file_put_contents(target, source_data)        
    error = err          
  else 
    print("There was an error: ", error )
    code = ERROR.USER
  end
  return not error, error, code
end


-- If file exists, popup a modal dialog asking permission to overwrite.
local function may_overwrite(path)
  local overwrite = true
  if (io.exists(path) and options.ConfirmOverwrite.value) then
    local buttons = {"Overwrite", "Keep existing file" ,"Always Overwrite"}
    local choice = renoise.app():show_prompt("File exists", "The file\n\n " ..path .. " \n\n"
    .. "already exists. Overwrite existing file?", buttons)
    if (choice==buttons[3]) then 
      options.ConfirmOverwrite.value = false
    end
    overwrite = (choice~=buttons[2])
  end  
  return overwrite
end


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

  local from_file = template_folder .. "/" .. template_name
  local to_file   = new_file_folder .. "/" .. new_file_name

  print("Copy '" .. from_file .. "' to '" .. to_file .. "'" )
  local ok, err, code =  copy_file_to( from_file, to_file )

  if (err and code ~= ERROR.USER) then 
    renoise.app():show_error(err)  
    return
  end
  renoise.app():show_message("Your new Tool has been created: \n\n" .. to_file)
end


function NewFromTemplate.menu_prefix()
  return "New from Template"
end


return NewFromTemplate 
