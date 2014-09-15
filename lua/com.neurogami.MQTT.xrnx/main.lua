--[[============================================================================
com.neurogami.MQTT.xrnx/main.lua
============================================================================]]--


-- Socket = renoise.Socket

-- global Socket

--[[
Socket = nil

function isPsp() return(Socket ~= nil) end

-- Might need to install LuaSocket for this to work: http://w3.impa.br/~diego/software/luasocket/home.html#download
if (not isPsp()) then
  require("socket")
  require("io")
  require("ltn12")
--require("ssl")
end

function callback(
  topic,    -- string
  message)  -- string

  print("Topic: " .. topic .. ", message: '" .. message .. "'")
end






-- **************************************************************************************************
function subToMqtt() 
print("[mqtt_subscribe v0.2 2012-06-01]")


local MQTT = require("libs/mqtt_library")

MQTT.Utility.set_debug(true) 
  mqtt_client = MQTT.client.create("arcangel.neurogami.com", nil, callback)
  mqtt_client:connect("lua mqtt client")
  mqtt_client:subscribe({"resoise/#"})


  running = true

  while (running) do
    mqtt_client:handler()
    mqtt_client:publish("test/1", "test message")
    socket.sleep(1.0)  -- seconds
  end
end

renoise.tool():add_menu_entry {
  name = "--- Main Menu:Tools:Neurogami MQTT",
  invoke = subToMqtt
}

]]--
