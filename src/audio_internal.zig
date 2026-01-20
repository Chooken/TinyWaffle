const std = @import("std");
const sdl3 = @import("sdl3");
const assert = @import("assert.zig");

pub const Waveform = enum {
    Sin,
    Square,
    Triangle,
};

pub const Tone = struct {
    isPlaying: bool = false,
    waveform: Waveform = .Sin,
    frequency: f32 = 0,
    volume: f32 = 1,
};

var osculator1: Osculator = .{};
var audioStream1: sdl3.audio.Stream = undefined;

var osculator2: Osculator = .{};
var audioStream2: sdl3.audio.Stream = undefined;

var osculator3: Osculator = .{};
var audioStream3: sdl3.audio.Stream = undefined;

var osculator4: Osculator = .{};
var audioStream4: sdl3.audio.Stream = undefined;

pub fn setChannelTone(channel: u8, tone: Tone) void {
    assert.true(channel < 4, "Using a channel that doesn't exist.");

    switch (channel) {
        0 => osculator1.set(tone),
        1 => osculator2.set(tone),
        2 => osculator3.set(tone),
        3 => osculator4.set(tone),
        else => unreachable
    }
}

pub fn init() !void {

    // Make a spec for audio stream.
    const spec = sdl3.audio.Spec {
        .sample_rate = SAMPLE_RATE,
        .num_channels = 1,
        .format = if (sdl3.endian.byteOrder() == .little) sdl3.audio.Format.floating_32_bit_little_endian 
            else sdl3.audio.Format.floating_32_bit_big_endian,
    };

    // Creates a stream with 440hz frequency.
    audioStream1 = try sdl3.audio.Device.default_playback.openStream(spec, Osculator, GetOsculatorData, &osculator1);
    audioStream2 = try sdl3.audio.Device.default_playback.openStream(spec, Osculator, GetOsculatorData, &osculator2);
    audioStream3 = try sdl3.audio.Device.default_playback.openStream(spec, Osculator, GetOsculatorData, &osculator3);
    audioStream4 = try sdl3.audio.Device.default_playback.openStream(spec, Osculator, GetOsculatorData, &osculator4);

    // Play Audio
    try audioStream1.resumeDevice();
    try audioStream2.resumeDevice();
    try audioStream3.resumeDevice();
    try audioStream4.resumeDevice();
}

const SAMPLE_RATE = 8000.0;

const Osculator = struct {
    current_step: f32 = 0,
    waveform: Waveform = .Sin,
    step_size: f32 = 0,
    volume: f32 = 0,
    last: f32 = 0,
    tone: Tone = .{},

    pub fn set(self: *Osculator, tone: Tone) void {
        self.tone = tone;
    }

    fn update(self: *Osculator) void {
        self.volume = if (self.tone.isPlaying) self.tone.volume else 0;
        self.waveform = self.tone.waveform;
        self.step_size = 1.0 / (SAMPLE_RATE / self.tone.frequency);
    }

    pub fn next(self: *Osculator) f32 {

        self.current_step += self.step_size;

        if (self.current_step > 1 or self.step_size == 0) { 
            self.update();
        }

        if (self.current_step > 1) { 
            self.current_step -= 1; 
        }

        const desired = switch (self.waveform) {
            .Sin => std.math.sin((2.0 * std.math.pi) * self.current_step),
            .Square => std.math.sign(std.math.sin((2.0 * std.math.pi) * self.current_step)) / 6,
            .Triangle => 2.0 / std.math.pi * std.math.asin(std.math.sin((2.0 * std.math.pi) * self.current_step)),
        };

        return desired * self.volume * self.volume;

        // Attempted Aliasing
        // const distance = std.math.sign(desired * self.volume * self.volume - self.last) * @min(@abs(desired * self.volume * self.volume - self.last), 1.0 / 10.0);

        // self.last = desired * self.volume * self.volume;

        // return self.last + distance;
    }
};

fn GetOsculatorData(osculator: ?*Osculator, stream: sdl3.audio.Stream, additional: usize, _: usize) void {
    
    // Get how many additional floats to provide.
    var new_additional = additional / @sizeOf(f32);

    // Chunk to upload.
    var samples: [128]f32 = undefined;

    // Do till don't need any additional values.
    while(new_additional > 0) {
    
        const max = @min(new_additional, samples.len);

        for (0..max) |index| {

            samples[index] = osculator.?.next();
        }

        stream.putData(@ptrCast(samples[0..max])) catch break;
        new_additional -= max;
    }
}



// fn GetAudioData (tone: ?*Tone, stream: sdl3.audio.Stream, additional: usize, _: usize) void {

//     // Get how many additional floats to provide.
//     var new_additional = additional / @sizeOf(f32);

//     // Chunk to upload.
//     var samples: [128]f32 = undefined;

//     // Do till don't need any additional values.
//     while(new_additional > 0) {
    
//         const max = @min(new_additional, samples.len);

//         for (0..max) |index| {

//             const freq = if (tone.?.isPlaying) tone.?.frequency else 0;

//             const phase: f32 = tone.?.sample_index * freq / SAMPLE_RATE;

//             const desired_position = switch (tone.?.wave) {
//                 .Sin => std.math.sin(phase * 2 * std.math.pi),
//                 .Square => std.math.sign(std.math.sin(phase * 2 * std.math.pi)) / 8,
//                 .Triangle => 2.0 / std.math.pi * std.math.asin(std.math.sin(phase * 2 * std.math.pi)),
//             };

//             const distance = @min(desired_position - tone.?.last_pos, 1.0 / 40.0);

//             samples[index] = tone.?.last_pos + distance;

//             tone.?.last_pos = samples[index];
            
//             tone.?.sample_index += 1;
//         }

//         tone.?.sample_index = @mod(tone.?.sample_index, SAMPLE_RATE);

//         stream.putData(@ptrCast(samples[0..max])) catch break;
//         new_additional -= max;
//     }
// }