-- Core.lua 

require "RandyNoteColumns/Utils"

RandyNoteColumns = {}


RandyNoteColumns.timers = {}
RandyNoteColumns.volume_jumper_timers = {}
RandyNoteColumns.volume_jumper_track_col_odds = {}
RandyNoteColumns.volume_jumper_normalized_col_odds = {}
RandyNoteColumns.volume_jumper_track_odds = {}
RandyNoteColumns.volume_jumper_track_stop_odds = {}
RandyNoteColumns.volume_jumper_track_timer_interval = {}



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
  --local track = renoise.song().tracks[track_index]
  -- local note_cols_num = track.visible_note_columns
  local r = math.random()
  local col_to_solo = RandyNoteColumns.select_note_col(track_index)
  RandyNoteColumns.solo_note_column_volume(track_index, col_to_solo )

end


function RandyNoteColumns.normalize_volume_jumper_track_col_odds(track_index)
  local raw_column_odds = RandyNoteColumns.volume_jumper_track_col_odds[track_index]
  local normalized = {}

  print("normalize_volume_jumper_track_col_odds")

  local sum = 0
  for k,v in pairs(raw_column_odds) do
    sum = sum + v
  end

  for k,v in pairs(raw_column_odds) do
    normalized[k] = v/sum
  end

  rPrint()
  sum = 0
  for k,v in pairs(normalized ) do
    normalized [k] = normalized [k] + sum
    sum = sum + normalized [k]
  end

  RandyNoteColumns.volume_jumper_normalized_col_odds[track_index]  = normalized 

  print(" Should have now created volume_jumper_normalized_col_odds[track_index]  ")
  rPrint(RandyNoteColumns.volume_jumper_normalized_col_odds[track_index]  )
end

function RandyNoteColumns.select_note_col(track_index)
  -- The assumption is that the values have  already beeen normalized
  -- so that they represent a series of values from 0.0 to 1.0.
  -- This function needs to get a rand in that range and then see
  -- where it best fits.
  -- Suppose we have four  odds values:  0.05, 0.55, 0.70, and 1.0
  -- The odds for any given columns is the size of different between it and
  -- the previous number.
  -- That is,  we have a 0.3 gap for the last col, but only 0.05 for the first,
  -- and 0.5 for the second, and 0.15 for the third.
  -- If the rand is, say 0.61, the code needs to look at each of these
  -- "odds"  values and see if it is less than the number.
  --  First hit means a win.
  --
  print("------------ select_note_col for ", track_index, " -------------")

  print(" SELECT A COLUMN USING volume_jumper_normalized_col_odds[track_index] ")
  rPrint(RandyNoteColumns.volume_jumper_normalized_col_odds[track_index])

  local column_odds = RandyNoteColumns.volume_jumper_normalized_col_odds[track_index]
  print("column_odds = ", column_odds )
  local r =  math.random()

  for col,v in pairs(column_odds) do
    print("col", col, " = ", v )
    if (r < v) then
        return col
    end
  end

  return 1 -- What's the best behavior if no other mtch comes up?
end

function RandyNoteColumns.reset_note_volumes(track_index)
  RandyNoteColumns.solo_note_column_volume(track_index, 1)
end

function RandyNoteColumns.clear_vol_column_timers(track_index)
  if(RandyNoteColumns.timers[track_index] and renoise.tool():has_timer( RandyNoteColumns.timers[track_index] ) ) then
    print("Remove the poller " , track_index, " ...")
    renoise.tool():remove_timer( RandyNoteColumns.timers[track_index] )
  end
  RandyNoteColumns.reset_note_volumes(track_index)
end


function RandyNoteColumns.assign_vol_column_timers(timer_interval, trigger_percentage, track_index, note_column_odds, solo_stop_percentage)

  print("assign_vol_column_timers. note_column_odds = ", note_column_odds )
  rPrint(note_column_odds)

  RandyNoteColumns.volume_jumper_track_timer_interval[track_index] = timer_interval
  RandyNoteColumns.volume_jumper_track_col_odds[track_index] = note_column_odds
  RandyNoteColumns.volume_jumper_track_odds[track_index] = trigger_percentage
  RandyNoteColumns.volume_jumper_track_stop_odds[track_index] = solo_stop_percentage

  RandyNoteColumns.normalize_volume_jumper_track_col_odds(track_index)


  local func_string = [[   
  print("Multitimer for track ]] ..track_index .. [[ ")
  local track = renoise.song().tracks[]] .. track_index .. [[]
  local have_solo = track:column_is_muted(1)
  local rand_num = math.random(100)
  local note_cols_num = track.visible_note_columns
  local odds = RandyNoteColumns.volume_jumper_track_odds[]] .. track_index .. [[] 
  local stop_odds = RandyNoteColumns.volume_jumper_track_stop_odds[]] .. track_index .. [[]
  if (not have_solo) then
    print("NO SOLO ...")
    if (odds > rand_num ) then
      print("SET UP SWAP...")
      RandyNoteColumns.solo_note_column(]] .. track_index .. [[)
    end
  else
    print("SOLO IS IN PLAY")
    odds = 50
    if (stop_odds > rand_num ) then
      print("STOP THE SOLO")
      RandyNoteColumns.reset_note_volumes(]] .. track_index ..[[ )
    end
  end
  ]]


  if(RandyNoteColumns.timers[track_index] and renoise.tool():has_timer( RandyNoteColumns.timers[track_index] ) ) then
    print("Remove the poller " ,track_index, " ...")
    renoise.tool():remove_timer( RandyNoteColumns.timers[track_index] )
  end

  -- Stuff can go wrong here, though there is no way at
  -- the moment to inform the client of that
  RandyNoteColumns.timers[track_index] = assert(loadstring(func_string))
  print("Add the poller " , track_index , " ...")
  renoise.tool():add_timer(RandyNoteColumns.timers[track_index], timer_interval)
end




