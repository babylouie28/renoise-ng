--[[============================================================================

Custom GlobalOscActions.lua


============================================================================]]--

--[[

 This file defines Renoise's default OSC server implementation. Besides the 
 messages and patterns you find here, Renoise already processes a few realtime 
 critical messages internally. Those will never be triggered here, and thus can
 not be overloaded here:
 
 
 ---- Realtime Messages
 
 /renoise/trigger/midi(message(u/int32/64))
 
 /renoise/trigger/note_on(instr(int32/64), track(int32/64), 
   note(int32/64), velocity(int32/64))
   
 /renoise/trigger/note_off(instr(int32/64), track(int32/64), 
   note(int32/64))

 
 ---- Message Format
 
 All other messages are handled in this script. 
 
 The message arguments are passed to the process function as a table 
 (array) of:

 argument = {
   tag, -- (OSC type tag. See http://opensoundcontrol.org/spec-1_0)
   value -- (OSC value as lua type: nil, boolean, number or a string)
 }
 
 Please note that the message patterns are strings !without! the "/renoise" 
 prefix in this file. But the prefix must be specified when sending something 
 to Renoise. Some valid message examples are:
 
 /renoise/trigger/midi (handled internally)
 /renoise/transport/start (handled here)
 ...
 
 
 ---- Remote evaluation of Lua expressions via OSC
 
 With the OSC message "/renoise/evaluate" you can evaluate Lua expressions 
 remotely, and thus do "anything" the Renoise Lua API offers remotely. This 
 way you don't need to edit this file in order to extend Renoise's OSC 
 implementation, but can do so in your client.
 
 "/renoise/evaluate" expects exactly one argument, the to be evaluated 
 Lua expression, and will run the expression in a custom, safe Lua environment. 
 This custom environment is a sandbox which only allows access to some global 
 Lua functions and the renoise.XXX modules. This means you can not change any 
 globals or locals from this script. Please see below (evaluate_env) for the 
 complete list of allowed functions and modules. 
 
 
---- Adding new messages

If you want to extend the default OSC message set, first copy this file to the 
"Scripts" folder in your preferences folder. Then do your changes there. The 
file in the Renoise resource folder may be overwritten when updating Renoise. 
Click on "Help" -> "Show Preferences Folder..." in Renoise to locate the folder.

Any errors that happen in the OSC message handlers, are not shown to the user.
They are only dumped into the scripting terminal. Make sure its open when 
changing anything in here to make debugging easier.

When editing this file in Renoises "Scripting Terminal&Editor", any changes 
to the message set will instantly be applied as soon as you save the file.
This way you can quickly test out your changes.
 
When working with an external editor, you can manually reload this script and 
apply changes, by clicking on the small "refresh" button in Renoise's OSC 
preferences pane (watch out for a small icon in the message search field, above
the OSC message list). 

Scripting developer tools must be enabled to see the "refresh" button and the 
scripting terminal in Renoise. Please see http://scripting.renoise.com for more 
info about this.
  
]]


--------------------------------------------------------------------------------
-- Message Registration
--------------------------------------------------------------------------------

local global_action_pattern_map = table.create{}

local track_action_pattern_map = table.create{}
local track_action_pattern_map_prefix = "/song/track"

local device_action_pattern_map = table.create{}
local device_action_pattern_map_prefix = "/device"


-- argument

-- Helper function to define a message argument for an action.
-- "name" is only needed when generating a list of available messages for the 
-- user. "type" is the expected lua type name for the OSC argument, NOT the OSC 
-- type tag. e.g. argument("bpm", "number").

local function argument(name, type)
  return { name = name, type = type }
end


-- add_action

-- Register a global Renoise OSC message:
-- info = {
--   pattern,     -> required. OSC message pattern like "/transport/start"
--   description, -> optional. string which describes the action
--   arguments    -> optional. table of arguments (see function 'argument')
--   handler      -> required. function which applies the action.
-- }

local function add_action(map, info)

  -- validate actions, help finding common errors and typos
  if not (type(info.pattern) == "string" and 
          type(info.handler) == "function") then
    error("An OSC action needs at least a 'pattern' and "..
      "'handler' function property.")
  end
  
  if not (type(info.description) == "nil" or 
          type(info.description) == "string") then
    error(("OSC action '%s': OSC message description should not be "..
      "specified or should be a string"):format(info.pattern))
  end
  
  if not (type(info.arguments) == "nil" or 
          type(info.arguments) == "table") then
    error(("OSC action '%s': OSC arguments should not be specified or "..
      "should be a table"):format(info.pattern))
  end
    
  for _, argument in pairs(info.arguments or {}) do
    if (argument.type ~= "number" and 
        argument.type ~= "string" and
        argument.type ~= "boolean")
    then
      error(("OSC action '%s': unexpected argument type '%s'. "..
        "expected a lua type (number, string or boolean)"):format(
        info.pattern, argument.type or "nil"))
      end
  end
    
  if (map[info.pattern] ~= nil) then 
    error(("OSC pattern '%s' is already registered"):format(info.pattern))
  end
  
  -- register the action
  info.arguments = info.arguments or {}
  info.description = info.description or "No description available"

  map[info.pattern] = info
end
 
 
-- add_global_action

local function add_global_action(info)
  add_action(global_action_pattern_map, info)
end


-- add_track_action

local function add_track_action(info)
  add_action(track_action_pattern_map, info)
end


-- add_device_action

local function add_device_action(info)
  add_action(device_action_pattern_map, info)
end


--------------------------------------------------------------------------------
-- Message Helpers
--------------------------------------------------------------------------------

-- Environment for custom Lua expressions via OSC. Such expressions can only 
-- access a few "safe" globals and modules.

local evaluate_env = {
  _VERSION = _G._VERSION,
  
  math = table.rcopy(_G.math),
  renoise = table.rcopy(_G.renoise),
  string = table.rcopy(_G.string),
  table = table.rcopy(_G.table),
  assert = _G.assert,
  error = _G.error,
  ipairs = _G.ipairs,
  next = _G.next,
  pairs = _G.pairs,
  pcall = _G.pcall,
  print = _G.print,
  select = _G.select,
  tonumber = _G.tonumber,
  tostring = _G.tostring,
  type = _G.type,
  unpack = _G.unpack,
  xpcall = _G.xpcall
}


-- evaluate

-- Compile and evaluate an expression in the evaluate_env sandbox.
local function evaluate(expression)
  local eval_function, message = loadstring(expression)
  
  if (not eval_function) then 
    -- failed to compile
    return nil, message 
  
  else
    -- run and return the result...
    setfenv(eval_function, evaluate_env)
    return pcall(eval_function)
  end
end


-- song

local song = renoise.song


-- clamp_value

local function clamp_value(value, min_value, max_value)
  return math.min(max_value, math.max(value, min_value))
end


-- convert_value

-- Tries to convert the given value to the specified dest type
-- returns the converted value when conversion succeeded, else nil

local function convert_value(value, dest_type)

  local src_type = type(value)
  
  if (dest_type == src_type) then
    -- no conversion needed
    return value
  
  elseif (dest_type == "string") then
    -- try converting dest to a string
    return tostring(value)
    
  elseif (dest_type == "number") then
    -- try converting dest to a number
    return tonumber(value)
    
  elseif (dest_type == "boolean") then
    -- try converting value from a string or number to boolean
    if (tonumber(value) ~= nil) then 
      local number = tonumber(value)
      if (number == 1) then
        return true
      elseif (number == 0) then
        return false
      end
    
    -- try converting value from a string to boolean
    elseif (tostring(value) ~= nil) then
      local string = tostring(value):lower()
      if (string == "true") then
        return true
      elseif (string == "false") then
        return false
      end
    end
  end
end
    
    
-- selected_track_index

local function selected_track_index()
  return song().selected_track_index
end


-- selected_device_index

local function selected_device_index()
  return song().selected_device_index
end


-- set_track_parameter

local function set_track_parameter(track_index, parameter_name, value)
  -- sequencer + master + sends
  local num_tracks = song().sequencer_track_count + 1 + song().send_track_count

  if (track_index >= 1 and track_index <= num_tracks) then
    local parameter = song():track(track_index)[parameter_name]
    
    parameter.value = clamp_value(value, 
      parameter.value_min, parameter.value_max)
  end
end


--------------------------------------------------------------------------------
-- Global Action Registration
--------------------------------------------------------------------------------

-- /evaluate

add_global_action { 
  pattern = "/evaluate", 
  description = "Evaluate a custom Lua expression, like e.g.\n" ..
    "'renoise.song().transport.bpm = 234'",
  
  arguments = { argument("expression", "string") },
  handler = function(expression)
    print(("OSC Message: evaluating '%s'"):format(expression))

    local succeeded, error_message = evaluate(expression)
    if (not succeeded) then
      print(("*** expression failed: '%s'"):format(error_message))
    end
  end
}


-- /transport/panic

add_global_action { 
  pattern = "/transport/panic", 
  description = "Stop playback and reset all playing instruments and DSPs",
  
  arguments = nil,
  handler = function()
    song().transport:panic()
  end
}

-- /transport/start

add_global_action { 
  pattern = "/transport/start", 
  description = "Start playback or restart playing the current pattern",
  
  arguments = nil,
  handler = function()
    local play_mode = renoise.Transport.PLAYMODE_RESTART_PATTERN
    song().transport:start(play_mode)
  end
}


-- /transport/stop

add_global_action { 
  pattern = "/transport/stop", 
  description = "Stop playback",
  
  arguments = nil,
  handler = function()
    song().transport:stop()
  end
}


-- /transport/continue

add_global_action { 
  pattern = "/transport/continue", 
  description = "Continue playback",
  
  arguments = nil,
  handler = function()
    local play_mode = renoise.Transport.PLAYMODE_CONTINUE_PATTERN
    song().transport:start(play_mode)
  end
}


-- /transport/loop/pattern

add_global_action { 
  pattern = "/transport/loop/pattern", 
  description = "Enable or disable looping the current pattern",
  
  arguments = { argument("enabled", "boolean") },
  handler = function(enabled)
    song().transport.loop_pattern = enabled
  end
}


-- /transport/loop/block

add_global_action { 
  pattern = "/transport/loop/block", 
  description = "Enable or disable pattern block looping",
  
  arguments = { argument("enabled", "boolean") },
  handler = function(enabled)
    song().transport.loop_block_enabled = enabled
  end
}


-- /transport/loop/block_move_forwards

add_global_action { 
  pattern = "/transport/loop/block_move_forwards", 
  description = "Move loop block one segment forwards",
  
  arguments = nil,
  handler = function()
    song().transport:loop_block_move_forwards()
  end
}


-- /transport/loop/block_move_backwards

add_global_action { 
  pattern = "/transport/loop/block_move_backwards", 
  description = "Move loop block one segment backwards",
  
  arguments = nil,
  handler = function()
    song().transport:loop_block_move_backwards()
  end
}


-- /transport/loop/sequence

add_global_action { 
  pattern = "/transport/loop/sequence", 
  description = "Disable or set a new sequence loop range",
  
  arguments = { argument("start", "number"), argument("end", "number") },
  handler = function(rstart, rend)
    local start_pos = song().transport.loop_start
    start_pos.line = 1; start_pos.sequence = clamp_value(rstart, 1, 
      song().transport.song_length.sequence)
    
    local end_pos = song().transport.loop_end
    end_pos.line = 1; end_pos.sequence =  clamp_value(rend + 1, 1, 
      song().transport.song_length.sequence + 1)

    song().transport.loop_range = {start_pos, end_pos}
  end
}


-- /song/bpm

add_global_action { 
  pattern = "/song/bpm", 
  description = "Set the songs current BPM [32 - 999]",
  
  arguments = { argument("bpm", "number") },
  handler = function(bpm)
    song().transport.bpm = clamp_value(bpm, 32, 999)
  end,
}


-- /song/lpb

add_global_action {
  pattern = "/song/lpb", 
  description = "Set the songs current Lines Per Beat [1 - 255]",

  arguments = { argument("lpb", "number") }, 
  handler = function(lpb)
    song().transport.lpb = clamp_value(lpb, 1, 255)
  end
}


-- /song/tpl

add_global_action {
  pattern = "/song/tpl", 
  description = "Set the songs current Ticks Per Line [1 - 16]",

  arguments = { argument("tpl", "number") }, 
  handler = function(tpl)
    song().transport.tpl = clamp_value(tpl, 1, 16)
  end
}


-- /song/edit/mode

add_global_action { 
  pattern = "/song/edit/mode", 
  description = "Set the songs global edit mode on or off",
  
  arguments = { argument("enabled", "boolean") },
  handler = function(enabled)
    song().transport.edit_mode = enabled
  end
}


-- /song/edit/octave

add_global_action { 
  pattern = "/song/edit/octave", 
  description = "Set the songs current octave [0 - 8]",
  
  arguments = { argument("octave", "number") },
  handler = function(octave)
    song().transport.octave = clamp_value(octave, 0, 8)
  end,
}


-- /song/edit/step

add_global_action { 
  pattern = "/song/edit/step", 
  description = "Set the songs current edit_step [0 - 8]",
  
  arguments = { argument("edit_step", "number") },
  handler = function(edit_step)
    song().transport.edit_step = clamp_value(edit_step, 0, 9)
  end
}


-- /song/edit/pattern_follow

add_global_action { 
  pattern = "/song/edit/pattern_follow", 
  description = "Enable or disable the global pattern follow mode",
  
  arguments = { argument("enabled", "boolean") },
  handler = function(enabled)
    song().transport.follow_player = enabled
  end,
}


-- /song/record/metronome

add_global_action { 
  pattern = "/song/record/metronome", 
  description = "Enable or disable the global metronome",
  
  arguments = { argument("enabled", "boolean") },
  handler = function(enabled)
    song().transport.metronome_enabled = enabled
  end
}


-- /song/record/metronome_precount

add_global_action { 
  pattern = "/song/record/metronome_precount", 
  description = "Enable or disable the global metronome precount",
  
  arguments = { argument("enabled", "boolean") },
  handler = function(enabled)
    song().transport.metronome_precount_enabled = enabled
  end
}


-- /song/record/quantization

add_global_action { 
  pattern = "/song/record/quantization", 
  description = "Enable or disable the global record quantization",
  
  arguments = { argument("enabled", "boolean") },
  handler = function(enabled)
    song().transport.record_quantize_enabled = enabled
  end
}


-- /song/record/quantization_step

add_global_action { 
  pattern = "/song/record/quantization_step", 
  description = "Set the global record quantization step [1 - 32]",
  
  arguments = { argument("step", "number") },
  handler = function(step)
    song().transport.record_quantize_lines = clamp_value(step, 1, 32)
  end,
}


-- /song/record/chord_mode

add_global_action { 
  pattern = "/song/record/chord_mode", 
  description = "Enable or disable the global chord mode",
  
  arguments = { argument("enabled", "boolean") },
  handler = function(enabled)
    song().transport.chord_mode_enabled = enabled
  end
}


-- /song/sequence/trigger

add_global_action { 
  pattern = "/song/sequence/trigger", 
  description = "Set playback pos to the specified sequence pos",
  
  arguments = { argument("sequence_pos", "number") },
  handler = function(sequence_pos)
    song().transport:trigger_sequence(clamp_value(sequence_pos, 
      1, song().transport.song_length.sequence))
  end,
}


-- /song/sequence/schedule_set

add_global_action { 
  pattern = "/song/sequence/schedule_set", 
  description = "Replace the current schedule playback pos",
  
  arguments = { argument("sequence_pos", "number") },
  handler = function(sequence_pos)
    song().transport:set_scheduled_sequence(clamp_value(sequence_pos, 
      1, song().transport.song_length.sequence))
  end
}


-- /song/sequence/schedule_add

add_global_action { 
  pattern = "/song/sequence/schedule_add", 
  description = "Add a scheduled sequence playback pos",
  
  arguments = { argument("sequence_pos", "number") },
  handler = function(sequence_pos)
    song().transport:add_scheduled_sequence(clamp_value(sequence_pos, 
      1, song().transport.song_length.sequence))
  end
}


-- /song/sequence/slot_mute

add_global_action { 
  pattern = "/song/sequence/slot_mute", 
  description = "Mute the given track, sequence slot in the matrix",
  
  arguments = { argument("track_index", "number"), 
    argument("sequence_pos", "number") },
  handler = function(track_index, sequence_pos)
    if track_index >= 1 and track_index <= #song().tracks then
      if sequence_pos >= 1 and 
         sequence_pos <= song().transport.song_length.sequence 
      then
        song().sequencer:set_track_sequence_slot_is_muted(
          track_index, sequence_pos, true)
      end
    end
  end
}
   

-- /song/sequence/slot_unmute

add_global_action { 
  pattern = "/song/sequence/slot_unmute", 
  description = "Unmute the given track, sequence slot in the matrix",
  
  arguments = { argument("track_index", "number"), 
    argument("sequence_pos", "number") },
  handler = function(track_index, sequence_pos)
    if track_index >= 1 and track_index <= #song().tracks then
      if sequence_pos >= 1 and 
         sequence_pos <= song().transport.song_length.sequence 
      then
        song().sequencer:set_track_sequence_slot_is_muted(
          track_index, sequence_pos, false)
      end
    end
  end
}

  
--------------------------------------------------------------------------------
-- Track Action Registration
--------------------------------------------------------------------------------

-- NOTE: track action handler functions will get the track index passed as first 
-- argument, but should not specify it in its argument list. Its resolved from 
-- the message pattern.


-- /song/track/XXX/prefx_volume

add_track_action { 
  pattern = "/prefx_volume", 
  description = "Set track XXX's pre FX volume [0 - db2lin(3)]\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = { argument("value", "number") },
  handler = function(track_index, value)
    set_track_parameter(track_index, "prefx_volume", value)
  end
}


-- /song/track/XXX/prefx_volume_db

add_track_action { 
  pattern = "/prefx_volume_db", 
  description = "Set track XXX's pre FX volume in dB [-200 - 3]\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = { argument("value", "number") },
  handler = function(track_index, value)
    set_track_parameter(track_index, "prefx_volume", math.db2lin(value))
  end
}


-- /song/track/XXX/postfx_volume

add_track_action { 
  pattern = "/postfx_volume", 
  description = "Set track XXX's post FX volume [0 - db2lin(3)]\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = { argument("value", "number") },
  handler = function(track_index, value)
    set_track_parameter(track_index, "postfx_volume", value)
  end
}


-- /song/track/XXX/postfx_volume_db

add_track_action { 
  pattern = "/postfx_volume_db", 
  description = "Set track XXX's post FX volume in dB [-200 -  3]\n"..
    "XXX is the track index, -1 the currently selected track",

  arguments = { argument("value", "number") },
  handler = function(track_index, value)
    set_track_parameter(track_index, "postfx_volume", math.db2lin(value))
  end
}


-- /song/track/XXX/prefx_panning

add_track_action { 
  pattern = "/prefx_panning", 
  description = "Set track XXX's pre FX panning [-50 - 50]\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = { argument("value", "number") },
  handler = function(track_index, value)
    set_track_parameter(track_index, "prefx_panning", value / 100 + 0.5)
  end
}


-- /song/track/XXX/postfx_panning

add_track_action { 
  pattern = "/postfx_panning", 
  description = "Set track XXX's post FX panning [-50 - 50]\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = { argument("value", "number") },
  handler = function(track_index, value)
    set_track_parameter(track_index, "postfx_panning", value / 100 + 0.5)
  end
}


-- /song/track/XXX/prefx_width

add_track_action { 
  pattern = "/prefx_width", 
  description = "Set track XXX's pre FX width [0, 1]\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = { argument("value", "number") },
  handler = function(track_index, value)
    set_track_parameter(track_index, "prefx_width", value * 126)
  end,
}


-- /song/track/XXX/output_delay

add_track_action { 
  pattern = "/output_delay", 
  description = "Set track XXX's delay in ms [-100 - 100]\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = { argument("value", "number") },
  handler = function(track_index, value)
    local tracks = song().tracks
    if (track_index >= 1 and track_index <= #tracks) then
      tracks[track_index].output_delay = clamp_value(value, -100, 100)
    end
  end
}


-- /song/track/XXX/mute

add_track_action { 
  pattern = "/mute", 
  description = "Mute track XXX\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = nil,
  handler = function(track_index)
    local tracks = song().tracks
    if (track_index >= 1 and track_index <= #tracks) then
      tracks[track_index]:mute() 
    end
  end,
}


-- /song/track/XXX/unmute

add_track_action { 
  pattern = "/unmute", 
  description = "Unmute track XXX\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = nil,
  handler = function(track_index)
    local tracks = song().tracks
    if (track_index >= 1 and track_index <= #tracks) then
      tracks[track_index]:unmute() 
    end
  end
}


-- /song/track/XXX/solo

add_track_action { 
  pattern = "/solo", 
  description = "Solo track XXX\n"..
    "XXX is the track index, -1 the currently selected track",
  
  arguments = nil,
  handler = function(track_index)
    local tracks = song().tracks
    if (track_index >= 1 and track_index <= #tracks) then
      tracks[track_index]:solo() 
    end
  end
}


--------------------------------------------------------------------------------
-- Device Action Registration
--------------------------------------------------------------------------------

-- NOTE: device action handler functions will get the track and device index 
-- passed as first argument, but should not specify it in its argument list. 
-- Its resolved from the message pattern.


-- /song/track/XXX/device/XXX/bypass

add_device_action { 
  pattern = "/bypass", 
  description = "Set bypass status of an device [true or false]\n"..
    "XXX is the device index, -1 the currently selected device",
  
  arguments = { argument("bypassed", "boolean") },
  handler = function(track_index, device_index, bypassed)
    local tracks = song().tracks
    if (track_index >= 1 and track_index <= #tracks) then
      local devices = tracks[track_index].devices
      -- 2: do not try bypassing the mixer device
      if (device_index >= 2 and device_index <= #devices) then
        devices[device_index].is_active = not bypassed
      end
    end
  end
}


-- /song/track/XXX/device/XXX/set_parameter_by_index

add_device_action { 
  pattern = "/set_parameter_by_index",
  description = "Set parameter value of an device [0 - 1]\n"..
    "XXX is the device index, -1 the currently selected device",
  
  arguments = { argument("parameter_index", "number"), 
    argument("value", "number") },
  handler = function(track_index, device_index, parameter_index, value)
    local tracks = song().tracks

    if (track_index >= 1 and track_index <= #tracks) then
      local devices = tracks[track_index].devices

      if (device_index >= 1 and device_index <= #devices) then
        local parameters = devices[device_index].parameters

        if (parameter_index >= 1 and parameter_index <= #parameters) then
          local parameter = parameters[parameter_index]
          
          local parameter_value = value * (parameter.value_max - 
            parameter.value_min) + parameter.value_min
          
          parameter.value = clamp_value(parameter_value, 
            parameter.value_min, parameter.value_max)
        end
      end
    end
  end
}


-- /song/track/XXX/device/XXX/set_parameter_by_name

add_device_action { 
  pattern = "/set_parameter_by_name",
  description = "Set parameter value of an device [0 - 1]\n"..
    "XXX is the device index, -1 the currently selected device",
  
  arguments = { argument("parameter_name", "string"), 
    argument("value", "number") },
  handler = function(track_index, device_index, parameter_name, value)
    local tracks = song().tracks
    
    if (track_index >= 1 and track_index <= #tracks) then
      local devices = tracks[track_index].devices

      if (device_index >= 1 and device_index <= #devices) then
        local parameters = devices[device_index].parameters

        local parameter
        for _,p in pairs(parameters) do
          if (p.name:lower() == parameter_name:lower()) then
            parameter = p
            break
          end
        end
          
        if (parameter) then
          local parameter_value = value * (parameter.value_max - 
            parameter.value_min) + parameter.value_min
          
          parameter.value = clamp_value(parameter_value, 
            parameter.value_min, parameter.value_max)
        end
      end
    end
  end
}


--------------------------------------------------------------------------------
-- Interface
--------------------------------------------------------------------------------

-- available_messages

-- Called by Renoise to show info about all available messages in the 
-- OSC preferences pane.

function available_messages()

  local action_pattern_maps = table.create()
  action_pattern_maps:insert{
    map = global_action_pattern_map, 
    scope = ""
  }
  action_pattern_maps:insert{
    map = track_action_pattern_map, 
    scope = track_action_pattern_map_prefix.."/XXX"
  }
  action_pattern_maps:insert{
    map = device_action_pattern_map, 
    scope = track_action_pattern_map_prefix.."/XXX"..
      device_action_pattern_map_prefix.."/XXX"
  }
  
  local ret = table.create()

  for _, action_pattern_map in pairs(action_pattern_maps) do
    for _, action in pairs(action_pattern_map.map) do
      
      local argument_types = table.create()
      for _, argument in pairs(action.arguments) do
        argument_types:insert(argument.type)
      end
      
      ret:insert {
        name = action_pattern_map.scope .. action.pattern,
        description = action.description,
        arguments = argument_types
      }
    end
  end
    
  return ret
end


--------------------------------------------------------------------------------

-- process_message

-- Called by Renoise in order to process an OSC message which was received by 
-- the global Renoise OSC server (the one that is configured in the OSC 
-- preferences pane in Renoise).
-- The returned boolean is only used for the OSC log view in the preferences
-- (return false will log messages as REJECTED).
-- Lua runtime errors that may happen here, will never be shown as errors to 
-- the user, but will only be dumped to scripting terminal in Renoise.

function process_message(pattern, arguments)

  -- global pattern match
  local action = global_action_pattern_map[pattern]
  local action_arguments = table.create{}
  
  if (not action) then
  
    -- track pattern match
    local _, _, track_index, track_pattern = pattern:find(
      track_action_pattern_map_prefix.."/(-?%d+)(/.+)")
  
    if (track_index and track_pattern) then
      track_index = tonumber(track_index) or 0
      if (track_index == -1) then
        track_index = selected_track_index() 
      end
      
      action = track_action_pattern_map[track_pattern]
      action_arguments:insert(track_index)
      
      if (not action) then
  
        -- track device match
        local _, _, device_index, device_pattern = track_pattern:find(
          device_action_pattern_map_prefix.."/(-?%d+)(/.+)")
  
        if (device_index and device_pattern) then
          device_index = tonumber(device_index) or 0
          if (device_index == -1) then
            device_index = selected_device_index() 
          end
      
          action = device_action_pattern_map[device_pattern]
          action_arguments:insert(device_index)
        end
      end
    end
  end
  
  -- found a matching pattern?
  if (action) then
    
    -- check if the arguments match as well
    if (#action.arguments == #arguments) then
      local arg_match = true
      local arg_values = table.create{}

      -- check if the passed and the actions argument types match
      -- or can be converted to the expected type
      for i = 1, #arguments do
        local arg_value = convert_value(
          arguments[i].value, action.arguments[i].type)
        
        if (arg_value ~= nil) then 
          action_arguments:insert(arg_value)
        else
          arg_match = false
          break
        end
      end
      
      --  when the arg types matched, invoke the action
      if (arg_match) then
        action.handler(unpack(action_arguments))
        return true -- handled
      end
    end
  end
    
  return false -- not handled (REJECTED)
end


--[[============================================================================


Now starts all the customize stuff.


============================================================================]]--


add_track_action { 
  pattern = "/clear", 
  description = "Clear track XXX\n"..
  "XXX is the track index, -1 the currently selected track",

  arguments = nil,
  handler = function(track_index)
    local tracks = song().tracks
    if (track_index >= 1 and track_index <= #tracks) then
      --- tracks[track_index]:clear() 
      renoise.song().patterns[1].tracks[track_index]:clear()
    end
  end,
}

    -- /song/track/XXX/send_switch

    add_track_action { 
      pattern = "/send_switch", 
      description = "Change the receiver of the track's send device.\n" .. 
      "Requires you follow a naming convention",

      arguments = { argument("send_index", "number") },


      handler = function(track_index, send_index)
        local device_index
        local device
        print( ( "Triggered /song/track/XXX/send_switch for track index %d, send index %d"):format(track_index, send_index) )

        local tracks = song().tracks

        if ( send_tracks == nil ) then
          print("Go get send tracks")
          send_tracks = {}

          send_track_count = 0
          for i = 1,#renoise.song().tracks do

            if renoise.song().tracks[i].type == renoise.Track.TRACK_TYPE_SEND  then
              send_track_count = send_track_count + 1
              print("Storing send track: " .. renoise.song().tracks[i].name)
              send_tracks[send_track_count] =  renoise.song().tracks[i]
            end
          end

        else
          print("send_tracks = ")
          print(send_tracks)
        end

        -- This should be catching requests for track 0 
        -- yet we still get this:
        --  *** GlobalOscActions.lua:564: attempt to index a nil value   
        if (track_index > 0 and track_index <= #tracks) then
          print("Found the track!")
          local send_device = nil
          --          
          local devices = tracks[track_index].devices
          -- 2: do not try bypassing the mixer device

          if (#devices > 0 ) then
            local i, j
            for device_idx, device in ripairs(devices) do
              -- The demo song, with a percussion group that uses a send, has the send on track 5.
              -- It contains the first 4 tracks.
              -- The default name is "#Send"
              -- One option is to use device naming to control how a send track is manipulated.
              -- For example, use a format such as "<prefix>Send" and then have the code 
              -- a) Check that the send track is not using  a default name
              -- b) only allow switch the send device to send track with a matching prefix.
              -- So, name the send device "SPerc_Send" (or maybe just SPerc)
              -- and then use the given send-to value as in index into only those send tracks
              -- that start with "SPerc" (in tihs case SPerc1 and SPerc2).
              -- Someting would need to acqire a list of send tracks, perhaps  some data structure
              -- that allowed to fast-finding by prefix. 
              -- The goal is to avoid looking up send tracks on every call.
              --
              print(device.display_name)
              -- Need a way to catch the send device, and if found  go
              -- and see if we can alter the waht send track it uses.
              -- This means having a way to test either the type of a device
              -- or rely on a naming convention
              --
              -- Unless there is a Renoise way to test for device type, assume the name follows this convention:
              -- "send_<tag>"
              -- Then extract the tag and assume the matching send tracks follow this convention:
              -- "<tag>_<id>"
              --
              -- So, for out demo track, the percussion send device is named "send_perc"
              -- and the two send tracks for it are "perc_1" and "perc_2"
              i, j = string.find(device.display_name, "send_")
              if i == 1 then
                -- Get the part that comes after 'send_'
                local send_tag = string.gsub(device.display_name, "send_", "")
                print("Found a send device with tag " .. send_tag )
                send_device  = device
                -- Now loop over the send tracks to find a match

                local idx
                print( ("We have %d send tracks"):format(send_track_count ) )
                local match_count = 0;
                for idx = 1, send_track_count do
                  print("Check name of send track '" .. send_tracks[idx].name .. "' for '" .. send_tag .. "'")

                  i, j = string.find( send_tracks[idx].name, send_tag)

                  if i then
                    match_count = match_count + 1
                    print("- - - - - - We have a send track tag match on send track " .. send_tracks[idx].name )
                    print(("Matched send track is idx %d and match_count %d "):format(idx, match_count) )
                    -- If this send track matches on the tag and is the correct index
                    -- then we need to set the device to use that send track
                    if match_count == send_index then

                      for __,param in ipairs(device.parameters) do
                        print(param.name)
                        if  param.name == "Receiver" then
                          param.value = 100 --- idx-1
                          print("Updated value of  device " .. device.display_name )
                          break
                        end
                      end

                      break
                    end
                  end
                end
                break
                --- End send track lopp
              end
            end
          end
        else
          print("That index is out of range: %d"):format(track_index)
        end
      end

    }
add_track_action { 
  pattern = "/patternize", 
  description = "Add pattern to track XXX\n"..
  "XXX is the track index, -1 the currently selected track",

  arguments = nil,
  handler = function(track_index)
    local tracks = song().tracks
    if (track_index >= 1 and track_index <= #tracks) then
      --- tracks[track_index]:clear()
      renoise.song().patterns[1].tracks[track_index]:clear()
    end
  end,
}


