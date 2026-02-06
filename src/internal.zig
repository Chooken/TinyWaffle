const std = @import("std");
pub const application = @import("internal/application.zig");
pub const assets = @import("internal/assets.zig");
pub const profiling = @import("internal/profiling.zig");
pub const audio = @import("internal/audio.zig");
pub const scene_management = @import("internal/scenemanagement.zig");
pub const input = @import("internal/input.zig");
pub const assert = @import("assert.zig");

var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
pub var allocator: std.mem.Allocator = undefined; 

pub fn init() !void {

    allocator = gpa.allocator();

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

    const check = gpa.deinit();
    if (check == .leak)
    {
        std.debug.print("Leaked\n", .{});
    }
}