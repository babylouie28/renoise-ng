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

function rand_looping()
  print("----- rand_loop() ----")

  local r = math.random(1, 100)
  if r > 50  then
    print(" ********************* Reset loop pointer to current loop ********************* ")
    LoopComposer.current_loop = LoopComposer.current_loop - 1 
  end

  LoopComposer.set_next_loop()
end


