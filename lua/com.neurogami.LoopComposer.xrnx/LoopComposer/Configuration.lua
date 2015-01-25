-- Configuration.lua

composition = nil
local composition_dialog = nil
local view_loop_compose_dialog = nil

local composition_file = TOOL_NAME .. "Pattern.xml"

local raw_composition_text = ""

SMALL_GAP = 8



-- function next_raw_loop_index()
--    raw_loop_index = raw_loop_index +  1
--    return string.lpad("0" .. raw_loop_index, 5, "0")
--  end

function load_loop_config()
  composition = renoise.Document.create(TOOL_NAME) {
    text = "",
  }

  local res = composition:load_from(composition_file)
  raw_composition_text = composition.text.value
end



function save_composition()

  print("save_composition. raw_composition_text: ")
  rPrint(raw_composition_text)
  -- It *should * come in as a string, a series of rows of space-delimited numbers.
  --  It should be saved and loaed that way; it make sit easier to hand edit or
  --  have some otehr tool create/manipulate.
  --  Other code will need to convert it into the internal table format
  if composition ~= nil then
    composition = renoise.Document.create(TOOL_NAME) {
      text = raw_composition_text,
    }

    composition:save_as(composition_file)
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
          text = raw_composition_text,
          id = "composition",
          font = "big",
          width = 300,
          height = 400,
          notifier = function(v)
            -- This will set the table to a list of rows of text
            raw_composition_text =  v --vb.views["raw_coposition"].paragraphs
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

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Neurogami:" .. TOOL_NAME .. ":Compose ...",
  invoke = function() display_loop_compose_dialog() end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:Neurogami:" .. TOOL_NAME  .. ":Run",
  invoke = LoopComposer.go
}

renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami:" .. TOOL_NAME .. ":Stop",
  invoke = function()  
      LoopComposer.clear() 
  end
}

load_loop_config()

