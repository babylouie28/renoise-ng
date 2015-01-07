Status = {}

Status.current_pattern = 0 
Status.is_polling = false

function Status.sequence_pos()
  --  local lines_passed = 0 --global buffer!
  --    local song = renoise.song()
  --   local edit_pos = song.transport.edit_pos
  --  local patterns = song.patterns
  --   Status.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]
  Status.current_pattern  = renoise.SongPos().sequence
  print("Status.sequence_pos: ", Status.current_pattern)
end


function Status.status_poller()
  local OscMessage = renoise.Osc.Message
  local OscBundle = renoise.Osc.Bundle
  Status.sequence_pos()
  print("Status.status_poller. Status.current_pattern = ", Status.current_pattern )

  CONTROLLER_OSC:send( OscMessage("/ng/current_pattern", { 
    {tag="i", value=Status.current_pattern} 
  }))
end


function Status.stop_status_poller()
  print("\tStatus.stop_status_poller()")
  if(renoise.tool():has_timer(Status.status_poller)) then
    print("Remove the poller ...")
    renoise.tool():remove_timer(Status.status_poller)
  end
  Status.is_polling = false
end


function Status.start_status_poller(interval)
  interval = interval or 500
  Status.stop_status_poller()
  Status.is_polling = true
  print("\t* * * * * * Status.start_status_poller() * * * * * * " )
  renoise.tool():add_timer(Status.status_poller, interval)
end


