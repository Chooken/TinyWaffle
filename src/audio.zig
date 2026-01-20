const internal = @import("internal.zig");
const assert = @import("assert.zig");

pub const Waveform = internal.audio.Waveform;
pub const Tone = internal.audio.Tone;

var tone1: Tone = .{ };
var tone2: Tone = .{ };
var tone3: Tone = .{ };
var tone4: Tone = .{ };

pub fn SetFrequency(channel: u8, frequency: f32) void {
    var tone = GetTone(channel);
    tone.frequency = frequency;
    ResumeTone(channel);
}

pub fn SetWaveform(channel: u8, waveform: Waveform) void {
    var tone = GetTone(channel);
    tone.waveform = waveform;
    ResumeTone(channel);
}

pub fn SetVolume(channel: u8, volume: f32) void
{
    const clamped = @max(@min(volume, 1), 0);

    var tone = GetTone(channel);
    tone.volume = clamped;
    ResumeTone(channel);
}

pub fn SetTone(channel: u8, tone: Tone) void {
    GetTone(channel).* = tone;
    SubmitTone(channel, tone);
}

pub fn StopTone(channel: u8) void {
    const tone = GetTone(channel);
    tone.isPlaying = false;
    SubmitTone(channel, tone.*);
}

pub fn ResumeTone(channel: u8) void {
    var tone = GetTone(channel);
    tone.isPlaying = true;
    SubmitTone(channel, tone.*);
}

fn SubmitTone(channel: u8, tone: Tone) void {
    internal.audio.setChannelTone(channel, tone);
}

fn GetTone(channel: u8) *Tone {
    return switch (channel) {
        0 => &tone1,
        1 => &tone2,
        2 => &tone3,
        3 => &tone4,
        else => unreachable,
    };
}