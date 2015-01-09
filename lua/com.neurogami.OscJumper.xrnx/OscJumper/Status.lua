Status = {}

Status.current_pattern = 0 
Status.is_polling = false

Status.polls = {}


function Status.sequence_pos()
  --  local lines_passed = 0 --global buffer!
  --    local song = renoise.song()
  --   local edit_pos = song.transport.edit_pos
  --  local patterns = song.patterns
  --   Status.current_pattern  = renoise.song().sequencer.pattern_sequence[renoise.song().transport.playback_pos.sequence]
  Status.current_pattern  = renoise.SongPos().sequence
  print("Status.sequence_pos: ", Status.current_pattern)
  return Status.current_pattern
end



Status.polls["current_pattern_poll"] = function ()
  local OscMessage = renoise.Osc.Message
  Status.sequence_pos()
  print(" Status.polls.current_pattern_poll = ", Status.current_pattern )
  Status.send_to_client("current_pattern_poll", Status.current_pattern)
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

  interval = interval or 500
  
  Status.polls[poll_id] = assert(loadstring(full_code))
  
  if(renoise.tool():has_timer( Status.polls[poll_id] ) ) then
    print("Remove the poller " .. poll_id " ...")
    renoise.tool():remove_timer( Status.polls[poll_id] )
  end
  
  renoise.tool():add_timer(Status.polls[poll_id], interval)
end


function Status.remove_poll(poll_id)
  if(renoise.tool():has_timer(Status.polls[poll_id])) then
    print("Remove the poller ...")
    renoise.tool():remove_timer(Status.polls[poll_id])
  end

end

function Status.stop_status_poller()
  print("\tStatus.stop_status_poller()")
  --if(renoise.tool():has_timer(Status.polls["current_pattern_poll"])) then
  --  print("Remove the poller ...")
   -- renoise.tool():remove_timer(Status.polls["current_pattern_poll"])
  --end
  
  Status.remove_poll('sequence_pos')
  Status.is_polling = false
end


function Status.start_status_poller(interval)
  interval = interval or 500
  
--  Status.stop_status_poller()
 -- Status.is_polling = true
  print("\t* * * * * * Status.start_status_poller() * * * * * * " )
 -- renoise.tool():add_timer(Status.polls["current_pattern_poll"], interval)
  Status.add_poll('sequence_pos', "Status.sequence_pos()", interval)
    

end

--[[

The idea is to accept an OSC message that contains three things:
* A status polling ID
* A polling interval
* The data to poll for, such as BPM, master volume, track N volume, etc.

Data sent back would return with the polling ID so the client would know what it is.

The ID is a string to make client code more readable. 


Possibility #1: Pass Lua code to define the polling function.

Thing is, `has_timer` expects a function reference, so the function needs to exist somehow.

--]]



