--[[======================================================
com.neurogami.BeatMasher.xrnx/main.lua
=======================================================]]--

RENOISE_OSC    = nil
CONTROLLER_OSC = nil

require 'BeatMasher/Utils'
require 'BeatMasher/Status'
require 'BeatMasher/Rotator'

attempt_rotate_setup()

require 'BeatMasher/Core'
require 'BeatMasher/OscDevice'
require 'BeatMasher/Configuration'

local osc_client, socket_error = nil
local osc_server, server_socket_error = nil
local osc_device = nil

function create_osc_server()
  osc_server, server_socket_error = renoise.Socket.create_server(
  configuration.osc_settings.internal.ip.value, 
  configuration.osc_settings.internal.port.value, 
  renoise.Socket.PROTOCOL_UDP)
  
  osc_device = OscDevice()

  RENOISE_OSC = osc_device:renoise_osc()
  CONTROLLER_OSC = osc_device:controller_osc()

  load_handlers(osc_device)

  if (server_socket_error) then 
    renoise.app():show_warning(("Oh noes! Failed to start the " .. 
    "BeatMasher OSC server. Error: '%s'"):format(server_socket_error))
    return
  else
    print("Beat Masher has created a osc_server on port ", configuration.osc_settings.internal.port.value )
    osc_server:run(osc_device)
  end

  Status.start_status_poller()
end


renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami BeatMasher:Start the OSC server ..",
  invoke = create_osc_server
}

require 'BeatMasher/Handlers'
