--[[============================================================================
com.neurogami.RawMidi.xrnx/main.lua
============================================================================]]--

function showUI() 
  local ui_dialog = nil
  local vb = renoise.ViewBuilder()
  local DIALOG_MARGIN = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN
  local CONTENT_SPACING = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING

  local dialog_title = "Raw MIDI value entry"
  local note_value_from_text


  local function insert_note()
          print(" * * insert_note() will insert ", note_value_from_text )
          local rs = renoise.song()  
          local edit_pos = rs.transport.edit_pos.line
          local track = rs.selected_track
          local pattern = rs.selected_pattern
          local pattern_track = rs.selected_pattern_track
          local number_of_lines = pattern.number_of_lines

          local note_column_index = 1

          local note = pattern_track:line(edit_pos):note_column(note_column_index)

          print("note.note_value  = " , note.note_value  )
          note.note_value = note_value_from_text

        end
  local dialog_content =  vb:column {

    vb:row { 
      margin = DIALOG_MARGIN,
      spacing = CONTENT_SPACING,

      vb:text {
        text = "Enter raw MIDI note value:"
      }  , vb:textfield {
        value = "",
        width = 90,
        notifier = function(v)
          print("We have text " , v )
          note_value_from_text = v + 0 
        end
    
      }
    } ,

    vb:horizontal_aligner {
      mode = "center",

      vb:button {
        text = "Insert",
        notifier = insert_note
      },

      vb:button {
        text = "Close",
        notifier = function()
          print("XXX Close has been triggered XXX")
          ui_dialog:close()
        end
      }

    }
  }


  local function key_handler(dialog, key)
    print("key_handler: ", key )
    if (key.name == "esc") then
      dialog:close()
    elseif (key.name == "return") then
      print("Return: Call insert_note()")
      insert_note()
    else
      return key
    end
  end

  ui_dialog  = renoise.app():show_custom_dialog( dialog_title, dialog_content, key_handler)

end

renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami Raw MIDI Value Entry",
  invoke = showUI
}
