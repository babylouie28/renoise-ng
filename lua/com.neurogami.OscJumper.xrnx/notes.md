# OSC Jumper #



# Issues 

Notes:

Need to hit the tool with a barrage of OSC messages to see that it
- does not kill the OSC server
- shows decent latency

Also need to document how things (are supposed to) work:

- Setting up an OSC server for a tool so that you can call it with OSC

- Having a tool that can accept it's own OSC messages but also route stuff to the main Renoise OSC server

- Managing configuration loading and saving (which does not work right now)


** Tue Dec 16 15:08:32 MST 2014 **

How it works as of now:

If you load a song you'll have the tool menu showing Neurogami OSC Jumper

The OSC server has not started yet.

You have to click on the tool menu item "Start the OSC server"

You can then send standard Renoise messages such as /renoise/transport/start
as well as tool messages such as /ng/pattern/into 3 7

If you send message before turning on the server you get, from the ruby client,

     "Connection refused"

but, oddly, on every other message.

If you send a message with out-of-bounds values the OSC server dies and the tool is 
useless unless you reload it. :(

** Tue Dec 16 18:01:40 MST 2014 **

Tasks:

Wrap all OSC handling in error protection

Basic pcall usage:

    -- Error-prone function you the does the thing you hope
      local function attempt_remove_menu()
        renoise.tool():remove_menu_entry(menu_name)
      end

    -- Wrapper function to use pcall with function that you actually care abour
      local function close_song()
        pcall(attempt_remove_menu)
        print("Song was closed")
      end



But how?


The code defines a series of handlers and passes them off to

    osc_device:add_message_handler( h.pattern, h.handler )  

and that ends up at


    function OscDevice:add_message_handler(pattern, func)
      --if (self.handlers) then
      self.handlers[pattern] = func
      -- end
    end

Where do these handlers get called?

    OscDevice:socket_message(socket, binary_data)

seems to be the place


       if(self.handlers[pattern]) then
          print("Have a handler match on ", pattern)
          print("Have msg.arguments[1][1] ", msg.arguments[1][1])
          rPrint(msg.arguments, nil, "ARGS ");
          self.handlers[pattern](msg.arguments[1].value, msg.arguments[2].value   )
        else
          print(" * * * * *  No handler for  ", pattern, " * * * * ")
        end

Can pcall be stuffed in there?

yes:


          local res = pcall( self.handlers[pattern], msg.arguments[1].value, msg.arguments[2].value    )
          if res then
            print("Handler worked!");
              else
            print("Handler  error!");
          end


Seems to work.


Next task: Fix up config saving/loading




### Some assumptions ###

The song is something designed for use with OSC Jumper.  That means there are "mirror" or alt tracks; not a real "song" structure; sectiions meant to be looped.



### Some actions that would be handy ###

Quickly soloing some set of tracks, then restoring the previous volume settings.  For example, you wan to just hear kick and a bass line, then jump back to whatever was playing.

Preparing pattern loops using a starting pattern row and number of patterns.  Then when the current pattern ends it jumps to the start of the defined loop.

Jump to the start of a pattern, giving a scratching effect.

Jump back N lines.


## Keeping it simple ##

The client (i.e. Leap or Kinect or whatever) needs a way to associate certain actions with pre-set messages.

IOW, you can't be specifiy the two tracks to swap with hand movements; there needs to be some action that is already defined to do `/ng/pattern/swap 4 5 10`.

This could be based off some controllable aspect of the gesture; finger count or Y or Y.

We could map X (lef/right) to some set of paired tracks, with the client UI changing color to indicate what pair would be affected.

If we kept that number small (4?) but used a decent range (two feet?) then you could move to a track-pair quickly without having to be super precise.  Then, if a track-pair were active, use a clear gesture (circle? ) to do the volume swap.

The two most useful actions are track swapping and pattern jumping/looping.


THe current loop call always loop on a single pattern.  Is there a way to a) change this value when setting up the jump, and b) use  a gesture or something to alter the number of patterns to be used for the loop?

Maybe a circle gesture that alters a visible number? Or height, with higher upping that number?


