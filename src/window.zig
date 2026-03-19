const std = @import("std");
const sdl3 = @import("sdl3");
const internal = @import("internal.zig");
const assert = @import("assert.zig");

pub const WindowSettings = struct {
    fullscreen: bool,
};

pub fn GetSettings() WindowSettings {

    const windowFlags = internal.application.sdl_window.getFlags();

    return WindowSettings {
        .fullscreen = windowFlags.fullscreen,
    };
}

pub fn SetFullscreen(value: bool) void {
    assert.ok(internal.application.sdl_window.setFullscreen(value));
}

pub fn GetDensity() f32 {
    return tw.assert.ok(internal.application.sdl_window.getPixelDensity());
}