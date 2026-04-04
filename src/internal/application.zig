const std = @import("std");
const sdl3 = @import("sdl3");
const root = @import("../root.zig");
const assert = @import("../assert.zig");
const splash = @import("../splash.zig");
const internal = @import("../internal.zig");

const waffle_debug_font: []const u8 = @embedFile("../included_files/RobotoMono-VariableFont_wght.ttf");

pub var sdl_window: sdl3.video.Window = undefined;
pub var sdl_renderer: sdl3.render.Renderer = undefined;
pub var sdl_text_engine: sdl3.ttf.RendererTextEngine = undefined;

pub var application_running: bool = true;
pub var path: []u8 = undefined;

pub var clear_color: root.Color = root.Color.Black;
pub var last_frame_time: f32 = 0.016;

pub const StartOptions = struct {
    title: [:0]const u8,
    width: usize = 800,
    height: usize = 600,
    resizeable: bool = false,
    start_volume: f32 = 0.25,
    skip_splash: bool = false,
};

pub fn run(start_options: StartOptions, start_scene: root.scene_management.Scene) void {
    assert.ok(internal.initAllocator());
    defer internal.deinitAllocator();

    const initFlags = sdl3.InitFlags { 
        .video = true, 
        .events = true,
        .audio = true,
    };

    assert.ok(sdl3.init(initFlags));
    assert.ok(sdl3.ttf.init());
    defer sdl3.shutdown();

    sdl_window, sdl_renderer = assert.ok(sdl3.render.Renderer.initWithWindow(
        start_options.title, 
        start_options.width, 
        start_options.height, 
        .{ .high_pixel_density = true, .resizable = start_options.resizeable }));
    defer {
        sdl_renderer.deinit();
        sdl_window.deinit();
    }

    assert.ok(sdl_renderer.setVSync(sdl3.video.VSync.fromSdl(1)));

    assert.ok(internal.init());
    defer internal.deinit();

    assert.ok(internal.assets.addInternalFontFromData("Waffle_Debug_", waffle_debug_font));

    sdl_text_engine = assert.ok(sdl3.ttf.RendererTextEngine.init(sdl_renderer));
    defer sdl_text_engine.deinit();

    path = assert.ok(std.fs.selfExeDirPathAlloc(internal.allocator));
    defer internal.allocator.free(path);

    if (start_options.skip_splash) {
        internal.scene_management.setNext(start_scene);
    } else {
        splash.first_scene = start_scene;
        internal.scene_management.setNext(splash.splash_scene);
    }

    if (start_options.resizeable) {
        _ = assert.ok(sdl3.events.addWatch(anyopaque, handleResizeEvents, null));
    }

    internal.audio.setGlobalVolume(start_options.start_volume);

    assert.ok(loop());
}

fn handleResizeEvents(_: ?*anyopaque, event: *sdl3.events.Event) bool {

    switch (event.*) {

        .window_pixel_size_changed, .window_resized => {

            // Clear Framebuffer.
            assert.ok(sdl_renderer.setDrawColor(.{
                .r = clear_color.r, 
                .g = clear_color.g, 
                .b = clear_color.b, 
                .a = clear_color.a }));
            assert.ok(sdl_renderer.clear());

            // Call Update Logic
            internal.scene_management.update() catch |err| {
                std.debug.print("An error occured in a scene function: {s}\n", .{@errorName(err)});
            };

            // Preset Framebuffer.
            assert.ok(sdl_renderer.present());
        },

        else => return true,
    }

    return true;
} 

fn loop() !void {

    var timer = try std.time.Timer.start();

    while (application_running) {

        internal.profiling.reset();

        internal.profiling.startScope("Total");

        // Events
        internal.profiling.startScope("Events");

        internal.profiling.startScope("Reset Key States");

        internal.input.resetMouseState();
        internal.input.resetKeyStates();
        internal.input.resetKeyboardInput();

        internal.profiling.endScope("Reset Key States");

        internal.profiling.startScope("Poll Window Events");

        while (sdl3.events.poll()) |event| {
            switch (event) {
                .mouse_button_down => |mouse_event| {
                    internal.input.onMouseEvent(mouse_event);
                },
                .mouse_button_up => |mouse_event| {
                    internal.input.onMouseEvent(mouse_event);
                },
                .mouse_motion => |mouse_event| {
                    internal.input.onMouseMotion(mouse_event);
                },
                .key_down => |key_event| {
                    internal.input.onKeyDownEvent(key_event);
                },
                .key_up => |key_event| {
                    internal.input.onKeyUpEvent(key_event);
                },
                .text_input => |text_event| {
                    internal.input.addToKeyboardBuffer(text_event.text);
                },
                .quit => quit(),
                .terminating => quit(),
                else => {},
            }
        }

        internal.profiling.endScope("Poll Window Events");

        internal.profiling.endScope("Events");

        internal.profiling.startScope("App Update");

        // Clear Framebuffer.
        assert.ok(sdl_renderer.setDrawColor(.{
            .r = clear_color.r, 
            .g = clear_color.g, 
            .b = clear_color.b, 
            .a = clear_color.a }));
        assert.ok(sdl_renderer.clear());

        last_frame_time = @as(f32, @floatFromInt(timer.lap())) / std.time.ns_per_s ;

        internal.profiling.startScope("Scene Update");

        // Call Update Logic
        internal.scene_management.update() catch |err| {
            std.debug.print("An error occured in a scene function: {s}\n", .{@errorName(err)});
        };

        internal.profiling.endScope("Scene Update");

        internal.profiling.endScope("App Update");

        internal.profiling.endScope("Total");

        root.profiling.renderProfiler();

        // Preset Framebuffer.
        assert.ok(sdl_renderer.present());

        //profiling.printTimings();
    }

    internal.scene_management.exit();
}

pub fn quit() void {
    application_running = false;
}