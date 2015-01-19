-- The ides is to have  place to attempt loading 
-- files that belong to other tools


local RANGE_WHOLE_SONG = 1
local RANGE_WHOLE_PATTERN = 2
local RANGE_TRACK_IN_SONG = 3
local RANGE_TRACK_IN_PATTERN = 4
local RANGE_SELECTION_IN_PATTERN = 5


have_rotator = false
have_randy = false

function rotate_setup()
  package.path = "../com.renoise.PatternRotate.xrnx/?.lua;" .. package.path
  require "pattern_line_tools"
  require "main"
end


function attempt_rotate_setup()

  local res, err = pcall(rotate_setup)

  if (res) then
    have_rotator = true
    print(TOOL_NAME  .. ": Seem to have loaded code from com.renoise.PatternRotate.xrnx")
  else
    have_rotator = false
    print("WARNING: " .. TOOL_NAME .. " failed to load code from com.renoise.PatternRotate.xrnx." )

  end
end


-- *******************************************

function randy_setup()
  package.path = "../com.neurogami.RandyNoteColumns.xrnx/?.lua;" .. package.path
  require "RandyNoteColumns/Core"
end


function attempt_randy_setup()
print("|||||||||||||||||||||||| ATTEMPT RANDY SETUP |||||||||||||||||||||") -- DEBUG

  local res, err = pcall(randy_setup)

  if (res) then
    have_randy = true
    print(TOOL_NAME .. ": Seem to have loaded code from com.neurogami.RandyNoteColumns.xrnx")

  else
    have_randy = false
    print("WARNING: " .. TOOL_NAME .. " failed to load code from com.neurogami.RandyNoteColumns.xrnx." )
    print("Error: ", err)
  end

end


rotate_handlers = {

  { -- Marks a pattern loop range and  then sets the start of the loop as  the next pattern to play
  pattern = "/rotate/track",
  handler = function(track_num, lines)

    -- need a way to get the current pattern or something so that
    -- this works on the right stuff
    print("Rotate ",lines, " lines")

    --      local selected_track_index = song().selected_track_index
    local song = renoise.song
    if (track_num > -1 ) then
      song().selected_track_index = track_num
      local selected_track_index = song().selected_track_index
      print( "ROTATE: selected_track_index is now " , selected_track_index )
    end
    
    rotate(lines, RANGE_TRACK_IN_PATTERN, true)

  end 
}, 

}


randy_handlers = {

  { -- Marks a pattern loop range and  then sets the start of the loop as  the next pattern to play
  pattern = "/randy/test",
  handler = function(track_index)
    -- need a way to get the current pattern or something so that
    -- this works on the right stuff
    print("Randy test for track_index ", track_index )
  end 
}, 

}

