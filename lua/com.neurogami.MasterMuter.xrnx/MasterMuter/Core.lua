-- Core.lua 
MasterMuter = {}

MasterMuter.mute_gainer_name = "MUTE_GAINER"

MasterMuter.gainer = nil

function MasterMuter.get_master_track(song) 
    local t
      for _,track in ipairs(song().tracks) do
      if track.type == renoise.Track.TRACK_TYPE_MASTER then
        t = track
      end
    end

    return t
end

function MasterMuter.get_muter_gainer(track)
  print( "MasterMuter.get_muter_gainer(", track, ")" )

  -- rprint(track.available_devices)

-- Get a list of devices. If we find a device with the name "master_mute_gainer"
-- then return.
-- If no such device exists, add a gain device and set the volume to -INF and disable it

  for index, device in ipairs(track.devices) do
    if device.display_name == MasterMuter.mute_gainer_name then -- Skip TrackVolPan device    
       return device
    end
  end

-- track.available_devices.
-- local gainer = track:insert_device_at("Audio/Effects/Native/Gainer", 2) -- Doesn't like index 1
   -- local gainer = track:insert_device_at("Audio/Effects/    Native/Gainer", 2) -- Doesn't like index 1
   local gainer = track:insert_device_at("Audio/Effects/Native/Gainer", 2) -- Doesn't like index 1
   print("gainer  = ", gainer)
   gainer.display_name = MasterMuter.mute_gainer_name
--   gainer.is_active = false 
   return gainer

end


function MasterMuter.prepare_gainer(gainer) 
   gainer.is_active = false
--   rprint(gainer.presets)
--   2 is panning
--   1 is gain, though it seems to only accept values of 1 through 4.
   gainer.parameters[1].value = 0
     
end

function MasterMuter.manage_master_mute(mute_value)
   
  print("MasterMuter.manage_master_mute(",mute_value,")" )

  local song = renoise.song
    local master = MasterMuter.get_master_track(song) 
    print("master = ", master)

    MasterMuter.gainer = MasterMuter.get_muter_gainer(master)

    MasterMuter.prepare_gainer(MasterMuter.gainer)
end

