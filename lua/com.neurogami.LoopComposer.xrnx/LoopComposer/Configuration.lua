-- Configuration.lua

composition = nil
local composition_dialog = nil
local view_loop_compose_dialog = nil

local composition_file = TOOL_NAME .. "Pattern.xml"

local raw_loop_table = {}
local raw_loop_index = 0

SMALL_GAP = 8

string.lpad = function(str, len, char)
    if char == nil then char = ' ' end
    return str .. string.rep(char, len - #str)
end


function next_raw_loop_index()
   raw_loop_index = raw_loop_index +  1
   return string.lpad("0" .. raw_loop_index, 5, "0")
end
-- Since we have a variable size of data
-- we may need to use that serialization lib

function load_loop_config()
  composition = renoise.Document.create(TOOL_NAME) {

    loop_table = { 1,2,3,4  },
  }

  local res = composition:load_from(composition_file)
end

function save_composition()

  print("save_composition. raw_loop_table: ")
  rPrint(raw_loop_table)

  if composition ~= nil then

 composition = renoise.Document.create(TOOL_NAME) {
    loop_table = { 1,2,3,4  },
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
        text = "Test to see if we can add and remove tings dynamically",
        tooltip = "test",
      },

    },   
    vb:horizontal_aligner {
         mode = "justify",
    vb:column {
      id = "loop_holder"
    },
  },


    vb:horizontal_aligner {
      mode = "justify",    
      vb:button {
        text = "Add a loop pattern",
        released = function()
          local rand_id = next_raw_loop_index()
          local loop_holder = vb.views["loop_holder"]

          local new_loop = vb:row {
            id = rand_id, 
            vb:text { text = "Loop details: n,n,n,n " },
             vb:space {width = SMALL_GAP * 2 },
            vb:row {
              vb:textfield {
                width = 64,
                notifier = function(v)
                       raw_loop_table[rand_id] = v
                end
              }, vb:space {width = SMALL_GAP  },
            },  
            
            vb:button {
              text = " X ",
              released = function(stuff)
                 print("delete button was passed ", stuff)
                 print("Do we know about the id? ", rand_id)
                 raw_loop_table[rand_id] = nil
                 local loop_thing =  vb.views[rand_id]
                  local loop_holder = vb.views["loop_holder"]
                  loop_holder:remove_child(loop_thing)
                  loop_holder:resize() -- FIXME This does nothing. Need to resize
              end
             } 
          }

          loop_holder:add_child(new_loop)
        end 
      },
      vb:space { width = SMALL_GAP },
        vb:button {
          text = "Save",
          released = function()
            save_composition()
            composition_dialog:close()
          end
    },
  }

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

load_loop_config()

