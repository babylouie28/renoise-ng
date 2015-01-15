
local view_voljumper_config_dialog 
local configuration_dialog

local SIMPLE_SPACE = 32
local INPUT_FIELD_WIDTH = 32
local DEFAULT_NOTE_COL_ODDS = 20

function configuration_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    configuration_dialog:close()
  else
    return key
  end
end


function volume_jumper_config() 
  print("volume_jumper_config() ")

  local track_index = renoise.song().selected_track_index

  local timer_interval =  RandyNoteColumns.volume_jumper_track_timer_interval[track_index] or  500
  local trigger_percentage = RandyNoteColumns.volume_jumper_track_odds[track_index] or 25
  local solo_stop_percentage = RandyNoteColumns.volume_jumper_track_stop_odds[track_index] or 30

  local track = renoise.song().tracks[track_index]

  local note_cols_num = track.visible_note_columns
  local note_cols_odds = RandyNoteColumns.volume_jumper_track_col_odds[track_index] or {}
  local vb = renoise.ViewBuilder()

  view_voljumper_config_dialog = vb:column {

    spacing = renoise.ViewBuilder.DEFAULT_CONTROL_SPACING,
    margin = renoise.ViewBuilder.DEFAULT_DIALOG_MARGIN,

    vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = "ms for timer interval",
        tooltip = "ms for timer interval",
      },
      vb:space { width = SIMPLE_SPACE },
      vb:textfield {
        text = ("" .. timer_interval),
        tooltip = "ms for timer interval",
        width = INPUT_FIELD_WIDTH,
        notifier = function(v)
          timer_interval = tonumber(v)
        end
      },
    },
    vb:horizontal_aligner {
      mode = "justify",

      vb:text {
        text = "Percentage for triggering (1 to 100)",
        tooltip = "Percentage for triggering (1 to 100)",
      },
      vb:space { width = SIMPLE_SPACE },
      vb:textfield {
        text = ("" .. trigger_percentage),
        tooltip = "ms for timer interval",
        width = INPUT_FIELD_WIDTH,
        notifier = function(v)
          trigger_percentage = tonumber(v)
        end
      },

    },
    vb:horizontal_aligner {
      mode = "justify",

      vb:text {
        text = "Percentage for unsoloing  (1 to 100)",
        tooltip = "Percentage for unsoloing (1 to 100)",
      },

      vb:space { width = SIMPLE_SPACE },
      vb:textfield {
        text = ("" .. solo_stop_percentage),
        tooltip =  "% for unsolo",
        width = INPUT_FIELD_WIDTH,
        notifier = function(v)
          solo_stop_percentage = tonumber(v)
        end
      },

    }, -- end of horiz aligner

  } -- end of vb:colum

  local note_column_odds = {}

  for i = 2,note_cols_num  do

    note_column_odds[i] = note_cols_odds[i] or DEFAULT_NOTE_COL_ODDS

    local horiz_note_vol_form = vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = string.format("Volume column %d", i),
        tooltip = "",
      },
      vb:textfield {
        text = ("" .. note_column_odds[i]),
        tooltip = "Odds of selection",
        width = INPUT_FIELD_WIDTH,
        notifier = function(v)
          note_column_odds[i] = tonumber(v)
        end
      },

    } -- end of horiz aligner

    view_voljumper_config_dialog:add_child(horiz_note_vol_form)

  end  -- end of note volume columns 

  local action_buttons = vb:horizontal_aligner {
    mode = "center",    
    vb:button {
      text = "Apply",
      color = {227,255,150 },
      released = function()
        configuration_dialog:close()
        RandyNoteColumns.assign_vol_column_timers(timer_interval, trigger_percentage, track_index, note_column_odds, solo_stop_percentage )
      end
    },
    vb:space {
      width = SIMPLE_SPACE
    },
    vb:button {
      text = "Clear existing timers",
      color = {200, 255, 255 },
      released = function()
        configuration_dialog:close()
        RandyNoteColumns.clear_vol_column_timers(track_index)
      end
    },
    vb:space{
      width = SIMPLE_SPACE
    },

    vb:button {
      text = "Cancel",
      color = {255, 200, 200 },
      released = function()
        configuration_dialog:close()
      end
    },
  }
  view_voljumper_config_dialog:add_child(action_buttons)
  configuration_dialog = renoise.app():show_custom_dialog("Volume Jumper", view_voljumper_config_dialog, configuration_dialog_keyhander)
end

