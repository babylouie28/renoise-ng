-- Core.lua 

require "RandyNoteColumns/Utils"
require "RandyNoteColumns/Dumper"

-- Define a shortcut function for testing
-- See http://lua-users.org/wiki/DataDumper
function dump(...)
  print(DataDumper(...), "\n---")
end




--[[

Notes on saving the current set of rand values.

Option 1: Add a button to save the settings for the current track

Option 2: Add a button that saves everything for the whole song (no matter what track you happen to have selected)

The advantage to #2 is that the full contents of all the RandyNoteColumns.volume_jumper_* stuff gets saved/loaded.

There's no need to pick and choose.  Save it out using the current song file 
name (or some derivative) and allow reloading based on the same.

Is there a reason to save per track?  

Is there a reaosn both can't coexist?



--]]
RandyNoteColumns = {}

configuration = nil

RandyNoteColumns.CONFIG_PREFIX = "RandyConfig"
function RandyNoteColumns.start_fresh()

  RandyNoteColumns.timers = {}
  RandyNoteColumns.volume_jumper_timers = {}
  RandyNoteColumns.volume_jumper_track_col_odds = {}
  RandyNoteColumns.volume_jumper_normalized_col_odds = {}
  RandyNoteColumns.volume_jumper_track_odds = {}
  RandyNoteColumns.volume_jumper_track_stop_odds = {}
  RandyNoteColumns.volume_jumper_track_timer_interval = {}

--  RandyNoteColumns.load_all()

end


-- ******************************************************************
-- Handle clean up when loading a new song

local notifier = {}

function notifier.add(observable, n_function)
  if not observable:has_notifier(n_function) then
    observable:add_notifier(n_function)
  end
end

function notifier.remove(observable, n_function)
  if observable:has_notifier(n_function) then
    observable:remove_notifier(n_function)
  end
end


-- Set up song opening & closing observables
local new_doc_observable = renoise.tool().app_new_document_observable
local close_doc_observable = renoise.tool().app_release_document_observable


-- Set up notifier functions that are called when song opened or closed
local function open_song()
  print("A new song was opened")
  RandyNoteColumns.start_fresh()
end


-- Add the notifiers
notifier.add(new_doc_observable, open_song)

-- ******************************************************************

function RandyNoteColumns.save_all()


  if next(RandyNoteColumns.volume_jumper_track_col_odds) == nil then
    print("There are no time values to save.")
    return
  end

  configuration = renoise.Document.create(RandyNoteColumns.CONFIG_PREFIX  ) {
    volume_jumper_track_col_odds =  DataDumper(RandyNoteColumns.volume_jumper_track_col_odds),
    volume_jumper_normalized_col_odds =  DataDumper(RandyNoteColumns.volume_jumper_normalized_col_odds), 
    volume_jumper_track_odds =  DataDumper(RandyNoteColumns.volume_jumper_track_odds),
    volume_jumper_track_stop_odds =  DataDumper(RandyNoteColumns.volume_jumper_track_stop_odds),
    volume_jumper_track_timer_interval =  DataDumper(RandyNoteColumns.volume_jumper_track_timer_interval)
  }
  configuration:save_as(RandyNoteColumns.config_file_for_current_song())
end

function RandyNoteColumns.config_file_for_current_song()
  local fname = renoise.song().file_name
  local parts = split(fname, "/")
  local xname = parts[#parts]
  return RandyNoteColumns.CONFIG_PREFIX  .. "_" ..  xname .. ".xml"
end

function RandyNoteColumns.have_config_file() 
  local file_name = os.currentdir() .. "/" .. RandyNoteColumns.config_file_for_current_song()
  print(file_name)
  local f=io.open(file_name,"r")
  if f~=nil then io.close(f) return true else return false end
end

function RandyNoteColumns.load_all()
  if RandyNoteColumns.have_config_file() then
    configuration  =  renoise.Document.create(RandyNoteColumns.CONFIG_PREFIX  ) {
      volume_jumper_track_col_odds = DataDumper("foo"),
      volume_jumper_normalized_col_odds = DataDumper("foo"),
      volume_jumper_track_odds =  DataDumper("foo"),
      volume_jumper_track_stop_odds =  DataDumper("foo"),
      volume_jumper_track_timer_interval =  DataDumper("foo"),
    }

    configuration:load_from(RandyNoteColumns.config_file_for_current_song())

    RandyNoteColumns.volume_jumper_track_col_odds = loadstring(configuration.volume_jumper_track_col_odds.value )()
    RandyNoteColumns.volume_jumper_normalized_col_odds = loadstring(configuration.volume_jumper_normalized_col_odds.value)() 
    RandyNoteColumns.volume_jumper_track_odds = loadstring(configuration.volume_jumper_track_odds.value)()  
    RandyNoteColumns.volume_jumper_track_stop_odds = loadstring(configuration.volume_jumper_track_stop_odds.value)()  
    RandyNoteColumns.volume_jumper_track_timer_interval = loadstring(configuration.volume_jumper_track_timer_interval.value)() 
  else
    print("Cannot find ", RandyNoteColumns.config_file_for_current_song())
  end
end

function RandyNoteColumns.solo_note_column_volume(track_index, note_column_index)
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

function RandyNoteColumns.solo_note_column(track_index)
  local r = math.random()
  local col_to_solo = RandyNoteColumns.select_note_col(track_index)
  RandyNoteColumns.solo_note_column_volume(track_index, col_to_solo )
end

function RandyNoteColumns.normalize_volume_jumper_track_col_odds(track_index)
  local raw_column_odds = RandyNoteColumns.volume_jumper_track_col_odds[track_index]
  local normalized = {}

  local sum = 0
  for k,v in pairs(raw_column_odds) do
    sum = sum + v
  end

  for k,v in pairs(raw_column_odds) do
    normalized[k] = v/sum
  end

  sum = 0
  for k,v in pairs(normalized ) do
    normalized [k] = normalized [k] + sum
    sum = sum + normalized [k]
  end

  RandyNoteColumns.volume_jumper_normalized_col_odds[track_index]  = normalized 

end

function RandyNoteColumns.select_note_col(track_index)

  local column_odds = RandyNoteColumns.volume_jumper_normalized_col_odds[track_index]
  local r =  math.random()

  for col,v in pairs(column_odds) do
    if (r < v) then
      return col
    end
  end

  return 1 -- What's the best behavior if no other match comes up?
end

function RandyNoteColumns.reset_note_volumes(track_index)
  RandyNoteColumns.solo_note_column_volume(track_index, 1)
end

function RandyNoteColumns.clear_vol_column_timers(track_index)
  if(RandyNoteColumns.timers[track_index] and renoise.tool():has_timer( RandyNoteColumns.timers[track_index] ) ) then
    renoise.tool():remove_timer( RandyNoteColumns.timers[track_index] )
  end
  RandyNoteColumns.reset_note_volumes(track_index)
end


function RandyNoteColumns.assign_vol_column_timers(timer_interval, trigger_percentage, track_index, note_column_odds, solo_stop_percentage)


  RandyNoteColumns.volume_jumper_track_timer_interval[track_index] = timer_interval
  RandyNoteColumns.volume_jumper_track_col_odds[track_index] = note_column_odds
  RandyNoteColumns.volume_jumper_track_odds[track_index] = trigger_percentage
  RandyNoteColumns.volume_jumper_track_stop_odds[track_index] = solo_stop_percentage

  RandyNoteColumns.normalize_volume_jumper_track_col_odds(track_index)

  local func_string = [[   
  local track = renoise.song().tracks[]] .. track_index .. [[]
  local have_solo = track:column_is_muted(1)
  local rand_num = math.random(100)
  local note_cols_num = track.visible_note_columns
  local odds = RandyNoteColumns.volume_jumper_track_odds[]] .. track_index .. [[] 
  local stop_odds = RandyNoteColumns.volume_jumper_track_stop_odds[]] .. track_index .. [[]
  if (not have_solo) then
    if (odds > rand_num ) then
      RandyNoteColumns.solo_note_column(]] .. track_index .. [[)
    end
  else
    odds = 50
    if (stop_odds > rand_num ) then
      RandyNoteColumns.reset_note_volumes(]] .. track_index ..[[ )
    end
  end
  ]]

  if(RandyNoteColumns.timers[track_index] and renoise.tool():has_timer( RandyNoteColumns.timers[track_index] ) ) then
    renoise.tool():remove_timer( RandyNoteColumns.timers[track_index] )
  end

  -- Stuff can go wrong here, though there is no way at
  -- the moment to inform the client of that
  RandyNoteColumns.timers[track_index] = assert(loadstring(func_string))
  renoise.tool():add_timer(RandyNoteColumns.timers[track_index], timer_interval)
end
