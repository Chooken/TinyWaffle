const std = @import("std");
const root = @import("root.zig");
const internal = @import("internal.zig");

pub fn startScope(name: []const u8) void {
    internal.profiling.startScope(name);
}

pub fn endScope(name: []const u8) void {
    internal.profiling.endScope(name);
}

pub fn renderProfiler() void {

    const font_size = 24;

    const times = internal.profiling.getTimes();

    const total = times[times.len - 1];

    for (internal.profiling.getTimes(), 0..) |time, index| {

        root.renderer.drawScreenspaceRect(
            .{ 
                .w = 100, 
                .h = font_size,
                .x = 10,
                .y = @floatFromInt(index * (font_size + 6)), 
            }, 
            root.Color.White);

        const percentage = @as(f32, @floatFromInt(time.time)) / @as(f32, @floatFromInt(total.time));

        root.renderer.drawScreenspaceRect(
            .{ 
                .w = 100 * percentage, 
                .h = font_size,
                .x = 10,
                .y = @floatFromInt(index * (font_size + 6)), 
            }, 
            root.Color.fromRgb(@intFromFloat(255 * percentage), 255 - @as(u8, @intFromFloat(255 * percentage)), 0));

        const string = root.assert.ok(std.fmt.allocPrint(
            internal.allocator, 
            "{s}: {d}ms\n", 
            .{time.name, @as(f32, @floatFromInt(time.time)) / std.time.ns_per_ms}));

        root.renderer.drawScreenspaceText(
            .{ 
                .w = 1000, 
                .h = 1000,
                .x = 120 + @as(f32, @floatFromInt(font_size * time.depth)),
                .y = @floatFromInt(index * (font_size + 6)), },
            "Waffle_Debug_",
            string,
            .White,
            font_size,
        );
        internal.allocator.free(string);
    }
}