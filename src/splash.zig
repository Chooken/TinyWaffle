const splashAnimation: []const u8 = @embedFile("./included_files/Engine Intro.png");
const TW = @import("root.zig");
const internal = @import("internal.zig");

pub fn init() void {
    TW.Assert.ok(internal.assets.addInternalTextureFromData("splash", splashAnimation));
    TW.Renderer.setFov(3);
}

var tick: f32 = 0;

pub fn update() void {

    tick += TW.Time.getDeltaTime() * 10;

    if (tick > 20) {
        TW.Renderer.setFov(17);
        internal.playing_splash = false;
        return;
    }

    const frame: usize = @min(@as(usize, @intFromFloat(tick)), 17);

    switch (frame) {

        3 => {
            TW.Audio.SetFrequency(0, 200);
            TW.Audio.SetWaveform(0, .Triangle);
        },

        6 => {
            TW.Audio.SetFrequency(0, 80);
            TW.Audio.SetWaveform(0, .Square);
        },
        7 => {
            TW.Audio.SetFrequency(0, 100);
            TW.Audio.SetWaveform(0, .Square);
        },
        8 => {
            TW.Audio.SetFrequency(0, 80);
            TW.Audio.SetWaveform(0, .Square);
        },

        10 => {
            TW.Audio.SetFrequency(0, 80);
            TW.Audio.SetWaveform(0, .Triangle);
        },
        11 => {
            TW.Audio.SetFrequency(0, 90);
            TW.Audio.SetWaveform(0, .Triangle);
        },
        12 => {
            TW.Audio.SetFrequency(0, 100);
            TW.Audio.SetWaveform(0, .Triangle);
        },
        13 => {
            TW.Audio.SetFrequency(0, 110);
            TW.Audio.SetWaveform(0, .Triangle);
        },
        14 => {
            TW.Audio.SetFrequency(0, 120);
            TW.Audio.SetWaveform(0, .Triangle);
        },
        
        else => { 
            TW.Audio.StopTone(0);
            TW.Audio.StopTone(1);
        },
    }

    var atlas: TW.TextureAtlas = TW.Assert.ok(TW.Assets.getTextureAtlas("splash", TW.Vec2(usize).from(18, 1)));

    TW.Renderer.drawTexture(
        atlas.get(frame), 
        .{
            .x = 0,
            .y = 0,
        },
        TW.Color.from(255, 255, 255, 255));
}

fn End() void {
    TW.Renderer.setFov(17);
}