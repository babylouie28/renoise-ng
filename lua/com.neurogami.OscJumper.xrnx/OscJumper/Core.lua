-- Core.lua 
OscJumper = {}

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

function OscJumper.sequence_pos()

  --  local lines_passed = 0 --global buffer!
  --    local song = renoise.song()
  --   local edit_pos = song.transport.edit_pos
  --  local patterns = song.patterns
  local sequence_pos = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]
  print("OscJumper.sequence_pos: ", sequence_pos)
end
