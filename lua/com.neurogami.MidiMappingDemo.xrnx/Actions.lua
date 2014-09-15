local send_tracks = nil
local send_track_count = 0

local app = renoise.app
local song = renoise.song

local verbose = true

function verbalize(s)
if verbose  then
  print(s)
end
end

function get_send_tracks() 
  verbalize("Go get send tracks")
  local send_tracks = {}

  local send_track_count = 0
  for i = 1,#renoise.song().tracks do
    if renoise.song().tracks[i].type == renoise.Track.TRACK_TYPE_SEND  then
      send_track_count = send_track_count + 1
      verbalize("Storing send track: " .. renoise.song().tracks[i].name)
      send_tracks[send_track_count] =  renoise.song().tracks[i]
    end
  end

  return send_tracks, send_track_count
end

function send_switch(track_index, send_index)
  local device_index
  local device
  verbalize( ( "Triggered send_switch for track index %d, send index %d"):format(track_index, send_index) )

  local tracks = song().tracks

  if ( send_tracks == nil ) then
    send_tracks, send_track_count = get_send_tracks()

  else
    verbalize("send_tracks = ")
    verbalize(send_tracks)
  end

  if (track_index > 0 and track_index <= #tracks) then
    print("Found the track!")
    local send_device = nil
    local devices = tracks[track_index].devices

    if (#devices > 0 ) then
      local i, j
      for device_idx, device in ripairs(devices) do
        print(device.display_name)
        i, j = string.find(device.display_name, "send_")
        if i == 1 then
          local send_tag = string.gsub(device.display_name, "send_", "")
          print("Found a send device with tag " .. send_tag )
          send_device  = device
          local idx
          print( ("We have %d send tracks"):format(send_track_count ) )
          local match_count = 0;
          for idx = 1, send_track_count do
            print("Check name of send track '" .. send_tracks[idx].name .. "' for '" .. send_tag .. "'")
            i, j = string.find( send_tracks[idx].name, send_tag)
            if i then
              print( ("Match count = %d").format(match_count))
              match_count = match_count + 1
              print("- - - - - - We have a send track tag match on send track " .. send_tracks[idx].name )
              print(("Matched send track is idx %d and match_count %d "):format(idx, match_count) )
              -- If this send track matches on the tag and is the correct index
              -- then we need to set the device to use that send track
              if match_count == send_index then

                for __,param in ipairs(device.parameters) do
                  print(param.name)
                  if  param.name == "Receiver" then
                    -- Tables use 1-based indexing, so send_tables needs to start at 1
                    -- but when using a send track index the indexing assigned needs to
                    -- be 0-based
                    param.value = idx-1 
                    print("Updated value of  device " .. device.display_name )
                    break
                  end
                end

                break
              end
            end
          end
          break
        end
      end
    end
  else
    print("That index is out of range: %d"):format(track_index)
  end
end

