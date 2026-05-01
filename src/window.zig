const std = @import("std");
const sdl3 = @import("sdl3");
const root = @import("root.zig");
const internal = @import("internal.zig");
const assert = @import("assert.zig");

pub const WindowSettings = struct {
    fullscreen: bool,
    resizable: bool,
};

pub fn GetSettings() WindowSettings {
    const windowFlags = internal.application.sdl_window.getFlags();

    return WindowSettings{
        .fullscreen = windowFlags.fullscreen,
        .resizable =  windowFlags.resizable,
    };
}

pub fn SetFullscreen(value: bool) void {
    assert.ok(internal.application.sdl_window.setFullscreen(value));
}

pub fn SetVSync(value: bool) void {
    internal.application.sdl_renderer.setVSync(sdl3.video.VSync {
        .on_each_num_refresh = if (value) 1 else 0,
    }) catch {
        if (sdl3.errors.get()) |err| {
            std.debug.print("Failed to set VSync to {?}: {s}", .{value, err});
        }
    };
}

pub fn GetVSync() bool {
    const opt_vsync = internal.application.sdl_renderer.getVSync() catch {
        if (sdl3.errors.get()) |err| {
            std.debug.print("Failed to get VSync state: {s}", .{err});
        }
    };

    if (opt_vsync) |_| {
        return true;
    }

    return false;
}

pub fn GetSize() root.Vec2(usize) {
    const data: struct { usize, usize } = assert.ok(internal.application.sdl_window.getSizeInPixels());
    return .{ .x = data.@"0", .y = data.@"1" };
}

pub fn GetDensity() f32 {
    return assert.ok(internal.application.sdl_window.getPixelDensity());
}
