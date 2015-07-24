-- Core.lua 
MisterMaster = {}

MisterMaster.mute_gainer_name = "NG MASTER MUTER"
MisterMaster.stereo_name = "NG MASTER STEREO"
MisterMaster.gainer = nil
MisterMaster.stereo = nil

function MisterMaster.setup() 
  local song = renoise.song
  local master = MisterMaster.get_master_track(song) 

  MisterMaster.stereo = MisterMaster.get_stereo(master)
  MisterMaster.gainer = MisterMaster.get_muter_gainer(master)
  MisterMaster.prepare_stereo(MisterMaster.stereo)
  MisterMaster.prepare_gainer(MisterMaster.gainer)
end


function MisterMaster.get_master_track(song) 
  local t
  for _,track in ipairs(song().tracks) do
    if track.type == renoise.Track.TRACK_TYPE_MASTER then
      t = track
    end
  end
  return t
end

function MisterMaster.get_muter_gainer(track)
  for index, device in ipairs(track.devices) do
    if device.display_name == MisterMaster.mute_gainer_name then -- Skip TrackVolPan device    
      return device
    end
  end

  local gainer = track:insert_device_at("Audio/Effects/Native/Gainer", 2) -- Doesn't like index 1
  gainer.display_name = MisterMaster.mute_gainer_name
  return gainer

end

function MisterMaster.get_stereo(track)
  for index, device in ipairs(track.devices) do
    if device.display_name == MisterMaster.stereo_name then 
      return device
    end
  end

  local stereo = track:insert_device_at("Audio/Effects/Native/Stereo Expander", 2) -- Doesn't like index 1
  stereo.display_name = MisterMaster.stereo_name
  return stereo

end


function MisterMaster.prepare_gainer(gainer) 
  gainer.is_active = false
  --   2 is panning
  --   1 is gain.  Values are from 0 to 1, mapping to the range of -INF .. 0 .. INF
  gainer.parameters[1].value = 0
end


function MisterMaster.prepare_stereo(stereo) 
  rprint(stereo.parameters)
  stereo.is_active = false
  stereo.parameters[1].value = 0
  stereo.parameters[2].value = 1
  stereo.active_preset_data = "<?xml version='1.0' encoding='UTF-8'?><FilterDevicePreset doc_version='9'>  <DeviceSlot type='StereoExpanderDevice'><IsMaximized>true</IsMaximized><MonoMixMode>L+R</MonoMixMode><StereoWidth><Value>0.0</Value></StereoWidth><SurroundWidth><Value>0.0</Value></SurroundWidth></DeviceSlot></FilterDevicePreset>"
end

function MisterMaster.manage_master_mute(mute_value)
  print("MisterMaster.manage_master_mute(",mute_value,")" )
  MisterMaster.gainer.is_active = mute_value == 1
end

function MisterMaster.manage_master_stereo(stereo_value)
  print("MisterMaster.manage_master_stereo(",stereo_value,")" )
  MisterMaster.stereo.is_active = stereo_value == 1
end

