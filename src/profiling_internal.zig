const std = @import("std");
const root = @import("root.zig");
const internal = @import("internal.zig");

var scopeTimers: ?std.StringHashMap(std.time.Timer) = null;
var scopeDepth: u64 = 0;

const ScopeTime = struct { 
    name: []const u8,
    time: u64,
    depth: u64,
};

var scopeTimes: std.ArrayList(ScopeTime) = .{};

pub fn init() !void {

    if (scopeTimers == null)
        scopeTimers = std.StringHashMap(std.time.Timer).init(internal.allocator);
}

pub fn deinit() void {
    scopeTimers.?.deinit();
    scopeTimes.deinit(internal.allocator);
}

pub fn reset() void {
    scopeTimers.?.clearRetainingCapacity();
    scopeTimes.clearRetainingCapacity();
    scopeDepth = 0;
}

pub fn startScope(name: []const u8) void {

    root.Assert.ok(scopeTimers.?.put(name, root.Assert.ok(std.time.Timer.start())));
    scopeDepth += 1;
}

pub fn endScope(name: []const u8) void {
    scopeDepth -= 1;

    if(scopeTimers.?.getPtr(name)) |timer| {
        root.Assert.ok(scopeTimes.append(internal.allocator, .{
            .name = name,
            .time = timer.lap(),
            .depth = scopeDepth,
        }));
    }
}

pub fn printTimings() void {

    std.debug.print("------- Timings --------\n", .{});

    var active_depths: u64 = 0x0;

    for (scopeTimes.items) |time| {

        for (0..time.depth) |index| {

            const current_depth_active = ((active_depths >> @intCast(index + 1)) & 0x1) == 1;

            if (index == time.depth - 1) {

                if (!current_depth_active)
                {
                    std.debug.print(" ┌─ ", .{}); 
                }
                else {
                    std.debug.print(" ├─ ", .{});
                }

            } else {
                
                if (current_depth_active) {
                    std.debug.print(" │  ", .{});
                }
                else {
                    std.debug.print("    ", .{});
                }
            } 
        }
        std.debug.print("{s}: {d}ms\n", .{time.name, @as(f32, @floatFromInt(time.time)) / std.time.ns_per_ms});
        active_depths = (active_depths & ~((~@as(u64, 0x0)) << @intCast(time.depth))) | (@as(u64, 0x1) << @intCast(time.depth));
    }
}