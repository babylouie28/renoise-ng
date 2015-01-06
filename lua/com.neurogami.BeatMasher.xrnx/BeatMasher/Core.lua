-- Core.lua 
BeatMasher = {}

function BeatMasher.song_reset()
  print("song_reset") 
  for i=0,300 do
    renoise.song():undo()
  end
end


function BeatMasher.set_status_polling(bool)
  print("-------------- BeatMasher.set_status_polling(", bool, ") -  bool is type ",type(bool),"------------- ")
 if (bool == true) then
      print("       bool == true      start the status poller!")
   Status.start_status_poller()
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
        {tag="i", value=intrument_index}, {tag="i", value=track_index}, {tag="i", value=midi_notes[tonumber(d2)+1]}  
      } )  )


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



