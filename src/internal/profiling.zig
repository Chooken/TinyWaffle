const std = @import("std");
const root = @import("../root.zig");
const internal = @import("../internal.zig");

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

    root.assert.ok(scopeTimers.?.put(name, root.assert.ok(std.time.Timer.start())));
    scopeDepth += 1;
}

pub fn endScope(name: []const u8) void {
    scopeDepth -= 1;

    if(scopeTimers.?.getPtr(name)) |timer| {
        root.assert.ok(scopeTimes.append(internal.allocator, .{
            .name = name,
            .time = timer.lap(),
            .depth = scopeDepth,
        }));
    }
}

pub fn getTimes() []const ScopeTime {
    return scopeTimes.items;
}