#!/usr/bin/env ruby
# Assumes you are using jruby since on Windows the unimidi stuff fails on midi notes < 10

require 'java'
require 'unimidi'
require 'midi-eye'
require 'osc-ruby-ng'

COLOR_OFF   = 12      
RED_FLASH   = 11
RED_LOW     = 13      
RED_FULL    = 15 
AMBER_LOW   = 29      
AMBER_FULL  = 63      
YELLOW_FULL = 62      

GREEN_LOW   = 28      
GREEN_FLASH = 56  
GREEN_FULL  = 60      

CONTROL = 176
GRID    = 144

MAX_NOTE  = 120
# Need a way to scan the list of devices, find the one that is Launchpad, and select it

module UniMIDI::Device::ClassMethods
  def use_first_match name_re
    use_device all.select{|d| d.name =~ name_re }.first
  end
end

@input = UniMIDI::Input.use_first_match  /Launchpad/ 
  warn "\nUsing input device #{@input.class} #{@input.name} \n"
  @output = UniMIDI::Output.use_first_match /Launchpad/ 
  warn "\nUsing output device #{@output.class} #{@output.name} \n"

  # If you have two instances of renoise you will have to change
  # the OSC port on one of them.
  # The song port needs to be the one set for Master Muter
  osc_config = { :reference => {:address => '192.168.0.15', :port => 9000},
    :song => {:address => '192.168.0.58', :port => 8001 }

}

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

class OscDispatcher
  include  OSC


  def initialize config
    @config = config
    setup
  end

  def setup
    # Need clients for the song and the reference instance
    warn "setup OSC with #{@config}"
    _song = @config[:song]
    _reference = @config[:reference]

    @song      = OSC::Client.new _song[:address],      _song[:port]
    @reference = OSC::Client.new _reference[:address], _reference[:port]
  end


  def song_send msg
    Thread.new do
      begin
        @song.send msg
      rescue 
        warn '!'*80
        warn "Error sending @song OSC message: #{$!}"
        warn '!'*80
      end
    end
  end

  def reference_send msg
    Thread.new do
      begin
        warn "Send msg #{msg} to #{@reference}"
        @reference.send msg
      rescue 
        warn '!'*80
        warn "Error sending @song OSC message: #{$!}"
        warn '!'*80
      end
    end
  end

  def solo_song
    msg = OSC::Message.new  "/ng/master/set_mute" , 0
    song_send msg
  end


  def mute_song
    msg = OSC::Message.new  "/ng/master/set_mute" , 1
    song_send msg
  end



  def solo_reference track
    #       /renoise/song/track/XXX/solo
    #  or
    #       /renoise/song/track/XXX/mute   
    #       /renoise/song/track/XXX/unmute
    #
    # Which is better? Do we fire off a slwew of mutes, then a single unmute?
warn "solo reference track #{track}"
    mute_all_reference_tracks

    msg = OSC::Message.new  "/renoise/song/track/#{track}/unmute"
    reference_send msg
  end

  def mute_all_reference_tracks
    1.upto(8) do |track|
      msg = OSC::Message.new  "/renoise/song/track/#{track}/mute"
      reference_send msg  
    end
  end

end

class Launchpad

  SCENE_BUTTONS = [8, 24, 40, 56, 72, 88, 104,120]

  def initialize output, osc_config
    @output = output  
    @osc_config = osc_config
    @current_column = 0
    @current_scene = 0
    @current_control = 0
    @multi = false
    @multi_start = -1
    @multi_end = -1
  end

  def setup 
    clear 
    light_top_set 
    @output.puts 176, 0, 40
    @osc = OscDispatcher.new @osc_config
  end



  # Does a brief full on-off for effect
  def clear 
    @output.puts CONTROL, 0, 0
    sleep 0.3
    @output.puts CONTROL, 0, 127
    sleep 0.3
    @output.puts CONTROL, 0, 0
  end

  def light_top_set 
    104.upto(111) do |n|
      @output.puts CONTROL, n, RED_FULL 
    end
  end

  def column_from_note n

    # 0  ..  7 (8)
    # 16 .. 23 (24)
    # 32 .. 39 (40)
    # 40
    # 64
    # 80
    # 96
    # 112 
    n % 8
  end

  def clear_control_row
    104.upto(111) do |n|
      @output.puts CONTROL, n, COLOR_OFF  # note on
    end
  end

  def grid_off n
    @output.puts GRID, n, COLOR_OFF # note off
  end

  def clear_grid_column n
    col = column_from_note n
  end

  def light_column_from_to n, m
    warn "\n-------------------\nlight_column_from_to #{n}, #{m}"
    while n < m+1
      light_grid_button n
      n += 16
    end
  end

  def light_column_from n
    while n < MAX_NOTE  
      light_grid_button n
      n += 16
    end
  end

  def solo_audio column
    warn '-' * 90
    warn "     solo_audio #{column}    "
    warn '-' * 90
    if column == 0
      @osc.solo_song
      @osc.mute_all_reference_tracks
    else
      @osc.mute_song
      @osc.solo_reference column
    end

  end

  # This is slow.
  def clear_grid
    warn "************* CLEAR ****************"
    8.times do |r|
      8.times do |c| # The numbers jump +16 on each row.
        grid_off r*16 + c
      end
    end
  end

  def light_grid_button n, color=GREEN_FULL
    @output.puts GRID, n, color # note on
  end

  def handle_grid_button note_array

    # The current plan: Solo the selected track.
    #  We need to know the  column, and then decide
    #  what OSC to send
    if note_array[2].to_i > 0   
      clear_grid
      @current_grid = note_array[1]
      light_column_from  @current_grid
      solo_audio column_from_note @current_grid 
    end

  end

  def handle_scene_button note_array 
    if note_array[2].to_i > 0   
      @output.puts GRID, note_array[1], AMBER_FULL # note on
    else
      Thread.new do 
        sleep  0.5
        @output.puts GRID, note_array[1], COLOR_OFF # note off
      end
    end
  end

  def handle_top_control note_array
    if note_array[2].to_i > 0   

      clear_control_row
      @current_control = note_array[1]

      @output.puts CONTROL, @current_control, RED_FULL # note on
      #else
      #  Thread.new do 
      #    sleep  0.5
      #    @output.puts CONTROL, note_array[1], COLOR_OFF # note off
      #  end
    end
  end


  def min_max_notes message_array
    warn "min_max_notes #{message_array} "

    min,max = MAX_NOTE, 0

    message_array.each do |msg|
      warn "msg = #{msg}"
      data = msg[:data]
      if data[1].to_i < min
        min = data[1].to_i
      end
      if data[1].to_i > max
        max = data[1].to_i
      end
    end

    [min,max]
  end

  def process_multi messages
    clear_grid

    @multi_start, @multi_end = *(min_max_notes messages )
    light_column_from_to @multi_start, @multi_end
  end


  def process messages
    warn "process #{messages.inspect}"


    @multi = messages.size > 1

    if @multi
      process_multi messages
      return
    end

    messages.each do |msg|
      p msg
      note_array = msg[:data]

      case note_array[0].to_i
      when GRID 
        # The problem: End-of-row arrow keys come up as GRID notes
        # (These are alos called 'scene launch buttons')
        # They all resolve to n%8 == 0 but so do some other keys.
        # How cna we quickly tell if 
        if SCENE_BUTTONS.include? note_array[1].to_i
          warn "Handle a scene button #{note_array[1].to_i} ..."
          handle_scene_button note_array 
        else
          warn "Handle a grid button #{note_array[1].to_i}  ..."
          handle_grid_button note_array
        end
      when CONTROL
        handle_top_control note_array
      else
        warn "'process' does not know what to do with note thing #{note_array[0].to_i}"
      end
    end

    warn "Multi message? #{@multi}"
  end

end # End Launchpad class

# We need a plan, a guide to behavior when a message comes in
#  We do we assume? 


#Thread.new do 
#@listener.on_message do |event|
#  puts '.'
#  puts event[:timestamp]
#  puts event[:message]
#end

#end

@launchpad = Launchpad.new @output, osc_config
@launchpad.setup 

warn "Ready on #{`hostname`.to_s.strip}!"


# This works.  Have no idea why the callback version does nothing.
while 1
  m = @input.gets
  @launchpad.process m
  sleep 0.01
end


