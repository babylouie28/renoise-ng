--[[============================================================================
com.neurogami.OscJumper.xrnx/main.lua
============================================================================]]--


require 'OscJumper/Utils'
require 'OscJumper/Rotator'

attempt_rotate_setup()

require 'OscJumper/OscDevice'
require 'OscJumper/Preferences'


local osc_client, socket_error = nil
local osc_server, server_socket_error = nil
local osc_device = OscDevice()

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
  name = "--- Main Menu:Tools:Neurogami OSC Jumper:Start the OSC server ..",
  invoke = createOSCServer 
}

require 'OscJumper/Handlers'
load_handlers(osc_device)
