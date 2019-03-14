-- TODO maybe these loose functions need to go to Utils

--=======================================================================
function print_pairs(t)
  for k,v in pairs(t) do
    print(k, " => ", v)
  end
end

--=======================================================================
-- Takes a list of ints, the number of lines in the pattern, 
-- and the current list of line numbers.
-- The new numbers are created by incrementing from 0
-- and adding each of the `inc_list` values.
--  E.g. 3,2 => 3,5,8,10,13
--  E.g. 3,2,5 => 3,5,10,13,15,20
--
-- The function makes no effort to check for negative increment values 
-- Returns that current list with the generated line numbers inserted, without duplicates
-- That list is unsorted.  
--=======================================================================
function sequence_from_inc_set(inc_list, lines_in_pattern, current_set)
  local inc = 0

  -- We always include line 0
  current_set[0] = 0

  print("sequence_from_inc_set is using current set:")
  print_pairs(current_set)

  for i=1,lines_in_pattern do 
    inc = inc + inc_list[1]
    if (inc > lines_in_pattern) then
      break
    end

    current_set[inc] = inc
    inc_list = U.wrap(inc_list, 1)
  end

  return current_set
end

--=======================================================================
-- Takes a list of ints, the number of lines in the pattern, 
-- and the current list of line numbers
-- The new numbers are base on whether any LINE_NUM % MOD_INT == 0
--  E.g 3,5 gives 3,5,6,9,10,12,15,18,20, ...
-- Returns that current list with the generated line numbers inserted, 
--    without duplicates
-- That list is unsorted.  
--=======================================================================
function sequence_from_mod_set(mod_list, lines_in_pattern, current_num_set)

  print("We have been passed current_num_set : ")
  print_pairs(current_num_set)

  -- We always include line 0
  current_num_set[0] = 0

  for i=1,lines_in_pattern do 
    for k,v in pairs(mod_list) do
      if not (i <  v) then
        if ( (i%v == 0 )  ) then
          current_num_set[i] = i
        end
      end

    end
  end


  return current_num_set
end

--=======================================================================
Core = {}

Core.gainer_name = "ALTERNATOR"

function get_alternator_gainer_and_index(ti)

  local track = renoise.song().tracks[ti]

  for index, device in ipairs(track.devices) do
    if device.display_name == Core.gainer_name then 
      return device, index
    end
  end

  return nil, nil

end

--[[ *******************************************************************
Loop over each line in the applicable note columns.

Clear all volume settings.

Original plan was to keep vol if there was a note on that line,
but that now feels like it applies more to edge cases.
******************************************************************* --]] 
function clear_existing_volumes()

  local _ti = renoise.song().selected_track_index
  local _fxci = renoise.song().selected_effect_column_index
  local _pi   = renoise.song().selected_pattern_index
  local _col = renoise.song().selected_note_column_index
  local _tp   = renoise.song().patterns[_pi].tracks[_ti]
  local lines_in_pattern = renoise.song().patterns[_pi].number_of_lines


  if (_fxci and _fxci > 0 ) then
    -- We have an fx column selected.
    -- See if we have a gain device named ALTERNATOR
    print("_fxci = " , _fxci )

    local gainer, dev_idx = get_alternator_gainer_and_index(_ti)
    local fx = renoise.song().patterns[_pi].tracks[_ti].lines[1].effect_columns[_fxci]

    

    if gainer then
      print("We have the special gainer.  Now we need to clear any existing values for it. Device index = ", dev_idx)
     local dev_number_string  = tostring(dev_idx - 1) .. "1"

      -- When the device index is 2, the automatoin number  ends up as  11. Why?
      -- Because: hh is [device-index][paramter-index]
      -- Since this is always a gainer we use "[dev_idx]1"
      for i=1,lines_in_pattern do   
        fx = renoise.song().patterns[_pi].tracks[_ti].lines[i].effect_columns[_fxci]
        -- The track volume fx command is '0Lxx'
        print("fx number string = " .. fx.number_string)
        print("fx amount string = " .. fx.amount_string)
        if (fx.number_string == dev_number_string ) then
          fx.number_string = ''
          fx.amount_string = ''
        end
      end
    else

      local fx = renoise.song().patterns[_pi].tracks[_ti].lines[1].effect_columns[_fxci]


      for i=1,lines_in_pattern do   
        fx = renoise.song().patterns[_pi].tracks[_ti].lines[i].effect_columns[_fxci]
        -- The track volume fx command is '0Lxx'
        print("fx number string = " .. fx.number_string)
        print("fx amount string = " .. fx.amount_string)
        if (fx.number_string == '0L') then
          fx.number_string = ''
          fx.amount_string = ''
        end
      end
    end
    return
  end

  if _col then
    for i=1,lines_in_pattern do   
      _tp.lines[i].note_columns[_col].volume_string = ''  
    end

  end

end -- func


-- ======================================================================
-- TODO:  This applies to a single entity.
--        It needs to work with a table of values that
--          will be applied repeatedly
--        That value loop needs to use a looping index (so we re-use the values)
--        The function needs to figure out where it is to apply the values:
--          If this is a note colume, then it uses the vol col.
--            (NOTE: If in the future the tool can apply arbitray fx commands this needs to change.)
--          If a track fx column is selected then values need to go there.
--          
--          ** ASSUMPTION ** Code will use the fx column currently selected
--          Really need to work out edge cases to handle tracks, groups, whatever.
--
-- FIXME Need error prevention: 
--  look for 
--    empty or nil values.
--    Out-of-range line numbers  (else it errors out)
--    Out of range volume values
-- ======================================================================
function alternate(value_list, lines_list)

  print("alternate. lines_list:")
  rprint(lines_list)

  print("alternate. value_list:")
  rprint(value_list)

  -- Right now we assume we only deal with volume values
  clear_existing_volumes()

  local _ti = renoise.song().selected_track_index
  local _pi   = renoise.song().selected_pattern_index
  local _col = renoise.song().selected_note_column_index
  local _tp   = renoise.song().patterns[_pi].tracks[_ti]
  local _fxci = renoise.song().selected_effect_column_index

  local lines_in_pattern = renoise.song().patterns[_pi].number_of_lines

  local v = 0



  if (_fxci and _fxci > 0 ) then
    print("_fxci = " , _fxci )
    local fx = _tp.lines[1].effect_columns[_fxci]


    -- We have an fx column selected.
    -- See if we have a gain device named ALTERNATOR
    print("_fxci = " , _fxci )

        local gainer, dev_idx = get_alternator_gainer_and_index(_ti)


    if gainer then
      print("We have the special gainer.  Now we need to set the values for it. Gainer index is ", dev_idx)
      --[[
      Do we simply toggle the gainer on and off, or so we set values 'Gain' values
      nn3F is a setting of 0db (i.e. pass thru the current volume)
      nn00 is zero.

      HOWEVER: What if we are dealing with a previous set of values that included
      C0 (the 0db value for the pre-fx volume?  C0 sets a gainer to 9.56 DB :(
      The rule thne is that we will always expect C0 as the "not mute" value
      and scale the given value to map to a gainer if that's the situation
      The gainer can at max be set to 12.04 db (nnFF)
      The root volume only goes to 3db  (LFF)
      The trick is to write a function that scales correctly.
      -inf to 3db
      -inf to 12.04db
                  
          if the hex is == to C0 then we use 3F for the gainer
          if not, convert to int
          if < 192 then map 0   .. 193 =>  0 ..  63
          if > 192 then map 192 .. 255 =>  63 .. 255

      and then convert back to hex string.

       But for now, assume that if the value is not 00 then use 3F 
              ]]--

              -- we need the device index number
            -- When the device index is 2, the automatoin number  ends up as  11. Why?
      -- Because: hh is [device-index][paramter-index]
      -- Since this is always a gainer we use "[dev_idx]1"

           local dev_number_string  = tostring(dev_idx - 1) .. "1"
            local dev_value_string = ''
            
              for i,l in ipairs(lines_list) do

                v = l + 1

                print(tostring(v))

                if ( v <= lines_in_pattern ) then

                  fx = _tp.lines[v].effect_columns[_fxci]
                  dev_value_string = value_list[1]  
                  if dev_value_string == 'C0' then
                      dev_value_string = '3F'
                  end
                  fx.amount_string = dev_value_string
                  fx.number_string = dev_number_string
                  value_list = U.wrap( value_list, 1)
                end

              end

            else


              -- The track volume fx command is '0Lxx'
              print("fx number string = " .. fx.number_string)
              print("fx amount string = " .. fx.amount_string)

              for i,l in ipairs(lines_list) do

                v = l + 1

                print(tostring(v))

                if ( v <= lines_in_pattern ) then

                  fx = _tp.lines[v].effect_columns[_fxci]

                  fx.amount_string = value_list[1]  
                  fx.number_string = '0L'
                  value_list = U.wrap( value_list, 1)
                end

              end

            end
            return
          end

          -- Still here? Then we are dealing with a note column

          for i,l in ipairs(lines_list) do
            v = l + 1
            print(tostring(v))

            if ( v <= lines_in_pattern ) then
              _tp.lines[v].note_columns[_col].volume_string = value_list[1]  
              value_list = U.wrap( value_list, 1)
            end
          end

        end


        -- ======================================================================
        function Core.new_set_from_funct_string(function_str, current_set)
          print("DEBUG: new_set_from_funct_string" ) -- JGB DEBUG
          local _pi   = renoise.song().selected_pattern_index
          local lines_in_pattern = renoise.song().patterns[_pi].number_of_lines
          local func_table = string.to_word_table(function_str)
          local func_char = table.remove(func_table, 1)

          U.str_table_to_int(func_table)
          local generated_line_table = {}
          local sorted_line_numbers = {}

          print("Dispatch on '" .. "'" .. func_char .. "'")

          -- FIXME If the user enters (for example) '+2 3' the value of func_char
          -- ends up as '+2', and this fails to match anything.
          -- We need code to fix that: Grab the first char, and then trim the remaining string
          -- BYW, why does   "table.remove(func_table, 1)"  return a 2-character result?
          -- Is it because of "func_table = string.to_word_table(function_str)"
          --
          if (func_char == "+") then
            generated_line_table = sequence_from_inc_set(func_table, lines_in_pattern, current_set)
          end

          if (func_char == "/") then
            generated_line_table = sequence_from_mod_set(func_table, lines_in_pattern, current_set)
          end

          for n in pairs(generated_line_table) do table.insert(sorted_line_numbers, n) end

          table.sort(sorted_line_numbers)

          return sorted_line_numbers
        end


        -- ======================================================================
        Core.set_alternate_values = function(gui)
          local values_string = string.trim(gui.fx_values_text)
          local values_list = string.to_word_table(values_string)
          local lines_list = string.int_list_to_numeric(gui.lines_list)
          alternate(values_list, lines_list)
        end

        return Core

