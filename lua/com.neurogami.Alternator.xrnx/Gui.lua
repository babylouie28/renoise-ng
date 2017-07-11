--------------------------------------------------------------------------------
-- GUI
--------------------------------------------------------------------------------
GUI = {}

GUI.dialog = nil
GUI.vb = {}
GUI.current_text = ""
GUI.lines_list = ""


GUI.values = nil

GUI.fx_values_text = ""

GUI.func_text = ""


-- ======================================================================
function rotate_right(s)
 local w_table = string.to_word_table(s)
 local r_table = U.wrap( w_table, 1 )
 local new_s = table.concat(r_table, " ")
 return new_s
end

-- ======================================================================
function rotate_left(s)
 local w_table = string.to_word_table(s)
 -- 
 local r_table = U.wrap( w_table, #w_table - 1 )
 local new_s = table.concat(r_table, " ")
 return new_s
end


-- ======================================================================
function line_nums_to_table(lines_str)
  print("In line_nums_to_table")
  local nums_table = string.int_list_to_numeric(lines_str)
  local paired_table = {}

  for k,v in pairs(nums_table ) do
    paired_table[v] = v
  end

  return paired_table 
end

-- ======================================================================
function load_values()
  print("Load last-used values ...")

  GUI.values = renoise.Document.create("AlternatorLastValues") {
    gen_function = GUI.func_text,
    fx_values = GUI.fx_values_text,
    lines_list  = GUI.lines_list
  }

  GUI.values:load_from("alternator.xml")

  GUI.func_text = GUI.values.gen_function.value 
  GUI.lines_list  = GUI.values.lines_list.value  
  GUI.fx_values_text = GUI.values.fx_values.value


  print("Loaded values, GUI.func_text = " .. "'" .. GUI.func_text .. "'")

end

-- ======================================================================
function save_values()
  print("Save current values ...")

  if GUI.values ~= nil then
    GUI.values.gen_function.value = GUI.func_text
    
    GUI.values.fx_values.value = GUI.fx_values_text
    GUI.values.lines_list.value  = GUI.vb.views.lines_list_field.text
    GUI.values:save_as("alternator.xml")
  end
end



function  GUI.rotate_values_left()
  print("Roate values left")
  GUI.vb.views.fx_values_text.text = rotate_left(GUI.vb.views.fx_values_text.text)
  GUI.fx_values_text = GUI.vb.views.fx_values_text.text 
end


function  GUI.rotate_values_right()
  print("Roate values right")
  GUI.vb.views.fx_values_text.text = rotate_right(GUI.vb.views.fx_values_text.text)
  GUI.fx_values_text = GUI.vb.views.fx_values_text.text 
end

-- TODO Decide how to define 'class' functions.  Either use `Foo.func_name = function` or `function Foo.func_name`


-- ======================================================================
GUI.show_dialog = function()

--[[   THE GOAL:

Values    [_______________________________________________________________] [< rotate] [ rotate > ]

Function  [_______________________________________________________________] [Generate]

Lines  
          |----------------------------------------------------------------|
          |                                                                |
          |                                                                |
          |                                                                |
          -----------------------------------------------------------------
           [Clear]   [Go] 


]]--




  if GUI.dialog and GUI.dialog.visible then
    GUI.dialog:show()
    return
  else
    GUI.dialog = {}
  end

  GUI.vb = renoise.ViewBuilder()
  GUI.current_text = ""  

  load_values()

  
  local button_rotate_left = GUI.vb:button {
      text = " << ",
      released = function()
        GUI.rotate_values_left()
      end
    }



  local button_rotate_right = GUI.vb:button {
      text = " >> ",
      released = function()
        GUI.rotate_values_right()
      end
    }



  local title = "Neurogami:Alternator.t of beta."

  local function_row = GUI.vb:row {
    GUI.vb:text {
      text = "Function",
      tooltip = "Function to generate line numbers",
    },

    GUI.vb:textfield {
      text = GUI.func_text,
      id = "func_text",
      notifier = function()
        GUI.func_text = string.upper(GUI.vb.views.func_text.text)
        print("Updated GUI.func_text: " .. GUI.func_text)
      end,
    },
    GUI.vb:button {
      text = "Generate",
      released = function()
        GUI.generate_values()
      end
    } 
  } -- end of row 


    local fx_values_row = GUI.vb:row {
    GUI.vb:text {
      text = "Values",
      tooltip = "FX values to insert",
    },

    button_rotate_left,

    GUI.vb:textfield {
      text = GUI.fx_values_text,
      id = "fx_values_text",
      notifier = function()
        GUI.fx_values_text = string.upper(GUI.vb.views.fx_values_text.text)
        print("Updated GUI.fx_values_text: " .. GUI.fx_values_text)
      end,
    },

    button_rotate_right
  } -- end of row 



  local button_clear = GUI.vb:button {
    text = "Clear",
    released = function()
      GUI.vb.views.lines_list_field.text = ""
    end
  } 

  local button_go = GUI.vb:button {
    text = "Go",
    released = function()
      Core.set_alternate_values(GUI)
      save_values()
      GUI.dialog:close()
    end
  }

  -- ********************************** ROW 
  local content = GUI.vb:row {

    GUI.vb:column {
      spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
      margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

      fx_values_row ,
      function_row,

    },
    GUI.vb:column {
      spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
      margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

      GUI.vb:text {
        text = "Apply to lines:",
        tooltip = "Series of line numbers",
      },

      GUI.vb:multiline_textfield {
        id = "lines_list_field",
        width = 400,
        height = 50,
        text = GUI.lines_list,
        notifier = function()
          GUI.lines_list = GUI.vb.views.lines_list_field.text
        end
      },

      GUI.vb:horizontal_aligner {
        mode = "left",

        button_clear,
        button_go, 
      },
    },

  } -- end of main row


  GUI.dialog = renoise.app():show_custom_dialog(title, content)  

end


-- ======================================================================
GUI.generate_values = function() 

  local current_set = line_nums_to_table(GUI.vb.views.lines_list_field.text)
  -- Need to turn this into a table, then generate new values, then merge the tables, sort, and remove dupes

  local function_str = string.trim(GUI.func_text)

  if U.is_empty_string(function_str) then
    print("Function string is empty, returning.")
    return 
  end

  -- Need to get the new list and populate the text box

  local new_set = Core.new_set_from_funct_string(function_str, current_set)
  print("New, generated, set: ")

  rprint(new_set)

  GUI.vb.views.lines_list_field.text = table.concat(new_set, " ")
  GUI.lines_list  = GUI.vb.views.lines_list_field.text
end

return GUI
