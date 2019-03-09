function calculate_swap_pairs(num_pattern_lines, mod_num, line_gap)
  --[[
      pattern = "/track/swap_lines_current_pattern",
       handler = function(selected_track_index, mod_num, line_gap)
       BeatMasher.swap_lines_pattern_track(selected_track_index, mod_num, line_gap)
    end 
--]]


--[[
  In practice, a 32-line pattern of simple chromatic notes with spaces
   (c,_,c#,_, d, _, d#, _ ...)
   when you repeatedly apply 
        /ng/track/swap_lines_current_pattern 1 1 4
    you get     d5, _, d#5, _,  c4, _,  c#4 _,    repeating.

    But if you look at the resulting numbers there are no lines repeated.

But note this:

    1       <=>     29
    2       <=>     30
    3       <=>     31
    4       <=>     32
    5       <=>     9
    6       <=>     10
    7       <=>     11
    8       <=>     12

  Why is 1 swapping with 29 and not 5, if line gap is 4?

  Should the calc start at mod_num?

  Before the wrapping, those values were

  
    1       <=>     5
    2       <=>     6
    3       <=>     7
    4       <=>     8
    5       <=>     9
    6       <=>     10
    7       <=>     11
    8       <=>     12
    9       <=>     13
         ...
    32      <=>     36
    33      <=>     29
    34      <=>     30
    35      <=>     31
    36      <=>     32


  Well, this is wrong

  If we are to swap 1 and 5, but also 29 and 33, that becomes 29 and 1

  The wrapping is broken.

Thu 04 Oct 2018 22:21:53

New rule: Once a line number is in the set it cannot be added again.

--]]
  
  local swap_pairs = {}
  local swap_pairs_wrapped = {}
  
  --[[

  Assume we have mod_num 3 and line_gap 2 (meaning e.g. swap lines 3 and 5)
  s usual we never start at line zero; might want to consider a way to pass that as an option.
  So we start at mod_num
  ]]

  -- If we are swapping, why not put both directions in
  -- the same table?  n -> m, and m -> n
  -- Then later code just does a straight copy of items
  -- (and does not need to do both a to j and j to i?
  local _gapline

  for i=mod_num, num_pattern_lines, mod_num do
    _gapline = i + line_gap
    if (swap_pairs[i] == nil ) then
    if (swap_pairs[_gapline ] == nil ) then
    swap_pairs[i] = _gapline 
    swap_pairs[ _gapline ] = i 
  end
  end
  end

  -- Need to account for pattern wrap
  for i,j in pairs(swap_pairs) do  
    i = ( (i-1) % num_pattern_lines ) + 1 
    j = ( (j-1) % num_pattern_lines ) + 1 

    if (swap_pairs_wrapped[i] == nil ) then
      if (swap_pairs_wrapped[ j ] == nil ) then
       swap_pairs_wrapped[i] = j    
       swap_pairs_wrapped[j] = i    
      end
    end

  end


  for k,v in pairs(swap_pairs_wrapped) do 
  print( tostring(k) .. "\t<=>\t" .. tostring(v) )
end

  return(swap_pairs_wrapped);
  -- return(swap_pairs);

end


function _swap_lines_pattern_track(selected_track_index, mod_num, line_gap)
  -- print("Begin swap fuction ... ")


  --[[

  We want something we can verify.  A function that produces values that can then be called
  by the actual swap code, which should only be concerned with access to song().

  This way we can see that the values are legit withou mocking stuff.

  The plan has been this:

  Duplicate the pattern-track (PT)

  Calculate the line pairs: an array of [orig_line, swap_line]

  Copy the line content from COPY[swap_line] to PT[orig_line]

  Copy the line content from COPY[orig_line] to PT[copy_line]

  In the simplest case, we would swap (e.g.) lines 4 and 13

  pairs = {{4,13}}




  --]]

  local num_pattern_lines = 16

  local swap_pairs = calculate_swap_pairs(num_pattern_lines, mod_num, line_gap)
end


local selected_track_index = 1
local mod_num = 1
local line_gap = 4
local num_pattern_lines = 32

local swap_pairs = calculate_swap_pairs(num_pattern_lines, mod_num, line_gap)



--   ************************************** ---

print("\nSwap lines, using mod_num ", mod_num, "; line_gap ", line_gap, "; num_pattern_lines ", num_pattern_lines, "\n" ) 
for k,v in pairs(swap_pairs) do 
  print( tostring(k) .. "\t<=>\t" .. tostring(v) )
end

