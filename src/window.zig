const std = @import("std");
const sdl3 = @import("sdl3");
const internal = @import("internal.zig");

pub const WindowSettings = struct {
    fullscreen: bool,
};

pub fn GetSettings() WindowSettings {

    const windowFlags = internal.sdl_window.getFlags();

    return WindowSettings {
        .fullscreen = windowFlags.fullscreen,
    };
}

pub fn SetFullscreen(value: bool) void {
    internal.sdl_window.setFullscreen(value);
}