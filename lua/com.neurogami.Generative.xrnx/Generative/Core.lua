-- Core.lua 
Generative = {}

function Generative.loop_schedule(range_start, range_end)
    local song = renoise.song
    print("/loop/schedule! ", range_start, " ", range_end)
    song().transport:set_scheduled_sequence(clamp_value(range_start, 1, song().transport.song_length.sequence))
    local pos_start = song().transport.loop_start
    pos_start.line = 1; pos_start.sequence = clamp_value(range_start, 1, song().transport.song_length.sequence)
    local pos_end = song().transport.loop_end
    pos_end.line = 1; pos_end.sequence =  clamp_value(range_end + 1, 1, 
    song().transport.song_length.sequence + 1)
    song().transport.loop_range = {pos_start, pos_end}
end


return Generative
