const std = @import("std");
const TW = @import("TinyWaffle");

pub fn main() !void {
    TW.run("Tiny Waffle", 800, 600, update);
}

pub fn update() anyerror!void {

    for (0..3) |y|
    for (0..7) |x| {
        TW.Renderer.drawRect(.{
            .x = -3 + @as(f32, @floatFromInt(x)),
            .y = @as(f32, @floatFromInt(y)),
            .w = 1,
            .h = 1,
        }, TW.Color.from(122, 0, 70, 255));
    };

    TW.Renderer.drawLine(
        TW.Vec2(f32).from(0, 0), 
        TW.Vec2(f32).from(1, 1),
        TW.Color.fromRgb(255, 255, 0));

    TW.Audio.SetFrequency(0, 120);
    TW.Audio.SetWaveform(0, .Sin);
}
