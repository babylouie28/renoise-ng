require "micromidi"

# Does not play nice with Launchpad
#
input = UniMIDI::Input.gets
output = UniMIDI::Output.gets

MIDI.using(input, output) do

  thru_except :note do |message|
#    message.note += 12
 #   output(message)
 p message
  end

  join

end

