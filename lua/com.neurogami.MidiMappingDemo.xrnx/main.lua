--[[============================================================================
com.neurogami.MidiMappingDemo.xrnx/main.lua
============================================================================]]--


print("com.neurogami.MidiMappingDemo devices")


require 'Utils'
require 'Actions'
require 'Handlers'

local midi_out_device


-- The code that does 'target to device name' matching should be
-- using whatever matches LAST, so put the last-resort fullback devices first
-- and the most preferred device names last.
--
-- You may want to set these to devices you now might be found.
-- This particular demo was intended for use with a Teensy micro-controller 
-- board that sends MIDI messages over USB.  Basically, it behaves as a 
-- MIDI device and uses some code to interpret sensor input as MIDI triggers.
local DEVICE_NAMES = {"Teensy MIDI NG", "Launchpad", "QuNexus MIDI 1", "LoopBe Internal MIDI" }


-------------------------------------------------------------
--Midi Mappings
-------------------------------------------------------------


--[[

If you open up the 'MIDI Mapping dialog you can get  aist of all the mappings.

You have to toggle open "Available & Active Mappings"

It's a hierarchy; the "*_midi_mapping" methods seem to map  a string of
the form "Transport:Playback" to the hierarchy of Transport -> Playback. 

Duh.

So you can look for and add/remove items.

But then what?

Some stuff here: http://forum.renoise.com/index.php?showtopic=26575

Also: com.renoise.LiveLooper_Rns280_V0.12.xrnx
http://forum.renoise.com/index.php?/topic/26576-experiment-use-midi-knob-to-set-loop-markers/page__st__25__p__219059#entry219059

By default (so far) that menu says it's not mapped.

Can we force a mapping at load time?


That Looper example does something clever, and different than MIDI mapping.

It automagically inserts a device, "*Instr. MIDI Control"
It then associates the first two settings on that devce to some methods.

But the code for that never specifies these control names ("Picthbend" and "Pressure").

Where does that come from?  

AH!  They are just the defaults for that device.

Can they map to other things, like notes?

"The MIDI Control Device broadcasts MIDI pitch bend, channel pressure, control change and program change commands to instruments."

One optoin might be to just look for pitchbend, CC, etc. and couple specific values to assorted behavior.

For example, a pressue value in the range of 10 to 20 uses that value to jump among patterns.


Something else: http://forum.renoise.com/index.php?/topic/35447-map-a-midi-cc-without-learn/



]]--



function tprint (tbl, indent)
  local formatting 
  if not indent then indent = 0 end
  for k, v in pairs(tbl) do
    formatting = string.rep("  ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      tprint(v, indent+1)
    elseif type(v) == 'boolean' then
      print(formatting .. tostring(v))    
    else
      print(formatting .. v)
    end
  end
end


if renoise.tool():has_midi_mapping("Transport:Playback:Skip to Line [SetNG]") then
  renoise.tool():remove_midi_mapping("Transport:Playback:Skip to Line [SetNG]")
end

-- Assumes that first and last  bytes are special, and all else are chars.
-- See http://www.blitter.com/~russtopia/MIDI/~jglatt/tech/midispec/sysex.htm
--   "Begins with 0xF0. Ends with a 0xF7 status (ie, after the data bytes)."
--
--   http://www.waveidea.com/en/products/bitstream/faqs.php
--      "A SYSEX is a MIDI message that enables machines to send whatever they want 
--      to other stuff : presets, samples, special parameters, etc ... 
--      It starts with F0h and ends with F7h. 
--      Most SYSEX are not longer than 127 bytes."
function sysex_handler(message)
  --[[
  See http://www.blitter.com/~russtopia/MIDI/~jglatt/tech/midispec/sysex.htm
  "Begins with 0xF0. Ends with a 0xF7 status (ie, after the data bytes)."
  ]]--



  local s = ""
  --[[
  On Ubuntu this is broken.  The first 2 characters are always:    
      (char)
  1     (decimal)
  A
  41

  What happens if you use the code compoiled on Ubuntu against the Renoise on Win7?
  Well, we get this:


  SYSEX with 7 bytes: 12345   
  1
  31
  2
  32
  3
  33
  4
  34
  5
  35

  A hack to work around this is to padd the sysex message with some junki byes up front.   
  Make the first two byes aways be "NG" and then read bytes 4 to #message-1


  What happens if we get a message less than 4 bytes?

  ]]--
  for i = 4,  #message-1 do
    -- print(string.char(message[i]))
    -- print(   ("%X"):format(message[i])  )
    s = s..string.char(message[i])
  end
  -- We can receive space-delimited messages and dispatch on the first word, passing the remainder
  -- cotent.  Do we assume that the remainder content are always ints or something?
  -- We assume that we can pass a table to the target function and that it will know
  -- what to do with it.
  --
  local words = {}
   print("Wat we got? ", s)
  for word in s:gmatch("%S+") do table.insert(words, word) end

  local m = words[1]
  table.remove(words, 1)

  local success, result = pcall(_G[HANDLER_PREFIX..m], words ) 

  if not success then
    print( ("There was an error calling %s: %s"):format( HANDLER_PREFIX..m, result) )
  end

end


function midi_handler(message)
  --[[

  Mind you, the MIDI messages are still caught by Renoise proper; if you send NoteOn with an
  intrument selected then you trigger a note as well as this method.

  http://forum.pjrc.com/threads/23523-Change-device-name

  For teensy 3 you edit usb_desc.h

  So now, on W500 Win7, teensy 3 midi gets this name:

  "Teensy MIDI NG"

  The trouble is, how can we know the order?     

  Don't need to.  Just the device name, not the leading index number, is needed.


  BTW, give some thought to using a unique name.  It means only such-named
  devices can work.  OTOH people can edit the tool to whatever name they want.


  Next step: How do we get the message values?


  print(("MIDI %X %X %X"):format(message[1], message[2], message[3]))

  MIDI 80 31 64
  MIDI 90 32 64
  MIDI 80 32 64
  MIDI 90 33 64
  MIDI 80 33 64
  MIDI 90 34 64
  MIDI 80 34 64
  MIDI 90 30 64
  MIDI 80 30 64
  MIDI 90 31 64
  MIDI 80 31 64
  MIDI 90 32 64
  MIDI 80 32 64


  These are hex values.


  This is from the midi ping sketch, which should be doing this:


  for (note=48; note <= 52; note++) {
    digitalWrite(led, HIGH);
    Serial.print("Note: ");
    Serial.print(note);
    Serial.println(".");

    usbMIDI.sendNoteOn(note, 100, channel);
    flicker();
    usbMIDI.sendNoteOff(note, 100, channel);
    digitalWrite(led, LOW); 
    delay(500);
  }



  If we use %d:


  MIDI 144 48 100
  MIDI 128 48 100
  MIDI 144 49 100
  MIDI 128 49 100
  MIDI 144 50 100
  MIDI 128 50 100
  MIDI 144 51 100
  MIDI 128 51 100
  MIDI 144 52 100
  MIDI 128 52 100
  MIDI 144 48 100
  MIDI 128 48 100
  MIDI 144 49 100


  The 144/128 seems to be note on/note off



  But it is not seeing  "usbMDIDI.sendPitchBend"
  ]]--

--  print(("MIDI %d %d %d"):format(message[1], message[2], message[3]))

  -- a CC message send like this:
  --     usbMIDI.sendControlChange(1, 65, 0);
  --  appears like this:
  --     MIDI 191 1 65

  -- How do we map plain MIDI messages to handers?
  -- For the send_switch thing we want, for example, notes 64 and 65,
  -- buttons 1 and 2 on row 5 of the launchpad, to
  -- trigger send_switch for track 5 with either 1 or 2
  --
  midi_handle(message)
end

-- Pull apart the MIDI message and create a function name, then call it

function on_or_off(v)
  if v > 0  then return "on" else return "off"  end
end

function midi_handle(message)

   -- local m = (HANDLER_PREFIX .. "%d_%d"):format(message[2], message[3])
   local m = (HANDLER_PREFIX .. "%d_%s"):format(message[2], on_or_off(message[3]))
   
   
   print(("MIDI handler has message:  %d %d %d"):format(message[1], message[2], message[3]))




   -- Trouble. If a handler is not defined for the note
   -- then pcall kills us with stuff like this:
   --   *** main.lua:287: variable 'handler_48_127' is not declared
   --  You cannot even do this:
   -- local meth = _G[m]



   --   http://www.lua.org/pil/14.html
   -- A runtime lookup by looping over _G seems expensive

  --if known_stuff[m] then
    
--   http://www.lua.org/pil/14.2.html
  if rawget(_G, m) ~= nil then
    print(" pcall " .. m )
    local success, result = pcall(_G[m], message, midi_out_device ) 
    if not success then
      print( ("There was an error calling %s: %s"):format( m, result) )
    end
  else
    print( ("* Cannot find %s in _G"):format(m) )
  end
end



-- The name of the device is not always appearing as it is set on the device.
-- On Ububunto 10.4 it is appeneding " MIDI 1" to the device name
-- as defined in usb_desc.h.
-- Code has to do some substring matching.
--     string.find(str_to_search, str_to_find )
--

local devices = renoise.Midi.available_input_devices()

print("com.neurogami.MidiMappingDemo devices")

tprint(devices, 2)

for i,name in pairs(DEVICE_NAMES) do
  for i= 1, #devices do
  print(("Compare '%s' to '%s'"):format(name,  devices[i]))
    if string.find( devices[i], name) then
      print(("FOUND '%s'"):format(name))
      -- miDevice = renoise.Midi.create_input_device(devices[i], midi_handler, sysex_handler)
      renoise.Midi.create_input_device(devices[i], midi_handler, sysex_handler)
      midi_out_device = renoise.Midi.create_output_device(devices[i])
      break
    end
  end
end


--[[

We get a list of devices like this:

1: 01. Internal MIDI
2: 02. Internal MIDI
3: LoopBe Internal MIDI

If we can assume the name of the Teensy MIDI input we have a chance.

]]--

--[[
renoise.tool():add_midi_mapping {
  name = "Transport:Playback:Skip to Line [SetNG]",
  invoke = function(mm) skip(mm) end
}

-------------------------------------------------------------
--Main: skip function
-------------------------------------------------------------
function skip(midi_message)
  local s = renoise.song()
  local current_seq = s.transport.playback_pos.sequence
  local current_pat = s.sequencer.pattern_sequence[current_seq]
  local pat_length = s.patterns[current_pat].number_of_lines
  local skipto = 1
  -- debug info
  print("MidiSkip DEBUG INFO")
  print("current_seq:", current_seq)
  print("current_pat:", current_pat)
  print("pat_length :", pat_length)
  -- if abs_value then skip to line no.
  --  (distribute possible values over current pattern length)
  if midi_message:is_abs_value() then
    if pat_length == 128 then
      skipto = midi_message.int_value+1 -- translation: pattern lines start with 1
    else
      skipto = math.floor(midi_message.int_value/128*pat_length)+1
    end
    s.transport.playback_pos = renoise.SongPos(current_seq, skipto)
    -- if rel_value then skip back/fw x lines
    --elseif midi_message:is_rel_value() then
    -- not supported yet
    -- will get more complicated, skipping back etc, 
  end
end
]]--
