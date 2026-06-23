const std = @import("std");
const internal = @import("internal.zig");

pub fn getApplicationPath() []u8 {
    return internal.application.path;
}

pub fn getAllocator() std.mem.Allocator {
    return internal.allocator;
}

pub fn getIo() std.Io {
    return internal.io;
}

pub fn quit() void {
    internal.application.quit();
}