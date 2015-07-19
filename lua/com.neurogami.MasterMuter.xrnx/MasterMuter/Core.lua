-- Core.lua 
MasterMuter = {}



function MasterMuter.get_master_track(song) 
    local t
      for _,track in ipairs(song().tracks) do
      if track.type == renoise.Track.TRACK_TYPE_MASTER then
        t = track
      end
    end

    return t
end

function MasterMuter.manage_master_mute(mute_value)
    local song = renoise.song
    local master = MasterMuter.get_master_track(song) 
    print("master = ", master)
end

