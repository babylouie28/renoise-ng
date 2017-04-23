-- A place to stick function that might be useful when called as 
-- part of a loop definition 
function restart() 
  print("-------------- restart! -------------- ")
  Generative.current_loop = 0
  Generative.set_next_loop() -- This will incremtn te counter
end

function rand_jump() 
  print("-------------- rand_jump! -------------- ")
  Generative.current_loop = math.random(0, #Generative.loop_list - 1)
  print(" rand_jump set Generative.current_loop  to ", Generative.current_loop  )
  Generative.set_next_loop()
end

function rand_looping()
  print("----- rand_loop() ----")

  local r = math.random(1, 100)
  if r > 50  then
    print(" ********************* Reset loop pointer to current loop ********************* ")
    Generative.current_loop = Generative.current_loop - 1 
  end

  Generative.set_next_loop()
end


