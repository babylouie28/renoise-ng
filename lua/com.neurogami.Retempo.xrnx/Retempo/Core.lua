--[[

Code needs to:

Get the current BPM
Use that value to index the corresponding note value.
If a note is found then:
- Go though the first note column of the current track
- For each pattern, each note found, change the note to the indexed note.
- Leave the instrument alone

If no indexed note is found popup a simple notification about that.

--]]
-- 64 == e-5
--
Core = {}
Core.bpm_notes = {}
Core.bpm_notes[116] = 48
Core.bpm_notes[118] = 49
Core.bpm_notes[120] = 50
Core.bpm_notes[122] = 51
Core.bpm_notes[124] = 52
Core.bpm_notes[126] = 53
Core.bpm_notes[128] = 54
Core.bpm_notes[130] = 55
Core.bpm_notes[132] = 56
Core.bpm_notes[134] = 57
Core.bpm_notes[136] = 58
Core.bpm_notes[138] = 59
Core.bpm_notes[140] = 60
Core.bpm_notes[142] = 61
Core.bpm_notes[144] = 62
Core.bpm_notes[146] = 63
Core.bpm_notes[148] = 64
Core.bpm_notes[150] = 65


function Core.note_for_bpm()
  local bpm = renoise.song().transport.bpm
  local note = Core.bpm_notes[bpm]
  print("Found " .. note .. " for bpm " .. bpm )
  return(note) 
end

-- Only works on note column 1
function Core.set_notes_in_track_pattern_to(new_note, pattern_index)
print("* * * Have new note value of " .. new_note .. " * * * ")

  local _ti = renoise.song().selected_track_index
  local _col = 1 -- renoise.song().selected_note_column_index
  local lines_in_pattern = renoise.song().patterns[pattern_index].number_of_lines


  local note_col

  for i=1,lines_in_pattern do   
    print("Line " .. i)
    note_col = renoise.song().patterns[pattern_index].tracks[_ti].lines[i].note_columns[_col]
    -- The track volume fx command is '0Lxx'
    print("note_col note_string = " .. note_col.note_string)
    if not (note_col.note_string == '---') then
      print("Change value of " .. note_col.note_value .. " to " .. new_note)
      note_col.note_value = new_note
    end
    -- Need to see wht value means there is no note, and skip those
    -- note_col.note_string = note
  end
end

return Core
