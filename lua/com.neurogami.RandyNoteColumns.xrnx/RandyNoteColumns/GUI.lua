local view_voljumper_config_dialog 
local configuration_dialog

local SIMPLE_SPACE = 32
local INPUT_FIELD_WIDTH = 32
local VALUEBOX_WIDTH = 56
local DEFAULT_NOTE_COL_ODDS = 20
local TITLE = "Randy Note Columns v1.4"
local MARGIN = 8

print("Loaded ", TITLE)


function configuration_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    configuration_dialog:close()
  elseif key.name == "tab" then
    print("             TAB             ")
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
        text = "Milliseconds for timer interval",
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
        text = "Likelihood for switching (0 to 100)",
        tooltip = "Enter a number from 0 to 100. Higher number means more likely to change note column",
      },
      vb:space { width = SIMPLE_SPACE },

      vb:valuebox {
        value = trigger_percentage,

        min = 0,
        max = 100,

        width = VALUEBOX_WIDTH,

        tooltip = "Enter a number from 0 to 100. Higher number means more likely to change note column",

        tostring = function(value) 
          local _ = math.floor(tonumber(value))
          if (_ > 100 ) then  _ = 100 end
          if (_ < 0 ) then  _ = 0 end
          return ("" .. _)
        end,

        tonumber = function(str) 
          local _ = math.floor(tonumber(str))
          if (_ > 100 ) then  _ = 100 end
          if (_ < 0 ) then  _ = 0 end
          return _
        end,

        notifier = function(v)
          local _ = tonumber(v)
          if (_ > 100 ) then  _ = 100 end
          if (_ < 0 ) then  _ = 0 end
          trigger_percentage = _ 
        end
      },
    },
    vb:horizontal_aligner {
      mode = "justify",

      vb:text {
        text = "Likelihood for resuming default  (1 to 100)",
        tooltip = "Likelihood for resuming default  (1 to 100)",
      },

      vb:space { width = SIMPLE_SPACE },
      vb:valuebox {
        value = solo_stop_percentage,
        tooltip =  "% for unsolo",
        min = 0,
        max = 100,

        width = VALUEBOX_WIDTH,

        tostring = function(value) 
          local _ = math.floor(tonumber(value))
          if (_ > 100 ) then  _ = 100 end
          if (_ < 0 ) then  _ = 0 end
          return ("" .. _)
        end,

        tonumber = function(str) 
          local _ = math.floor(tonumber(str))
          if (_ > 100 ) then  _ = 100 end
          if (_ < 0 ) then  _ = 0 end
          return _
        end,

        notifier = function(v)
          local _ = tonumber(v)
          if (_ > 100 ) then  _ = 100 end
          if (_ < 0 ) then  _ = 0 end
          solo_stop_percentage = _
        end
      },
    }, -- end of horizontal aligner
  } -- end of vb:column

  local note_column_odds = {}

  local default_value = math.floor(100/(note_cols_num-1))
  for i = 2,note_cols_num  do
    note_column_odds[i] = note_cols_odds[i] or default_value 
    local horiz_note_note_form = vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = string.format("Note column %d switching weight", i),
        tooltip = "",
      },
      vb:textfield {
        text = ("" .. note_column_odds[i]),
        tooltip = "Odds of selection",
        width = INPUT_FIELD_WIDTH,
        notifier = function(v)
          note_column_odds["" .. i] = tonumber(v)
        end
      },

    } -- end of horiz aligner
    view_voljumper_config_dialog:add_child(horiz_note_note_form)
  end  -- end of note volume columns 

  local action_buttons = vb:column {
    vb:horizontal_aligner {
      margin = MARGIN,
      mode = "center",    
      vb:button {
        text = "Apply",
        -- color = {227,255,150 },
        released = function()
          configuration_dialog:close()
          RandyNoteColumns.assign_note_column_timer(timer_interval, trigger_percentage, track_index, 
          note_column_odds, solo_stop_percentage)
        end
      },
      vb:space {
        width = SIMPLE_SPACE
      },
      vb:button {
        text = "Clear existing timer",
        -- color = {220, 225, 255 },
        released = function()
          configuration_dialog:close()
          RandyNoteColumns.clear_note_column_timers(track_index)
        end
      },
      vb:space{
        width = SIMPLE_SPACE
      },

      vb:button {
        text = "Cancel",
        -- color = {255, 100, 100 },
        released = function()
          configuration_dialog:close()
        end
      },


    },  -- end H aligner

    vb:horizontal_aligner {
      mode = "center",    
      margin = MARGIN,
      vb:button {
        text = "Load all",
        released = function()
          RandyNoteColumns.load_all()
          configuration_dialog:close()
        end
      },
      vb:space{
        width = SIMPLE_SPACE
      },

      vb:button {
        text = "Save all",
        released = function()
          RandyNoteColumns.save_all()
          configuration_dialog:close()
        end
      },
    },
  }

  view_voljumper_config_dialog:add_child(action_buttons)
  configuration_dialog = renoise.app():show_custom_dialog(TITLE, view_voljumper_config_dialog, configuration_dialog_keyhander)

end
