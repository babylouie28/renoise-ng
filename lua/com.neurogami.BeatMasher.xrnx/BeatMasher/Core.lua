-- Core.lua 


function copy_device_chain(src_track, target_track)

  --rprint (song.tracks[ sti ].available_devices)
  local device_path

  -- This seems to do OK to copy devices but not device settings
  for dev = 1, #src_track.devices do
    device_path = src_track:device( dev ).device_path
    if ( dev > 1 ) then
      target_track:insert_device_at( device_path, dev )
    end

    target_track.devices[ dev ].active_preset_data = src_track.devices[ dev ].active_preset_data
    target_track.devices[ dev ].is_active = src_track.devices[ dev ].is_active
    target_track.devices[ dev ].active_preset = src_track.devices[ dev ].active_preset
    target_track.devices[ dev ].active_preset_data = src_track.devices[ dev ].active_preset_data
    

  -- This copies all params (it seems) but does not update the preset name displayed.
  -- BUT DOES NOT WORK IF THE PRESET HAS BEEN ACTIVATED!
   -- for ip = 1, #target_track.devices[ dev ].parameters do
     -- target_track.devices[ dev ].parameters[ip] = src_track.devices[ dev ].parameters[ip]
   -- end
   -- TURNS OUT: The copying of active_preset_data does this. :)

  end
end


BeatMasher = {}

function BeatMasher.song_reset()
  print("song_reset") 
  for i=0,300 do
    renoise.song():undo()
  end
end

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


function BeatMasher.song_undo()
  print("song_undo") 
  renoise.song():undo()
end


function BeatMasher.track_select(track_number)
  print("track_select(", track_number, ") ") 
  renoise.song().selected_track_index = track_number
end


function BeatMasher.song_track_clear(track_number)
  print("song_track_clear(", track_number, ") ") 
  local tracks = renoise.song().tracks
  if (track_index >= 1 and track_index <= #tracks) then
    renoise.song().patterns[1].tracks[track_index]:clear()
  end
end


function master_track_index()
  local master_idx = 0
  for i=1, #renoise.song().tracks do
    if renoise.song().tracks[i].type == renoise.Track.TRACK_TYPE_MASTER then
      master_idx = i
    end
  end
  return master_idx
end

-- TODO: Track should go at the end of the grid (i.e. next to the master track)
-- and serve as a backup rather than the target of any mutations.
-- This way you can clone a track off, fuck with the original,
-- and then (if you want) restore the former content.
-- A restore function looks for any <trackname>+[+++] track and
-- works backwards.  Or something.
--
function BeatMasher.clone_track(track_number, mute_source_track)
  print("BeatMasher.clone_track", track_number)
  local new_track_index = master_track_index()

  local new_track = renoise.song():insert_track_at(new_track_index ) 
  local src_track = renoise.song():track(track_number) 

  new_track.name = src_track.name
  
  
  -- Iterate over all patterns in 
  for _p =1, #renoise.song().sequencer.pattern_sequence do
    renoise.song().patterns[_p].tracks[new_track_index]:copy_from( renoise.song().patterns[_p].tracks[track_number])
  end

  -- expose the note columns:
  new_track.visible_note_columns  = src_track.visible_note_columns

  -- Also need to copy over devices 

  copy_device_chain(src_track, new_track)

  src_track.name = src_track.name + "+"
  new_track:mute()

end


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



-- Whole track.
function BeatMasher.stripe_current_pattern_track(remove_every_n)

  print( "BeatMasher.stripe_current_pattern_track(" , remove_every_n , ")" )
  
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

function BeatMasher.song_save_version()
  print("song_save_version is not ready") -- FIXME
end

function BeatMasher.song_load_by_id(id_number)
  print("song_load_by_id(id_number) is not ready") -- FIXME
end

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


-- 
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



