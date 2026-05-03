const std = @import("std");
const root = @import("root.zig");
const internal = @import("internal.zig");

pub fn startScope(name: []const u8) void {
    internal.profiling.startScope(name);
}

pub fn endScope(name: []const u8) void {
    internal.profiling.endScope(name);
}

const average_size = 100;
var values: [average_size]f32 = undefined;
var current: usize = 0;

var show_profiler: bool = false;

pub fn toggleProfiler() void {
    show_profiler = !show_profiler;
}

pub fn renderProfiler() void {
    if (!show_profiler) {
        return;
    }

    const font_size = 24;

    const times = internal.profiling.getTimes();

    const total: f32 = @as(f32, @floatFromInt(times[times.len - 1].time))  / std.time.us_per_ms;

    values[current] = total;
    current = @mod(current + 1, average_size);

    for (times, 0..) |time, index| {
        root.renderer.drawScreenspaceRect(.{
            .w = 100,
            .h = font_size,
            .x = 10,
            .y = @floatFromInt(index * (font_size + 6)),
        }, root.Color.White);

        const percentage = @as(f32, @floatFromInt(time.time)) / total;

        root.renderer.drawScreenspaceRect(.{
            .w = 100 * percentage,
            .h = font_size,
            .x = 10,
            .y = @floatFromInt(index * (font_size + 6)),
        }, root.Color.fromRgb(@intFromFloat(255 * percentage), 255 - @as(u8, @intFromFloat(255 * percentage)), 0));

        const string = root.assert.ok(std.fmt.allocPrint(internal.allocator, "{s}: {d}ms\n", .{ time.name, @as(f32, @floatFromInt(time.time)) / std.time.us_per_ms }));

        root.renderer.drawScreenspaceText(
            .{
                .w = 1000,
                .h = 1000,
                .x = 120 + @as(f32, @floatFromInt(font_size * time.depth)),
                .y = @floatFromInt(index * (font_size + 6)),
            },
            "Waffle_Debug_",
            string,
            .White,
            font_size,
        );
        internal.allocator.free(string);
    }

    var average: f32 = 0;
    var one_perc_low: f32 = 0;

    for (values) |value| {
        average += value;
        one_perc_low = @max(one_perc_low, value);
    }

    average /= average_size;

    const string = root.assert.ok(std.fmt.allocPrint(internal.allocator, "Average: {d}ms\n", .{average}));

    root.renderer.drawScreenspaceText(
        .{ .w = 1000, .h = 1000, .x = 120, .y = @floatFromInt(times.len * (font_size + 6)) },
        "Waffle_Debug_",
        string,
        .White,
        font_size,
    );
    internal.allocator.free(string);

    const string2 = root.assert.ok(std.fmt.allocPrint(internal.allocator, "1% Low: {d}ms\n", .{one_perc_low}));

    root.renderer.drawScreenspaceText(
        .{ .w = 1000, .h = 1000, .x = 120, .y = @floatFromInt((times.len + 1) * (font_size + 6)) },
        "Waffle_Debug_",
        string2,
        .White,
        font_size,
    );
    internal.allocator.free(string2);
}
