const std = @import("std");
pub const application = @import("internal/application.zig");
pub const assets = @import("internal/assets.zig");
pub const profiling = @import("internal/profiling.zig");
pub const audio = @import("internal/audio.zig");
pub const scene_management = @import("internal/scenemanagement.zig");
pub const input = @import("internal/input.zig");
pub const assert = @import("assert.zig");

var gpa: std.heap.DebugAllocator(.{}) = .init;
pub var allocator: std.mem.Allocator = undefined;

var threaded: std.Io.Threaded = undefined;
pub var io: std.Io = undefined;

pub fn initAllocator() void {
    allocator = gpa.allocator();
}

pub fn initIo() void {
    threaded = .init_single_threaded;
    io = threaded.io();
}

pub fn deinitAllocator() void {
    const check = gpa.deinit();
    if (check == .leak) {
        std.debug.print("Leaked\n", .{});
    }
}

pub fn deinitIo() void {
    threaded.deinit();
}

pub fn init() !void {
    try assets.init();
    try input.init();
    try profiling.init();
    try audio.init();
}

pub fn deinit() void {
    assets.deinit();
    input.deinit();
    profiling.deinit();
    audio.deinit();
}
