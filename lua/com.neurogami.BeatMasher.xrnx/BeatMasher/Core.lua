-- Core.lua 


BeatMasher = {}

BeatMasher.CLONE_SUFFIX = "+"

-- **********************************************************************************
function BeatMasher.song_reset()
  print("song_reset") 
  for i=0,300 do
    renoise.song():undo()
  end
end

-- **********************************************************************************
function BeatMasher.set_status_polling(bool, interval)
  print("-------------- BeatMasher.set_status_polling(", bool, ") -  bool is type ",type(bool),"------------- ")
  if (bool == true) then
    print("       bool == true      start the status poller!")
    Status.start_status_poller(interval)
  else
    print("  bool == false           STOP THE STATUS POLLER!")
    Status.stop_status_poller()
  end

end


-- **********************************************************************************
function BeatMasher.song_undo()
  print("song_undo") 
  renoise.song():undo()
end


-- **********************************************************************************
function BeatMasher.track_select(track_number)
  print("track_select(", track_number, ") ") 
  renoise.song().selected_track_index = track_number
end


-- **********************************************************************************
function BeatMasher.song_track_clear(track_number)
  print("song_track_clear(", track_number, ") ") 
  local tracks = renoise.song().tracks
  if (track_index >= 1 and track_index <= #tracks) then
    renoise.song().patterns[1].tracks[track_index]:clear()
  end
end


-- **********************************************************************************
function BeatMasher.restore_track(track_number)

  local target_track = nil

  -- get name
  local target_name = renoise.song().tracks[track_number].name

  if BeatMasher.CLONE_SUFFIX ~= string.sub(target_name, -1) then
    print("target_name of '" .. target_name .. "' does not contain '" .. BeatMasher.CLONE_SUFFIX .. "' so cannot revert.")
    return
  end

  local version_name = target_name:sub(1, -2)
  print("Go find earlier version named '" .. version_name  ..   "'")

  -- get earlier version name

  local version_track_index = 0

  for i=1, #renoise.song().tracks do
    if renoise.song().tracks[i].name == version_name  then
      version_track_index = i
    end
  end

  if 0 == version_track_index then
    print("No track named '" .. version_name .. "', exiting.")
    return
  end

  renoise.song():swap_tracks_at(track_number, version_track_index)

  renoise.song().tracks[track_number]:unmute()
  renoise.song():delete_track_at(version_track_index)

end


-- **********************************************************************************
function BeatMasher.clone_track(track_number, mute_source_track)


  print("BeatMasher.clone_track", track_number)
  local new_track_index = U.master_track_index()

  U.clone_track(track_number, new_track_index)

  local src_track = renoise.song():track(track_number) 
  local new_track = renoise.song():track(new_track_index) 

  new_track.name = src_track.name
  new_track.name = src_track.name
  src_track.name = new_track.name .. BeatMasher.CLONE_SUFFIX
  new_track:mute()

end


-- **********************************************************************************
-- Whole track.
function BeatMasher.stripe_track(track_number, remove_every_n)
  print("BeatMasher.stripe_track( ", track_number , ", " , remove_every_n , ") " )
  local track
  for _p =1, #renoise.song().sequencer.pattern_sequence do
    track = renoise.song().patterns[_p].tracks[track_number]
    for _l = 1, #track.lines do
      if (0 == _l % remove_every_n ) then  
        track.lines[_l]:clear()
      end
    end
  end
end

-- **********************************************************************************
-- For the curent PT of the given track, for every mod_num lines, swap lines that are line_gap apart.
function BeatMasher.swap_lines_pattern_track(selected_track_index, mod_num, line_gap)
  --[[

  The plan:

  - Clone the pattern to the end of the song
  - Figure out what lines are to be swapped and create a set of pairs:
  cloned_pattarntrack_num -> src_pattarntrack_num
  - Iterate over that set and copy the lines from the clone to the original pattern track   
  ]]

  local song = renoise.song

  local selected_pattern_index = song().selected_pattern_index
  local new_pattern_index = U.clone_pattern_track_to_end(selected_pattern_index, selected_track_index)

  --      song().selected_sequence_index = new_pattern_index

  local num_pattern_lines = #song().patterns[selected_pattern_index].tracks[selected_track_index].lines
  local swap_pairs = calculate_swap_pairs(num_pattern_lines, mod_num, line_gap)

  -- Iterate over these pairs and do the copying
  local temp_patt_track = song().patterns[new_pattern_index].tracks[selected_track_index]
   local orig_patt_track = song().patterns[ selected_pattern_index ].tracks[ selected_track_index ]
  for i,j in pairs(swap_pairs) do  
    print("Swap " .. tostring(i) .. " -> " .. tostring(j) )
    orig_patt_track:line(i):copy_from( temp_patt_track:line(j) )
  end

  --   Then delete the cloned PT
  song().sequencer:delete_sequence_at(#song().sequencer.pattern_sequence)

  -- and go back to the original sequence
  song().selected_sequence_index = selected_pattern_index   

end

-- **********************************************************************************
function BeatMasher.stripe(track_number, remove_every_n)

  print( "BeatMasher.stripe(" , remove_every_n , ")" )

  local _ti = renoise.song().selected_track_index
  local _pi   = renoise.song().selected_pattern_index
  local _tp   = renoise.song().patterns[_pi].tracks[_ti]
  local lines_in_pattern = renoise.song().patterns[_pi].number_of_lines

  for _l=1,lines_in_pattern do   
    if (0 == _l % remove_every_n ) then  
      _tp.lines[_l]:clear()
    end
  end

end


-- **********************************************************************************
function BeatMasher.trigger_note(client_renoise, instrument, track, note,  velocity)
  local OscMessage = renoise.Osc.Message
  client_renoise:send( OscMessage("/renoise/trigger/note_on", { 
    {tag="i", value=track}, {tag="i", value=instrument}, {tag="i", value=note}, {tag="i", value=velocity} 
  }))        
  sleep(1.5) 
  client_renoise:send( OscMessage("/renoise/trigger/note_off", { 
    {tag="i", value=track}, {tag="i", value=instrument}, {tag="i", value=note} 
  } )  )

end


-- **********************************************************************************
function BeatMasher.speak_bpm(client_renoise, track_index, instrument_index)
  print("speak_bpm") -- FIXME

  local OscMessage = renoise.Osc.Message
  local OscBundle  = renoise.Osc.Bundle
  local bpm_int    = renoise.song().transport.bpm  
  local bpm_string = tostring(bpm_int)

  --                   0    1    2   3    4    5   6   7   8   9 
  local midi_notes = { 48, 49,  50,  51,  52,  53, 54, 55, 56, 57}
  local d1, d2, d3
  print("triggered BPM query ")
  print(tostring(track_index))
  print( ("Try to speak %s" ):format(bpm_string))

  -- /renoise_response/transport/bpm

  if  bpm_int < 100  then 
    print( ("Under 100: Split up  %s" ):format(bpm_string) )
    d1,d2 = bpm_string:match('(%d)(%d)')
    print( ("Speak %s %s, track %d, intr %s "):format(d1, d2, track_index, instrument_index) )

    client_renoise:send( OscMessage("/renoise/trigger/note_on", { 
      {tag="i", value=instrument_index}, {tag="i", value=track_index}, {tag="i", value=midi_notes[tonumber(d1)+1]}, {tag="i", value=125} 
    }))        
    sleep(1)
    client_renoise:send( OscMessage("/renoise/trigger/note_off", { 
      {tag="i", value=instrument_index}, {tag="i", value=track_index}, {tag="i", value=midi_notes[tonumber(d1)+1]}  
    } )  )

    print("Now speak the second digit ,,,")

    client_renoise:send( OscMessage("/renoise/trigger/note_on", { 
      {tag="i", value=track_index}, {tag="i", value=instrument_index}, {tag="i", value=midi_notes[tonumber(d2)+1]}, {tag="i", value=125} 
    }))
    sleep(1)
    client_renoise:send( OscMessage("/renoise/trigger/note_off", { 
      {tag="i", value=track_index}, {tag="i", value=instrument_index}, {tag="i", value=midi_notes[tonumber(d2)+1]}  
    }))

  else
    print( ("100 or greater: Split up  %s" ):format(bpm_string) )
    d1,d2,d3 = bpm_string:match('(%d)(%d)(%d)')
    print( ("Speak %s %s %s"):format(d1, d2, d3) )

    client_renoise:send( OscMessage("/renoise/trigger/note_on", { 
      {tag="i", value=track_index}, {tag="i", value=instrument_index}, {tag="i", value=midi_notes[tonumber(d1)+1]}, {tag="i", value=125} }))        
      sleep(1)
      client_renoise:send( OscMessage("/renoise/trigger/note_off", { 
        {tag="i", value=track_index}, {tag="i", value=instrument_index}, {tag="i", value=midi_notes[tonumber(d2)+1]} 
      } )  )


      client_renoise:send( OscMessage("/renoise/trigger/note_on", { 
        {tag="i", value=track_index}, {tag="i", value=instrument_index}, {tag="i", value=midi_notes[tonumber(d2)+1]}, {tag="i", value=125} 
      }))
      sleep(1)
      client_renoise:send( OscMessage("/renoise/trigger/note_off", { 
        {tag="i", value=track_index}, {tag="i", value=instrument_index}, {tag="i", value=midi_notes[tonumber(d2)+1]} 
      }))


      client_renoise:send( OscMessage("/renoise/trigger/note_on", { 
        {tag="i", value=track_index}, {tag="i", value=instrument_index}, {tag="i", value=midi_notes[tonumber(d3)+1]}, {tag="i", value=125}
      }))
      sleep(1)
      client_renoise:send( OscMessage("/renoise/trigger/note_off", { 
        {tag="i", value=track_index}, {tag="i", value=instrument_index}, {tag="i", value=midi_notes[tonumber(d3)+1]}  
      }))

    end

    --[[

    TODO: Some of these handlers should be sending a reply
    back to the client to provide status messages.

    print("Send info OSC message")
    client:send(
    OscMessage("/info", { 
      {tag="s", value=tostring(renoise.song().transport.bpm)} 
    })
    )
    print("OSC message sent")

    ]]--

  end



