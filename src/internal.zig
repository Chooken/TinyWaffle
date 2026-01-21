const std = @import("std");
const sdl3 = @import("sdl3");
const root = @import("root.zig");
const assert = @import("assert.zig");
const splash = @import("splash.zig");
pub const audio = @import("audio_internal.zig");
pub const assets = @import("assets_internal.zig");
pub const scene_management = @import("scene_internal.zig");

pub var allocator: std.mem.Allocator = undefined;

pub var playing_splash: bool = true;

pub var sdl_window: sdl3.video.Window = undefined;
pub var sdl_renderer: sdl3.render.Renderer = undefined;
pub var sdl_text_engine: sdl3.ttf.RendererTextEngine = undefined;

pub var application_running: bool = true;
pub var application_path: []u8 = undefined;

pub var clear_color: root.Color = root.Color.Black;

pub var last_frame_time: f32 = 0.016;

pub const KeyState = struct {
    down_first_frame: bool,
    down: bool,
};

pub var input: std.AutoHashMap(sdl3.keycode.Keycode, KeyState) = undefined;

pub fn run(title: [:0]const u8, width: usize, height: usize, start_scene: root.SceneManagement.Scene) void {
    defer sdl3.shutdown();

    const initFlags = sdl3.InitFlags { 
        .video = true, 
        .events = true,
        .audio = true,
    };

    assert.ok(sdl3.init(initFlags));
    assert.ok(sdl3.ttf.init());

    sdl_window, sdl_renderer = assert.ok(sdl3.render.Renderer.initWithWindow(
        title, 
        width, 
        height, 
        .{ .high_pixel_density = true, }));
    defer {
        sdl_renderer.deinit();
        sdl_window.deinit();
    }

    assert.ok(sdl_renderer.setVSync(sdl3.video.VSync.fromSdl(1)));

    sdl_text_engine = assert.ok(sdl3.ttf.RendererTextEngine.init(sdl_renderer));
    defer sdl_text_engine.deinit();

    assert.ok(audio.init());

    scene_management.setNext(start_scene);

    var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
    allocator = gpa.allocator();
    defer {
        const check = gpa.deinit();
        if (check == .leak)
        {
            std.debug.print("Leaked\n", .{});
        }
    } 

    application_path = assert.ok(std.fs.selfExeDirPathAlloc(allocator));
    defer allocator.free(application_path);

    input = std.AutoHashMap(sdl3.keycode.Keycode, KeyState).init(allocator);
    defer input.deinit();

    assert.ok(assets.init(allocator));
    defer assets.deinit();

    splash.init();

    assert.ok(loop());
}

fn loop() !void {

    var timer = try std.time.Timer.start();

    while (application_running) {
        // Events
        var iter = input.valueIterator();

        while (iter.next()) |value| {
            value.down_first_frame = false;
        }

        while (sdl3.events.poll()) |event| {
            switch (event) {
                .key_down => |key_event| {

                    if (key_event.key) |key| {

                        var state = input.getOrPut(key) catch unreachable;
                        state.value_ptr.down = true;

                        if (!key_event.repeat) {
                            state.value_ptr.down_first_frame = true;
                        }
                    }
                },
                .key_up => |key_event| {
                    if (key_event.key) |key| {
                        var state = input.getOrPut(key) catch unreachable;
                        state.value_ptr.down = false;
                    }
                },
                .quit => quit(),
                .terminating => quit(),
                else => {},
            }
        }

        // Clear Framebuffer.
        assert.ok(sdl_renderer.setDrawColor(.{
            .r = clear_color.r, 
            .g = clear_color.g, 
            .b = clear_color.b, 
            .a = clear_color.a }));
        assert.ok(sdl_renderer.clear());

        last_frame_time = @as(f32, @floatFromInt(timer.lap())) / std.time.ns_per_s ;

        if (playing_splash) {
            splash.update();
        }
        else {
            // Call Update Logic
            scene_management.update() catch |err| {
                std.debug.print("An error occured in a scene function: {s}\n", .{@errorName(err)});
            };
        }

        // Preset Framebuffer.
        assert.ok(sdl_renderer.present());
    }

    scene_management.exit();
}

pub fn quit() void {
    application_running = false;
}