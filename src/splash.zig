const splashAnimation: []const u8 = @embedFile("./included_files/Engine Intro.png");
const TW = @import("root.zig");
const internal = @import("internal.zig");
const profiling = @import("profiling.zig");

pub const splash_scene = TW.scene_management.Scene {
    .on_enter = init,
    .on_update = update,
    .on_exit = exit,
};

pub var first_scene: ?TW.scene_management.Scene = null;

var texture_batch: TW.renderer.TextureBatch = undefined;

pub fn init() !void {
    TW.assert.ok(internal.assets.addInternalTextureFromData("splash", splashAnimation));
    TW.renderer.setFov(3);

    const atlas: TW.TextureAtlas = TW.assert.ok(TW.assets.getTextureAtlas("splash", TW.Vec2(usize).from(18, 1)));
    texture_batch = TW.renderer.TextureBatch.init(atlas);
}

var tick: f32 = 0;

pub fn update() !void {

    tick += TW.time.getDeltaTime() * 10;

    if (tick > 20) {
        if (first_scene) |scene|{
            internal.scene_management.setNext(scene);
        } 
        return;
    }

    const frame: usize = @min(@as(usize, @intFromFloat(tick)), 17);

    switch (frame) {

        3 => {
            TW.audio.SetFrequency(0, 200);
            TW.audio.SetWaveform(0, .Triangle);
        },

        6 => {
            TW.audio.SetFrequency(0, 80);
            TW.audio.SetWaveform(0, .Square);
        },
        7 => {
            TW.audio.SetFrequency(0, 100);
            TW.audio.SetWaveform(0, .Square);
        },
        8 => {
            TW.audio.SetFrequency(0, 80);
            TW.audio.SetWaveform(0, .Square);
        },

        10 => {
            TW.audio.SetFrequency(0, 80);
            TW.audio.SetWaveform(0, .Triangle);
        },
        11 => {
            TW.audio.SetFrequency(0, 90);
            TW.audio.SetWaveform(0, .Triangle);
        },
        12 => {
            TW.audio.SetFrequency(0, 100);
            TW.audio.SetWaveform(0, .Triangle);
        },
        13 => {
            TW.audio.SetFrequency(0, 110);
            TW.audio.SetWaveform(0, .Triangle);
        },
        14 => {
            TW.audio.SetFrequency(0, 120);
            TW.audio.SetWaveform(0, .Triangle);
        },
        
        else => { 
            TW.audio.StopTone(0);
            TW.audio.StopTone(1);
        },
    }

    texture_batch.add(
        frame, 
        TW.Rect(f32).from(0, 0, 1, 1), 
        TW.Color.from(255, 255, 255, 255), 
        0);

    texture_batch.render();
}

fn exit() !void {
    TW.renderer.setFov(17);
    texture_batch.deinit();
}