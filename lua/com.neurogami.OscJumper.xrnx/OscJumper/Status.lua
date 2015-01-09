Status = {}

Status.current_pattern = 0 

Status.polls = {}

function Status.sequence_pos()
  print("Execute Status.sequence_pos() ", os.time() )

  Status.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]
  
  -- Hmmm,  This is not the same as the above line.  This line 
  -- here was not updating, though it used to. Why?
  -- Status.current_pattern  = renoise.SongPos().sequence
    
  print("Current Status.sequence_pos: ", Status.current_pattern)
  return Status.current_pattern
end

function Status.send_to_client(poll_id, val)
  local OscMessage = renoise.Osc.Message
  CONTROLLER_OSC:send( OscMessage("/ng/poller", { 
    {tag="s", value=poll_id} ,
    {tag="i", value=val} 
  }))
end


function Status.add_poll(poll_id, code, interval)
  interval = interval or 500
  local full_code = "local v = " .. code .. "\nStatus.send_to_client('" .. poll_id .. "', v )"
  
  print("full_code:\n", full_code)

  if(Status.polls[poll_id]  and renoise.tool():has_timer( Status.polls[poll_id] ) ) then
    print("Remove the poller " .. poll_id " ...")
    renoise.tool():remove_timer( Status.polls[poll_id] )
  end
 
  -- Stuff can go wrong here, though there is no way at
  -- the moment to inform the client of that
  Status.polls[poll_id] = assert(loadstring(full_code))

  renoise.tool():add_timer(Status.polls[poll_id], interval)
end

function Status.remove_poll(poll_id)
  if(  Status.polls[poll_id] and renoise.tool():has_timer(Status.polls[poll_id]) ) then
    print("Remove the poller ...")
    renoise.tool():remove_timer(Status.polls[poll_id])
  end
end

function Status.stop_status_poller()
  print("\tStatus.stop_status_poller()")
  Status.remove_poll('sequence_pos')
  Status.is_polling = false
end

function Status.start_status_poller(interval)
  interval = interval or 500
  print("\t* * * * * * Status.start_status_poller() * * * * * * " )
  Status.add_poll('sequence_pos', "Status.sequence_pos()", interval)
end

