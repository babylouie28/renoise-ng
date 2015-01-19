--[[======================================================
com.neurogami.OscJumper.xrnx/main.lua
=======================================================]]--

RENOISE_OSC    = nil
CONTROLLER_OSC = nil
TOOL_NAME = "OscJumper"

require (TOOL_NAME .. '/Utils')
require (TOOL_NAME .. '/Status')
require (TOOL_NAME .. '/Shared')

attempt_rotate_setup()
attempt_randy_setup()

require (TOOL_NAME .. '/Core')
require (TOOL_NAME .. '/OscDevice')
require (TOOL_NAME .. '/Configuration')
require (TOOL_NAME .. '/VolumeJumper')


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
    TOOL_NAME .. " OSC server. Error: '%s'"):format(server_socket_error))
    return
  else
    print(TOOL_NAME, " has created a osc_server on port ", configuration.osc_settings.internal.port.value )
    osc_server:run(osc_device)
  end

end

renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami " .. TOOL_NAME .. ":Start the OSC " .. TOOL_NAME .. " server ..",
  invoke = create_osc_server
}



require (TOOL_NAME .. '/Handlers')

renoise.ng = renoise.ng or {}
renoise.ng[TOOL_NAME] =  TOOL_NAME
rPrint(renoise.ng)

-- Even though this is done in two different tools, each only sees what they created
