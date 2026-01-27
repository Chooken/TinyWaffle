const splashAnimation: []const u8 = @embedFile("./included_files/Engine Intro.png");
const TW = @import("root.zig");
const internal = @import("internal.zig");
const profiling = @import("profiling.zig");

pub const splash_scene = TW.SceneManagement.Scene {
    .on_enter = init,
    .on_update = update,
    .on_exit = exit,
};

pub var first_scene: ?TW.SceneManagement.Scene = null;

var texture_batch: TW.Renderer.TextureBatch = undefined;

pub fn init() !void {
    TW.Assert.ok(internal.assets.addInternalTextureFromData("splash", splashAnimation));
    TW.Renderer.setFov(3);

    const atlas: TW.TextureAtlas = TW.Assert.ok(TW.Assets.getTextureAtlas("splash", TW.Vec2(usize).from(18, 1)));
    texture_batch = TW.Renderer.TextureBatch.init(atlas);
}

var tick: f32 = 0;

pub fn update() !void {

    tick += TW.Time.getDeltaTime() * 10;

    if (tick > 20) {
        if (first_scene) |scene|{
            internal.scene_management.setNext(scene);
        } 
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

    texture_batch.add(
        frame, 
        TW.Vec2(f32).from(0, 0), 
        TW.Color.from(255, 255, 255, 255), 
        0);

    texture_batch.render();
}

fn exit() !void {
    TW.Renderer.setFov(17);
    texture_batch.deinit();
}