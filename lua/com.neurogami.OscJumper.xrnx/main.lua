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
local osc_device = OscDevice()

function create_osc_server()
  osc_server, server_socket_error = renoise.Socket.create_server(
  configuration.osc_settings.internal.ip.value, 
  configuration.osc_settings.internal.port.value, 
  renoise.Socket.PROTOCOL_UDP)

  if (server_socket_error) then 
    renoise.app():show_warning(("Oh noes! Failed to start the " .. 
    "OSC server. Error: '%s'"):format(socket_error))
    return
  else
    print("OSC Jumper has created a osc_server on port ", configuration.osc_settings.internal.port.value )
    osc_server:run(osc_device)
  end

end

renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami OSC Jumper:Start the OSC server ..",
  -- FIXME This starts tge server no matter if a ser is actually using the tool
  -- Better to tie this to the starting of the OJ server.
  --  Worse, if the config is wonky then the user gets an error message when installing the tool 
  --  and every time the tool is loaded into the menu.
  invoke = create_osc_server
}

require 'OscJumper/Handlers'
load_handlers(osc_device)
