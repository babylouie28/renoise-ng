-- Core.lua 

require "OscJumper/Utils"

OscJumper = {}


OscJumper.timers = {}

function OscJumper.solo_vol_timer(track_index, column_index)
  print("------- OscJumper.solo_vol_timer(", track_index, ", ", column_index, ", ) ------------" )
  local interval = 500

  local func_string = [[   print("Timer for track ]] ..track_index .. [[ ")
  local track = renoise.song().tracks[]] .. track_index .. [[]
  local note_cols_num = track.visible_note_columns
 
  local have_solo = track:column_is_muted(1)
  
  local rand_num = math.random(100)
  local odds = 8
  if (not have_solo) then
      print("NO SOLO ...")
    if (odds > rand_num ) then
      print("SET UP SWAP...")
      for i = 1,note_cols_num  do
        if (i == ]] .. column_index .. [[ ) then
          track:mute_column(i, false)
        else
          track:mute_column(i, true)
        end
      end 
    end
  else
      print("SOLO IS IN PLAY")
    odds = 50
    if (odds > rand_num ) then
      print("STOP THE SOLO")
      for i = 1,note_cols_num  do
        if (i == 1 ) then
          track:mute_column(i, false)
        else
          track:mute_column(i, true)
        end
      end
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
  renoise.tool():add_timer(OscJumper.timers[track_index], interval)
end

function OscJumper.solo_vol(track_index, column_index)
  local track = renoise.song().tracks[track_index]
  local note_cols_num = track.visible_note_columns
  for i = 1,note_cols_num  do
    if (i == column_index ) then
      track:mute_column(i, false)
    else
      track:mute_column(i, true)
    end
  end
end


function OscJumper.loop_schedule(range_start, range_end)
  local song = renoise.song
  print("/loop/schedule! ", range_start, " ", range_end)
  song().transport:set_scheduled_sequence(clamp_value(range_start, 1, song().transport.song_length.sequence))
  local pos_start = song().transport.loop_start
  pos_start.line = 1; pos_start.sequence = clamp_value(range_start, 1, song().transport.song_length.sequence)
  local pos_end = song().transport.loop_end
  pos_end.line = 1; pos_end.sequence =  clamp_value(range_end + 1, 1, 
  song().transport.song_length.sequence + 1)
  song().transport.loop_range = {pos_start, pos_end}
end


function  OscJumper.pattern_into(pattern_index, stick_to)
  print("pattern into ", pattern_index)
  local song = renoise.song  
  local pos = renoise.song().transport.playback_pos
  pos.sequence = pattern_index
  song().transport.playback_pos = pos

  if stick_to > -1  then
    renoise.song().transport.loop_pattern = true
    local pos_start = song().transport.loop_start
    pos_start.line = 1; pos_start.sequence = clamp_value(stick_to, 1, song().transport.song_length.sequence)
    local pos_end = renoise.song().transport.loop_end
    pos_end.line = 1; pos_end.sequence =  clamp_value(stick_to + 1, 1, song().transport.song_length.sequence + 1)
    renoise.song().transport.loop_range = {pos_start, pos_end}
    renoise.song().transport:set_scheduled_sequence(clamp_value(stick_to, 1, renoise.song().transport.song_length.sequence))
  else
    renoise.song().transport.loop_pattern = false
    -- Seems that if you pass it 0,0 it clears the pattern.
    local range_start = 0
    local range_end = 0
    local pos_start = renoise.song().transport.loop_start
    pos_start.line = 1; pos_start.sequence = clamp_value(range_start, 1, renoise.song().transport.song_length.sequence)
    local pos_end = renoise.song().transport.loop_end
    pos_end.line = 1; pos_end.sequence =  clamp_value(range_end + 1, 1, renoise.song().transport.song_length.sequence + 1)
    renoise.song().transport.loop_range = {pos_start, pos_end}
  end
end


