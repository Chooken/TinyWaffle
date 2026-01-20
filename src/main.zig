const std = @import("std");
const TW = @import("TinyWaffle");

pub fn main() !void {
    TW.run("Tiny Waffle", 800, 600, update);
}

pub fn update() anyerror!void {

    var atlas = try TW.Assets.getTextureAtlas("tilesheet.png", TW.Vec2(usize).from(8, 8));

    if (TW.Input.isKeyPressed(TW.Input.Keycode.A))
    {
        atlas.get(1).setColorAt(.{ .x = 0, .y = 0 }, TW.Color.from(255,0,0,255));
    }

    for (0..3) |y|
    for (0..7) |x| {
        TW.Renderer.drawRect(.{
            .x = -3 + @as(f32, @floatFromInt(x)),
            .y = @as(f32, @floatFromInt(y)),
            .w = 1,
            .h = 1,
        }, TW.Color.from(122, 0, 70, 255));
    };

    TW.Renderer.drawTexture(
        atlas.get(1), 
        .{
            .x = 0,
            .y = 0,
        },
        TW.Color.from(255, 0, 0, 255));

    TW.Renderer.drawText(
        TW.Rect(f32).from(-2.6, 0.25, 7, 0), 
        "Nunito-Regular.ttf", 
        "Hello Darkness my old friend. It's good to see you again.",
        TW.Color.from(255, 255, 0, 255));

    TW.Renderer.drawLine(
        TW.Vec2(f32).from(0, 0), 
        TW.Vec2(f32).from(1, 1),
        TW.Color.fromRgb(255, 255, 0));

    TW.Audio.SetFrequency(0, 120);
    TW.Audio.SetWaveform(0, .Sin);
}
