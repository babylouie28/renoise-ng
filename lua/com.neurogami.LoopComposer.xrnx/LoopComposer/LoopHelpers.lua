-- A place to stick function that might be useful when called as 
-- part of a loop definition 
function restart() 
  print("-------------- restart! -------------- ")
  LoopComposer.current_loop  = 1
  LoopComposer.set_next_loop()
end

function rand_jump() 
  print("-------------- rand_jump! -------------- ")
  LoopComposer.current_loop = math.random(1, #LoopComposer.loop_list)
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


