
class 'OscDevice'

function OscDevice:__init()
  -- could pass a server ref or something else here, or simply do nothing
  print(" * * * * * OscJumper -  OscDevice:__init() * * * * * " )

  self.prefix = '/ng'

  self.client = nil
  self.server = nil

  -- preferences.nodes.node2.port.value seems to refer to the default port used by the Renoise OSC server
  -- Is this her to allow this tool to pass messages to the Renoise server?
  self.osc_client = OscClient("127.0.0.1", preferences.nodes.node2.port.value)

  if (self.osc_client == nil ) then 
    renoise.app():show_warning("Warning: OSC Jumper failed to start the internal OSC client")
    self.osc_client = nil
  else
    print("We have self.osc_client = ", self.osc_client )
  end

  self.message_queue = nil
  self.bundle_messages = false
  self.handlers = table.create{}
  self:open()
end



function OscDevice:open()
  print("OscDevice:open()")
end


function OscDevice:_msg_to_string(msg)
  print("OscDevice:_msg_to_string()",msg)

  local rslt = msg.pattern
  for k,v in ipairs(msg.arguments) do
    rslt = ("%s %s"):format(rslt, tostring(v.value))
  end

  return rslt

end


function OscDevice:socket_error(error_message)
  print("OscDevice:socket_error(error_message): %s", error_message)
  -- An error happened in the servers background thread.
end

function OscDevice:socket_accepted(socket)
  print("OscDevice:socket_accepted(socker)")
  -- FOR TCP CONNECTIONS ONLY: called as soon as a new client
  -- connected to your server. The passed socket is a ready to use socket
  -- object, representing a connection to the new socket.
end


--[[   Stuff stolen from Duplex/OscDevice ]]--


--------------------------------------------------------------------------------

-- look up value, once we have unpacked the message

function OscDevice:receive_osc_message(value_str)

  --  local param,val,w_idx,r_char = self.control_map:get_osc_param(value_str)
  --print("*** OscDevice: param,val,w_idx,r_char",param,val,w_idx,r_char)

  if (param) then

    -- take copy before modifying stuff
    --  local xarg = table.rcopy(param["xarg"])
    --  if w_idx then
    --    -- insert the wildcard index
    --    xarg["index"] = tonumber(r_char)
    --   --print('*** OscDevice: wildcard replace param["xarg"]["value"]',xarg["value"])
    --  end
    local message = Message()
    message.context = OSC_MESSAGE
    message.is_osc_msg = true
    -- cap to the range specified in the control-map
    for k,v in pairs(val) do
      val[k] = clamp_value(v,xarg.minimum,xarg.maximum)
    end
    --rprint(xarg)
    -- multiple messages are tables, single value a number...

    message.value = (#val>1) and val or val[1]
    --print("*** OscDevice:receive_osc_message - message.value",message.value)
    -- self:_send_message(message,xarg)
  end

end

--------------------------------------------------------------------------------

function OscDevice:release()
  --[[ if (self.client) and (self.client.is_open) then
  self.client:close()
  self.client = nil
  end
  ]]--

  if (self.server) and (self.server.is_open) then
    if (self.server.is_running) then
      self.server:stop()
    end
    self.server:close()
    self.server = nil
  end

end


--------------------------------------------------------------------------------

-- set prefix for this device (pattern is appended to all outgoing traffic,
-- and also act as a filter for incoming messages). 
-- @param prefix (string), e.g. "/my_device" 

function OscDevice:set_device_prefix(prefix)

  if (not prefix) then 
    self.prefix = ""
  else
    self.prefix = prefix
  end

end


function OscDevice:_unpack_messages(message_or_bundle, messages)

  if (type(message_or_bundle) == "Message") then
    messages:insert(message_or_bundle)

  elseif (type(message_or_bundle) == "Bundle") then
    for _,element in pairs(message_or_bundle.elements) do
      -- bundles may contain messages or other bundles
      self:_unpack_messages(element, messages)
    end

  else
    error("Internal Error: unexpected argument for unpack_messages: "..
    "expected an osc bundle or message")
  end

end

--------------------------------------------------------------------------------

-- create string representation of OSC message:
-- e.g. "/this/is/the/pattern 1 2 3"

function OscDevice:_msg_to_string(msg)

  local rslt = msg.pattern
  for k,v in ipairs(msg.arguments) do
    rslt = ("%s %s"):format(rslt, tostring(v.value))
  end

  return rslt

end


function OscDevice:add_message_handler(pattern, func)
  --if (self.handlers) then
  self.handlers[pattern] = func
  -- end

end




function OscDevice:socket_message(socket, binary_data)

  print("OscDevice:socket_message(socket, binary_data), %s",binary_data)

  --- local prefix = '/renoise'

  -- A message was received from a client: The passed socket is a ready
  -- to use connection for TCP connections. For UDP, a "dummy" socket is
  -- passed, which can only be used to query the peer address and port
  -- -> socket.port and socket.address
  --

  local message_or_bundle, osc_error = renoise.Osc.from_binary_data(binary_data)

  print("Have message_or_bundle ",message_or_bundle)
  if (message_or_bundle) then
    local messages = table.create()
    self:_unpack_messages(message_or_bundle, messages)

    for _,msg in pairs(messages) do
      local value_str = self:_msg_to_string(msg)
      local pattern = msg.pattern

      -- (only if defined) check the prefix:
      -- ignore messages that doesn't match our prefix
      if (self.prefix) then
        local prefix_str = string.sub(value_str,0,string.len(self.prefix))
        if (prefix_str~=self.prefix) then 
          print(" * * * * *  Proxy on  ", pattern, " * * * * ")
          self.osc_client:send(msg)
          return 
        end
        -- strip the prefix before continuing
        value_str = string.sub(value_str,string.len(self.prefix)+1)
        pattern  = string.sub(pattern,string.len(self.prefix)+1)


      end

      if value_str then
        print(" value_str = ",value_str )
        ---- Now we need to parse the string stuff and act on it.
        -- Suppose we have a hash that maps patterns to methods. Can Lua call
        -- methods dynamically?
        --
        if(self.handlers[pattern]) then
          print("Have a handler match on ", pattern)
          print("Have msg.arguments[1][1] ", msg.arguments[1][1])


          rPrint(msg.arguments, nil, "ARGS ");
          self.handlers[pattern](msg.arguments[1].value, msg.arguments[2].value   )
        else
          print(" * * * * *  No handler for  ", pattern, " * * * * ")
        end

        --print("incoming OSC",os.clock(),value_str)
        ----        self:receive_osc_message(value_str)
      end

    end

  else
    print(("OscDevice: Got invalid OSC data, or data which is not " .. 
    "OSC data at all. Error: '%s'"):format(osc_error))    
  end


end

--- Glommed from Duplex
--
class 'OscClient' 

function OscClient:__init(osc_host,osc_port)

  print("OscJumper - OscClient:__init!")

  -- the socket connection, nil if not established
  self._connection = nil

  --print("*** about to connect to the internal osc_server",osc_host,osc_port,type(osc_host),type(osc_port))
  local client, socket_error = renoise.Socket.create_client(osc_host, osc_port, renoise.Socket.PROTOCOL_UDP)
  if (socket_error) then 
    renoise.app():show_warning("Warning: OscJumper failed to start the internal OSC client")
    self._connection = nil
  else
    self._connection = client
    print("+ + +  OscJumper started the internal OscClient",osc_host,osc_port)
  end

end


function OscClient:send(osc_msg)
  self._connection:send(osc_msg)
end


-- How best to collect functions needed to act on renoise.song?
function set_track_parameter(track_index, parameter_name, value)
    -- sequencer + master + sends
    local song = renoise.song
    local num_tracks = song().sequencer_track_count + 1 + song().send_track_count

    if (track_index >= 1 and track_index <= num_tracks) then
      local parameter = song():track(track_index)[parameter_name]
      parameter.value = clamp_value(value, parameter.value_min, parameter.value_max)
    end
  end
