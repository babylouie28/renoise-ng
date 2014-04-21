handlers = { 
  { -- Marks a pattern loop range and  then sets the start of the loop as  the next pattern to play
    pattern = "/loop/schedule",
     handler = function(rstart, rend)
       local song = renoise.song
       print("/loop/schedule! ", rstart, " ", rend)
       song().transport:set_scheduled_sequence(clamp_value(rstart, 1, song().transport.song_length.sequence))
   
       local start_pos = song().transport.loop_start
       start_pos.line = 1; start_pos.sequence = clamp_value(rstart, 1, song().transport.song_length.sequence)

       local end_pos = song().transport.loop_end
       end_pos.line = 1; end_pos.sequence =  clamp_value(rend + 1, 1, 
       song().transport.song_length.sequence + 1)

       song().transport.loop_range = {start_pos, end_pos}
     end
 },

  {  
    -- Instantly jumps from the current pattern/line to given pattern and relative next line.
    -- If the second arg is greater than -1 it schedules that as the next pattern to play, and turns on
    -- block loop for that pattern.
    pattern = "/pattern/into",
     handler = function(pattern_index, stick_to)

    print("Jump into! ", pattern_index)
    local song = renoise.song  
    local pos = renoise.song().transport.playback_pos
    pos.sequence = pattern_index
    song().transport.playback_pos = pos

    if stick_to > -1  then
      renoise.song().transport.loop_pattern = true

      -- This as copied from elsewhere
      local start_pos = song().transport.loop_start
      start_pos.line = 1; start_pos.sequence = clamp_value(stick_to, 1, 
      song().transport.song_length.sequence)

      local end_pos = renoise.song().transport.loop_end
    end_pos.line = 1; end_pos.sequence =  clamp_value(stick_to + 1, 1, song().transport.song_length.sequence + 1)
    renoise.song().transport.loop_range = {start_pos, end_pos}
    renoise.song().transport:set_scheduled_sequence(clamp_value(stick_to, 1, renoise.song().transport.song_length.sequence))
  else
    renoise.song().transport.loop_pattern = false


    -- This was grabbed from a function that handles an default OSC message for 
    -- setting  a pattern loop range.
    -- Seems that if you pass it 0,0 it clears the pattern.
    --        handler = function(rstart, rend)
    local rstart = 0
    local rend = 0
    local start_pos = renoise.song().transport.loop_start
    start_pos.line = 1; start_pos.sequence = clamp_value(rstart, 1, renoise.song().transport.song_length.sequence)

    local end_pos = renoise.song().transport.loop_end
  end_pos.line = 1; end_pos.sequence =  clamp_value(rend + 1, 1, renoise.song().transport.song_length.sequence + 1)

  renoise.song().transport.loop_range = {start_pos, end_pos}
  -- end

end
        end



      }, {
        -- Takes two track numbers and swaps theri voulme settings.
        -- If using this then you need to set up your track pairs so that one is a set volume
        -- and the other is set to 0
        pattern = "/song/swap_volume", 

        handler = function(track1, track2)

          print("swap_volume for ", track1, track2)
          local song = renoise.song  
          local v1 = song().tracks[track1].prefx_volume['value']
          local v2 = song().tracks[track2].prefx_volume['value']
          print("v1 = ", v1)
          print("v2 = ", v2)
          
          set_track_parameter(track1, "prefx_volume", v2)
          set_track_parameter(track2, "prefx_volume", v1)
      end 
    }
  }

    function load_handlers(osc_device)
      for i, h in ipairs(handlers) do
        osc_device:add_message_handler( h.pattern, h.handler )  
      end
    end


