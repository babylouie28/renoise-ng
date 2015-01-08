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
end



Status.polls["current_pattern_poll"] = function ()
  local OscMessage = renoise.Osc.Message
  local OscBundle = renoise.Osc.Bundle
  Status.sequence_pos()
  print(" Status.polls.current_pattern_poll = ", Status.current_pattern )

  CONTROLLER_OSC:send( OscMessage("/ng/current_pattern", { 
    {tag="i", value=Status.current_pattern} 
  }))
end


function Status.stop_status_poller()
  print("\tStatus.stop_status_poller()")
  if(renoise.tool():has_timer(Status.polls["current_pattern_poll"])) then
    print("Remove the poller ...")
    renoise.tool():remove_timer(Status.polls["current_pattern_poll"])
  end
  Status.is_polling = false
end


function Status.start_status_poller(interval)
  interval = interval or 500
  Status.stop_status_poller()
  Status.is_polling = true
  print("\t* * * * * * Status.start_status_poller() * * * * * * " )
  renoise.tool():add_timer(Status.polls["current_pattern_poll"], interval)
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



