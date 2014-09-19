HANDLER_PREFIX = "handler_"

function handler_64_on(message, midi_out_device)
  send_switch(5, 1)
  local msg = {0x0, message[2], message[3]}
  --midi_out_device:send(msg)
  midi_out_device:send(message)

  print("     handler_64_on()   ")
end


function handler_64_off(message, midi_out_device)
  midi_out_device:send(message)
  print("     handler_64_off()   ")
end


function handler_65_on(message, midi_out_device)
  print("     handler_65_on()   ")
  midi_out_device:send(message)
  send_switch(5, 2)
end


function handler_65_off(message, midi_out_device)
  print("     handler_65_off()   ")
  midi_out_device:send(message)
end

function handler_schedule_loop(args)

  local rstart = tonumber(args[1])
  local rend = tonumber(args[2])

  local song = renoise.song
  print("handler_schedule_loop! ", rstart, " ", rend)
  song().transport:set_scheduled_sequence(clamp_value(rstart, 1, song().transport.song_length.sequence))

  local pos_start = song().transport.loop_start
  pos_start.line = 1; pos_start.sequence = clamp_value(rstart, 1, song().transport.song_length.sequence)

  local pos_end = song().transport.loop_end

  pos_end.line = 1
  pos_end.sequence = clamp_value(rend + 1, 1, 
  song().transport.song_length.sequence + 1)

  song().transport.loop_range = {pos_start, pos_end}
end


function handler_jump(args)
  print(("sysex_JUMP has args size %s"):format(#args) )

  local pattern_index = tonumber(args[1])
  local stick_to = tonumber(args[2])

  print("Jump into! ", pattern_index)
  local song = renoise.song 
  local pos = renoise.song().transport.playback_pos
  pos.sequence = pattern_index
  song().transport.playback_pos = pos

  if stick_to > -1 then
    renoise.song().transport.loop_pattern = true
    local pos_start = song().transport.loop_start
    pos_start.line = 1; pos_start.sequence = clamp_value(stick_to, 1, 
    song().transport.song_length.sequence)

    local pos_end = renoise.song().transport.loop_end
    pos_end.line = 1; pos_end.sequence = clamp_value(stick_to + 1, 1, song().transport.song_length.sequence + 1)
    renoise.song().transport.loop_range = {pos_start, pos_end}
    renoise.song().transport:set_scheduled_sequence(clamp_value(stick_to, 1, renoise.song().transport.song_length.sequence))
  else
    renoise.song().transport.loop_pattern = false

    -- This was grabbed from a function that handles a default OSC message for 
    -- setting a pattern loop range.
    -- Seems that if you pass it 0,0 it clears the pattern.
    --    handler = function(rstart, rend)
      local rstart = 0
      local rend = 0
      local pos_start = renoise.song().transport.loop_start
      pos_start.line = 1; pos_start.sequence = clamp_value(rstart, 1, renoise.song().transport.song_length.sequence)

      local pos_end = renoise.song().transport.loop_end
      pos_end.line = 1; pos_end.sequence = clamp_value(rend + 1, 1, renoise.song().transport.song_length.sequence + 1)

      renoise.song().transport.loop_range = {pos_start, pos_end}
    end
  end

  -- You need to have autoseek turned on for any track using long-ish samples, otherwise
  -- if you unmute after the sample has been triggered you will not hear it until it gets
  -- triggered again.  
  function handler_swap_mute(args) 
    local track1 = tonumber(args[1])
    local track2 = tonumber(args[2])

    local muted_track = track1



    -- renoise.Track.MUTE_STATE_MUTED


    local song = renoise.song 
    print(("track %d mute state: %d (compate to %d"):format(track1 , renoise.song().tracks[track1].mute_state , renoise.Track.MUTE_STATE_ACTIVE ) ) 


    if (renoise.song().tracks[track1].mute_state == renoise.Track.MUTE_STATE_ACTIVE) then           
      print("swap_mute for ", track2, track1)
      song().tracks[track1]:mute()
      song().tracks[track2]:unmute()


    else 
      print("swap_mute for ", track1, track2)

      song().tracks[track2]:mute()
      song().tracks[track1]:unmute()

    end


  end 
