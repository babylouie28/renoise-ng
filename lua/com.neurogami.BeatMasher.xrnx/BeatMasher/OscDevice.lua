-- OscDevices.lua
class 'OscDevice'

function OscDevice:__init()
  print(" * * * * * ", TOOL_NAME, " -  OscDevice:__init() * * * * * " )

  self.prefix = '/ng'

  self.client = nil
  self.server = nil

  self.osc_client = OscClient(configuration.osc_settings.renoise.ip.value, configuration.osc_settings.renoise.port.value)
  self.osc_controller_client = OscClient(configuration.osc_settings.controller.ip.value, configuration.osc_settings.controller.port.value)
  
  if (self.osc_client == nil ) then 
    renoise.app():show_warning("Warning: ", TOOL_NAME, " failed to start the internal OSC client")
--    self.osc_client = nil
  else
    print("We have self.osc_client = ", self.osc_client )
  end

    if (self.osc_controller_client == nil ) then 
    renoise.app():show_warning("OscDevice Warning: OSC Jumper failed to start the controller OSC client")
--    self.osc_controller_client = nil
  else
    print("We have self.osc_controller_client = ", self.osc_controller_client )
  end


  self.message_queue = nil
  self.bundle_messages = false
  self.handlers = table.create{}
  self:open()
  print("Finished creating OscDevice instance")
end

function OscDevice:renoise_osc()
  return self.osc_client
end

function OscDevice:controller_osc()
  return self.osc_controller_client
end

function OscDevice:open()
  print("OscDevice:open()")
end

function OscDevice:map_args(osc_args)
  local arg_vals = {}

  for k,v in ipairs(osc_args) do
    table.insert(arg_vals, v.value)
  end
 
  return arg_vals
end

function OscDevice:_msg_to_string(msg)
  local rslt = msg.pattern
  for k,v in ipairs(msg.arguments) do
    rslt = ("%s %s"):format(rslt, tostring(v.value))
  end
  return rslt
end


function OscDevice:socket_error(error_message)
  print("OscDevice:socket_error(error_message): %s", error_message)
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

--[[


]]--
function OscDevice:add_message_handler(pattern, func)
  self.handlers[pattern] = func
end




function OscDevice:socket_message(socket, binary_data)
  print("OscDevice:socket_message(socket, binary_data), %s",binary_data)

  local rns_prefix = '/renoise'

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
        local have_pref  = string.find(value_str, (self.prefix .. "/"), 1, true)
        local have_rns_pref  = string.find(value_str, "/renoise/", 1, true)
        print("----------- ", value_str, " has prefix str? ", have_pref, ". Have have_rns_pref? ", have_rns_pref , " --------------")

        if (not have_pref) then 
          print(" * * * * *  Proxy on  ", pattern, " , with pattern = ", pattern, " * * * * ")
          if (have_rns_pref)then
            print(" # # # renoise OSC: ", value_str, " # # # ")
            self.osc_client:send(msg)
          end
          return 
        end
        
        -- strip the prefix before continuing

        value_str = string.sub(value_str,string.len(self.prefix)+1)
        pattern  = string.sub(pattern,string.len(self.prefix)+1)
      end

      if value_str then
        print(" value_str = ",value_str )
        if(self.handlers[pattern]) then
          print("\n_________________________________________________\nHave a handler match on ", pattern)
          local vals = OscDevice:map_args(msg.arguments)
          local res, err = pcall( self.handlers[pattern], unpack(vals) )
          if res then
            print("Handler worked!");
              else
            print("Handler error: ", err);
          end
        else
          print(" * * * * *  No handler for  ", pattern, " * * * * ")
        end

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

  print( TOOL_NAME, " - OscClient:__init!")

  -- the socket connection, nil if not established
  self._connection = nil

  local client, socket_error = renoise.Socket.create_client(osc_host, osc_port, renoise.Socket.PROTOCOL_UDP)
  if (socket_error) then 
    renoise.app():show_warning("Warning: ", TOOL_NAME, " failed to start the internal OSC client")
    self._connection = nil
  else
    self._connection = client
    print("+ + +  ", TOOL_NAME, " started the internal OscClient",osc_host,osc_port)
  end

end

function OscClient:send(osc_msg)
  self._connection:send(osc_msg)
end


