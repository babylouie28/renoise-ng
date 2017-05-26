#!/usr/bin/env ruby
# Should this be done with JRuby?
# Seems to work OK using plain old Ruby on Windows 
# http://tx81z.blogspot.com/2011/06/high-level-midi-io-with-ruby.html
require 'unimidi'
require 'midi-eye'

COLOR_OFF   = 12      
RED_LOW     = 13      
RED_FULL    = 15 
AMBER_LOW   = 29      
AMBER_FULL  = 63      
YELLOW_FULL = 62      
GREEN_LOW   = 28      
GREEN_FULL  = 60      


CONTROL = 176
GRID    = 144

select = ARGV.first


@input = if select
           UniMIDI::Input.use select.to_i
         else
           UniMIDI::Input.gets
         end

warn "Using device #{@input.inspect} "

@listener =  MIDIEye::Listener.new @input


@output = UniMIDI::Output.gets

# If you have two instances of renoise you will have to change
# the OSC port on one of them.
refererence = {:address => '127.0.0.1', :port => 900}

song = {:address => '127.0.0.1', :port => 8001 }


=begin
Launchpad motes:

/There is a top row of circle buttons:

104 105 106 107 108 109 110 111

Then the grid: 

0  ..  7 (8)
16 .. 23 (24)
32 .. 39 (40)

...

112 .. 119 (120)


We want to grid to map to reference track soloing.

The end button on each row solos the song.

A possible plan:

Top button just alters soloing, leaving the song position as it is.

Lower buttons will alter soloing but jump the song position.

Bonus points if you can find a way to set loop points for each audio source.

Maybe use the top row of circle buttons to select an adio item, then grid buttons
change behavior.  

Anyways, a simple mapping wold be note-on values to OSC messages.

We know basically waht is supposed to happen. Either solo a ref track and mute the song,
or unmute the song and mute (unsolo?) the ref track.

(If we solo/unsolo a track in the reference insance, what happens? )

So maybe we can then map MIDI notes to integers that indicate what adio source takes
precedence, and invoke a method that knows what that int means.

We assme there are a max of 8 reference sources.  So 0..7 are refs, 8 is song.

For the launchpad we can derive this.  Perhaps the "config" file
fo any given controller is a rby fle that provides a method to convert the
note to something

=end

=begin

The following tables of pre-calculated velocity values for normal use may also be helpful: 
Hex     Decimal  Colour     Brightness 
 0Ch      12      Off         Off 
 0Dh      13      Red         Low 
 0Fh      15      Red         Full 
 1Dh      29      Amber       Low 
 3Fh      63      Amber       Full 
 3Eh      62      Yellow      Full 
 1Ch      28      Green       Low 
 3Ch      60      Green       Full 

Values for flashing LEDs are: 
Hex  Decimal  Colour  Brightness 
 0Bh  11  Red  Full 
 3Bh  59  Amber  Full 
 3Ah  58  Yellow  Full 
 38h  56  Green  Full 


=end

class Launchpad
  def initialize output
    @output = output  
  end

  def setup
  clear 
  light_top_set 
end

  def clear 
    121.times do |n|
      @output.puts(0x90, n, 15) # note on
      @output.puts(0x90, n, 60) # note on
#      sleep  0.05

      @output.puts(0x80, n, 0) # note off
    end

  end

  def light_top_set 
  104.upto(111) do |n|
      @output.puts(CONTROL, n, GREEN_FULL) # note on
  end
  end

end



def dispatch note_array

# First grid button gives this:
#   [{:data=>[144, 0, 127], :timestamp=>3775}]
#  [{:data=>[144], :timestamp=>3900}]

# Fifth button
#  [{:data=>[144, 5, 127], :timestamp=>34086}]
#  [{:data=>[144, 0], :timestamp=>34226}]
#  No note-off note value   

  p note_array
  note_array.each do |note_hash|
    note_array = note_hash[:data]
    if note_array[2]  # Note-on has three values
      # Handle note_array[1], the note value

      case note_array[0].to_i
      when 144
        @output.puts(0x90, note_array[1], GREEN_FULL) # note on
      when 176 # Top circle buttons
        
        @output.puts(CONTROL, note_array[1], RED_FULL) # note on
      end

    else

    #case note_array[0].to_i   
   # 
    #  when 144
    #    @output.puts(GRID, note_array[1], 0) # note on
    #  when 176 # Top circle buttons
    #    
    #    @output.puts(CONTROL, note_array[1], 0) # note on
    #  end


    end
  end
end



#Thread.new do 
#@listener.on_message do |event|
#  puts '.'
#  puts event[:timestamp]
#  puts event[:message]
#end

#end

@launchad = Launchpad.new @output 

@launchad.setup

warn "Ready!"

# We need something that takes a MIDI note and
# looks up a correspondng OSC action

# This works.  Have no idea why the callback version does nothing.
while 1

  m = @input.gets
  #  puts m.inspect
  dispatch m

  sleep 0.01
end


