
-- ***************************************************************************
-- A place to stick function that might be useful when called as 
-- part of a loop definition 
function restart() 
  print("-------------- restart! -------------- ")
  LoopComposer.current_loop = 0
  LoopComposer.set_next_loop() -- This will incremtn te counter
end

function rand_jump() 
  print("-------------- rand_jump! -------------- ")
  LoopComposer.current_loop = math.random(0, #LoopComposer.loop_list - 1)
  print(" rand_jump set LoopComposer.current_loop  to ", LoopComposer.current_loop  )
  LoopComposer.set_next_loop()
end


-- ***************************************************************************
-- We now allow args to be passed, but they will arrive as a list or something
function rand_looping(targs)
  local cutoff = 50

  if(targs) then
    cutoff = targs[1] or cutoff 
    cutoff = tonumber(cutoff)
  end

  local r = math.random(1, 100)
  print("----- rand_loop() ----", r)

  if r > cutoff then
    print(" ************* Reset loop pointer to current loop *************** ")
    LoopComposer.current_loop = LoopComposer.current_loop - 1   
  end

  LoopComposer.set_next_loop()
end

-- ***************************************************************************
-- We now allow args to be passed, but they will arrive as a list or something
function goto(targs)
  print("goto has targs: ")
  rprint(targs)
  
  local next_loop = 0

  if(targs) then
    -- Select a random value from targs on the
    -- chance we have decided to pass more than one option
    next_loop = targs[ math.random(#targs) ]
    print("================ goto " .. next_loop .. " =============")
    next_loop = tonumber(next_loop)
  else
    -- Error.  Now what?
    print("******************************************************************")
    print("******************************************************************")
    print("     ERROR: Cannot call goto without at least one tatgs value.   ")
    print("******************************************************************")
    print("******************************************************************")
  end

  LoopComposer.set_next_loop(next_loop)
end


