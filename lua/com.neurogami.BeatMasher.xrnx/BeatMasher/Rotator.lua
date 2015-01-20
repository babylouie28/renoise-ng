local RANGE_WHOLE_SONG = 1
local RANGE_WHOLE_PATTERN = 2
local RANGE_TRACK_IN_SONG = 3
local RANGE_TRACK_IN_PATTERN = 4
local RANGE_SELECTION_IN_PATTERN = 5

have_rotator = false



local function attempt_remove_menu(menu_name)
  renoise.tool():remove_menu_entry(menu_name)
end


function rotate_setup()
  package.path = "../com.renoise.PatternRotate.xrnx/?.lua;" .. package.path
  require "pattern_line_tools"
  require "main"
end


function attempt_rotate_setup()

  local res = pcall(rotate_setup)

  if (res) then
    have_rotator = true
    res, err = pcall( attempt_remove_menu, "Pattern Editor:Rotate..." )
    if res then
      print("Should have removed an extra Rotate menu")
    end
    print(TOOL_NAME, " seems to have loaded code from com.renoise.PatternRotate.xrnx")
  else
    have_rotator = false
    print("WARNING: ", TOOL_NAME, " Failed to load code from com.renoise.PatternRotate.xrnx" )
  end
end



rotate_handlers = {
  { 
    pattern = "/rotate/pattern",
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

