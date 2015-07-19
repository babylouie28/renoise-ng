-- Core.lua 
MasterMuter = {}

MasterMuter.mute_gainer_name = "NG MASTER MUTER"
MasterMuter.gainer = nil

function MasterMuter.setup() 
  local song = renoise.song
  local master = MasterMuter.get_master_track(song) 
  MasterMuter.gainer = MasterMuter.get_muter_gainer(master)
  MasterMuter.prepare_gainer(MasterMuter.gainer)
end

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
  for index, device in ipairs(track.devices) do
    if device.display_name == MasterMuter.mute_gainer_name then -- Skip TrackVolPan device    
      return device
    end
  end

  local gainer = track:insert_device_at("Audio/Effects/Native/Gainer", 2) -- Doesn't like index 1
  gainer.display_name = MasterMuter.mute_gainer_name
  return gainer

end

function MasterMuter.prepare_gainer(gainer) 
  gainer.is_active = false
  --   2 is panning
  --   1 is gain.  Values are from 0 to 1, mapping to the range of -INF .. 0 .. INF
  gainer.parameters[1].value = 0
end

function MasterMuter.manage_master_mute(mute_value)
  print("MasterMuter.manage_master_mute(",mute_value,")" )
  MasterMuter.gainer.is_active = mute_value == 1
end
