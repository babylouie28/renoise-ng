-- Core.lua 
BeatMasher = {}

function BeatMasher.song_reset()
  print("song_reset") 
  for i=0,300 do
    renoise.song():undo()
  end
end


function BeatMasher.song_undo()
  print("song_undo") 
  renoise.song():undo()
end


function BeatMasher.song_track_clear(track_number)
  print("song_track_clear(", track_number, ") ") 
  local tracks = renoise.song().tracks
  if (track_index >= 1 and track_index <= #tracks) then
    renoise.song().patterns[1].tracks[track_index]:clear()
  end

end


function BeatMasher.song_save_version()
  print("song_save_version is not ready") -- FIXME

end


function BeatMasher.pattern_rotate(track_num, num_lines)
  print("pattern_rotate(track_num, num_lines) is not ready") -- FIXME

end

function BeatMasher.song_load_by_id(id_number)
  print("song_load_by_id(id_number) is not ready") -- FIXME

end


function BeatMasher.speak_bpm()
  print("speak_bpm is not ready") -- FIXME
end



