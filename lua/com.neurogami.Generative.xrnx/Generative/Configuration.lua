-- Configuration.lua

composition = nil
local composition_dialog = nil
local view_loop_compose_dialog = nil

-- local composition_file = TOOL_NAME .. "Pattern.xml"


function composition_file()
  return "loop_composition_" ..  U.base_file_name() .. ".xml"
end

-- Since we are loading from comments we don't need this
-- to load from disk file. But while we're having issue
-- this ight be handy to see what form the old code expected
function load_loop_config()

  composition = renoise.Document.create(TOOL_NAME) {
    text = "",
  }

  local res = composition:load_from(composition_file())
  local text_from_xml = composition.text.value
  print("text_from_xml = " .. text_from_xml )

--  Generative.raw_script = composition.text.value
end



function save_composition()

  print("save_composition. Generative.raw_script: ")
  U.rPrint(Generative.raw_script)
  -- It *should * come in as a string, a series of rows of space-delimited numbers.
  --  It should be saved and loaed that way; it make sit easier to hand edit or
  --  have some otehr tool create/manipulate.
  --  Other code will need to convert it into the internal table format
  if composition ~= nil then
    composition = renoise.Document.create(TOOL_NAME) {
      text = Generative.raw_script,
    }

    composition:save_as(composition_file())
  end
end

function composition_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    save_loop_config()
    composition_dialog:close()
  else
    return key
  end
end

function init_loop_compose_dialog()
  local vb = renoise.ViewBuilder()

  view_loop_compose_dialog = vb:column {
    spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
    margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

    vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "Enter your loop composition as a series of space-seperated numbers:\nstart end count",
        tooltip = "n n n",
      },
    },   

    vb:horizontal_aligner {
      mode = "justify",    
      vb:row {
        vb:multiline_textfield {
          text = Generative.raw_script,
          id = "composition",
          font = "big",
          width = 300,
          height = 400,
          notifier = function(v)
            -- This will set the table to a list of rows of text
            Generative.raw_script =  v --vb.views["raw_coposition"].paragraphs
          end
        }, -- multiline 
      },  -- row



    }, -- h:aligner
    vb:button {
      text = "Save",
      released = function()
        save_composition()
        composition_dialog:close()
      end
    },
  }

end

function display_loop_compose_dialog()
  if composition_dialog then
    composition_dialog = nil
  end

  load_loop_config()
  init_loop_compose_dialog()
  composition_dialog = renoise.app():show_custom_dialog(TOOL_NAME .. " Preferences", view_loop_compose_dialog, composition_dialog_keyhander)
end

--[[
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Neurogami:" .. TOOL_NAME .. ":Compose ...",
  invoke = function() display_loop_compose_dialog() end
}
--]]
--
--[[
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Neurogami:" .. TOOL_NAME  .. ":Run",
  invoke = Generative.go
}
--]]
--[[
renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami:" .. TOOL_NAME .. ":Stop",
  invoke = function()  
      Generative.clear() 
  end
}
--]]


