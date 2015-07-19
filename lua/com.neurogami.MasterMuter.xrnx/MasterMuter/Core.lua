-- Core.lua 
MasterMuter = {}

MasterMuter.mute_gainer_name = "MUTE_GAINER"


function MasterMuter.get_master_track(song) 
    local t
      for _,track in ipairs(song().tracks) do
      if track.type == renoise.Track.TRACK_TYPE_MASTER then
        t = track
      end
    end

    return t
end

function MasterMuter.set_up_muter_gainer(track)
  print( "MasterMuter.set_up_muter_gainer(", track, ")" )

  -- rprint(track.available_devices)

-- Get a list of devices. If we find a device with the name "master_mute_gainer"
-- then return.
-- If no such device exists, add a gain device and set the volume to -INF and disable it

for index, device in ipairs(track.devices) do
    if device.name == MasterMuter.mute_gainer_name then -- Skip TrackVolPan device
       return device
    end
  end

-- track.available_devices.
-- local gainer = track:insert_device_at("Audio/Effects/Native/Gainer", 2) -- Doesn't like index 1
   -- local gainer = track:insert_device_at("Audio/Effects/    Native/Gainer", 2) -- Doesn't like index 1
   local gainer = track:insert_device_at("Audio/Effects/Native/Gainer", 2) -- Doesn't like index 1
   print("gainer  = ", gainer)

end

function MasterMuter.manage_master_mute(mute_value)
   
  print("MasterMuter.manage_master_mute(",mute_value,")" )

  local song = renoise.song
    local master = MasterMuter.get_master_track(song) 
    print("master = ", master)

    MasterMuter.set_up_muter_gainer(master)
end

