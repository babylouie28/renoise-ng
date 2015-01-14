-- Consider how to put this into a module or something

volume_jumper_timers = {}
volume_jumper_track_col_odds = {}
volume_jumper_track_odds = {}
volume_jumper_track_stop_odds = {}

local view_voljumper_config_dialog 
local configuration_dialog

local SIMPLE_SPACE = 32
local INPUT_FIELD_WIDTH = 32

function configuration_dialog_keyhander(dialog, key)
  if key.name == "esc" then
    configuration_dialog:close()
  else
    return key
  end
end

function reset_note_volumes(track_index)
  solo_note_column_volume(track_index, 1)
end

function solo_note_column_volume(track_index, note_column_index)
  local track = renoise.song().tracks[track_index]
  local note_cols_num = track.visible_note_columns

  for i = 1,note_cols_num  do
    if (i == note_column_index ) then
      track:mute_column(i, false)
    else
      track:mute_column(i, true)
    end
  end

end

function solo_note_column(track_index)
  local jump_odds   = volume_jumper_track_odds[track_index]
  local column_odds = volume_jumper_track_col_odds[track_index]
  local track = renoise.song().tracks[track_index]
  local note_cols_num = track.visible_note_columns

  print("solo_note_column(", track_index ,"). column_odds = ", column_odds )

  local r = math.random()

  -- FIXME Need to code the real function to 
  -- return a column number based on the percentages
  -- The function needs to account for
  -- actual location: col 1 always the "no solo" value
  local col_to_solo = select_note_col(track_index)

  solo_note_column_volume(track_index, col_to_solo )

end

function volume_jumper_config() 
  print("volume_jumper_config() ")

  local timer_interval = 1000
  local trigger_percentage = 10
  local solo_stop_percentage = 30
  local track_index = renoise.song().selected_track_index
  local track = renoise.song().tracks[track_index]
  local note_cols_num = track.visible_note_columns

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

    local horiz_note_vol_form = vb:horizontal_aligner {
      mode = "justify",
      vb:text {
        text = string.format("Volume column %d", i),
        tooltip = "",
      },
      vb:textfield {
        text = "20",
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
        assign_vol_column_timers(timer_interval, trigger_percentage, track_index, note_column_odds, solo_stop_percentage )
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
        clear_vol_column_timers(track_index)
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

function select_note_col(track_index)
  return 2
end

function clear_vol_column_timers(track_index)
  if(OscJumper.timers[track_index] and renoise.tool():has_timer( OscJumper.timers[track_index] ) ) then
    print("Remove the poller " , track_index, " ...")
    renoise.tool():remove_timer( OscJumper.timers[track_index] )
  end
  reset_note_volumes(track_index)
end

function assign_vol_column_timers(timer_interval, trigger_percentage, track_index, note_column_odds, solo_stop_percentage)

  volume_jumper_track_col_odds[track_index] = note_column_odds
  volume_jumper_track_odds[track_index] = trigger_percentage
  volume_jumper_track_stop_odds[track_index] = solo_stop_percentage


  -- NEED TO ADD SOMETHING TO DETERMINE WHEN TO STOP THE SOLOED COLUMN !!!!

  local func_string = [[   

  print("Multitimer for track ]] ..track_index .. [[ ")

  local track = renoise.song().tracks[]] .. track_index .. [[]

  local have_solo = track:column_is_muted(1)
  local rand_num = math.random(100)
  local note_cols_num = track.visible_note_columns

  local odds = volume_jumper_track_odds[]] .. track_index .. [[] 
  local stop_odds = volume_jumper_track_stop_odds[]] .. track_index .. [[]
  if (not have_solo) then
    print("NO SOLO ...")
    if (odds > rand_num ) then
      print("SET UP SWAP...")
      solo_note_column(]] .. track_index .. [[)
    end
  else
    print("SOLO IS IN PLAY")
    odds = 50
    if (stop_odds > rand_num ) then
      print("STOP THE SOLO")
      solo_note_column_volume(]] .. track_index ..[[, 1 )
    end
  end
  ]]


  if(OscJumper.timers[track_index] and renoise.tool():has_timer( OscJumper.timers[track_index] ) ) then
    print("Remove the poller " .. track_index " ...")
    renoise.tool():remove_timer( OscJumper.timers[track_index] )
  end

  -- Stuff can go wrong here, though there is no way at
  -- the moment to inform the client of that
  OscJumper.timers[track_index] = assert(loadstring(func_string))
  print("Add the poller " , track_index , " ...")
  renoise.tool():add_timer(OscJumper.timers[track_index], timer_interval)
end





