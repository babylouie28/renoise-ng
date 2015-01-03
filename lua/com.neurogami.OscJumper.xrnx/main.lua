--[[======================================================
com.neurogami.OscJumper.xrnx/main.lua
=======================================================]]--

require 'OscJumper/Utils'
require 'OscJumper/Rotator'

attempt_rotate_setup()

require 'OscJumper/Core'
require 'OscJumper/OscDevice'
require 'OscJumper/Configuration'

local osc_client, socket_error = nil
local osc_server, server_socket_error = nil
local osc_device = nil;  

RENOISE_OSC    = nil
CONTROLLER_OSC = nil

function create_osc_server()
  osc_server, server_socket_error = renoise.Socket.create_server(
  configuration.osc_settings.internal.ip.value, 
  configuration.osc_settings.internal.port.value, 
  renoise.Socket.PROTOCOL_UDP)
  
  osc_device = OscDevice()

  RENOISE_OSC    = osc_device:renoise_osc()
  CONTROLLER_OSC = osc_device:controller_osc()

  load_handlers(osc_device)

  if (server_socket_error) then 
    renoise.app():show_warning(("Oh noes! Failed to start the " .. 
    "OSC Jumper OSC server. Error: '%s'"):format(server_socket_error))
    return
  else
    print("Beat Masher has created a osc_server on port ", configuration.osc_settings.internal.port.value )
    osc_server:run(osc_device)
  end

  OscJumper.start_status_poller()
end


renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami OSC Jumper:Start the OSC server ..",
  invoke = create_osc_server
}

require 'OscJumper/Handlers'


