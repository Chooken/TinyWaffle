const std = @import("std");
const sdl3 = @import("sdl3");
const root = @import("root.zig");
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

pub fn GetSize() root.Vec2(usize) {
    const data: struct { usize, usize } = assert.ok(internal.application.sdl_window.getSizeInPixels());
    return .{ .x = data.@"0", .y = data.@"1" };
}

pub fn GetDensity() f32 {
    return assert.ok(internal.application.sdl_window.getPixelDensity());
}