--[[============================================================================
com.neurogami.OscJumper.xrnx/main.lua
============================================================================]]--


require 'OscJumper/Utils'
require 'OscJumper/Notifier'
require 'OscJumper/Preferences'


-- NOTE: You need to catch all OSC exceptions because they
-- seem to bork any further OSC behavior.
-- Alos need to see why sometimes the client gets a 
-- "Connection refused" error


_AUTO_RELOAD_DEBUG = true

local osc_client_port = 7119

local osc_client, socket_error = nil
local osc_server, server_socket_error = nil

local osc_device = OscDevice()

function connectOSC()
  osc_client, socket_error = renoise.Socket.create_client(
  "localhost", osc_client_port, renoise.Socket.PROTOCOL_UDP)

  if (socket_error) then 
    renoise.app():show_warning(("Failed to start the " .. 
    "OSC client. Error: '%s'"):format(socket_error))
    return
  end

  print("OscJumper has created osc_client on port ", osc_client_port)

end



function createOSCServer()
    print("================================================== OscJumper! ==================================================")

  osc_server, server_socket_error = renoise.Socket.create_server(
  "localhost", preferences.nodes.node1.port.value, renoise.Socket.PROTOCOL_UDP)

  if (server_socket_error) then 
    renoise.app():show_warning(("Failed to start the " .. 
    "OSC server. Error: '%s'"):format(socket_error))
    return
  else
    print("OscJumper has created a osc_server on port ", preferences.nodes.node1.port.value )
    osc_server:run(osc_device)
  end

end

renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami OSC Jumper:Start OSC server ..",
  invoke = createOSCServer
}

require 'OscJumper/Handlers'

load_handlers(osc_device)


