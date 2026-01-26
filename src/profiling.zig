const internal = @import("internal.zig");

pub fn startScope(name: []const u8) void {
    internal.profiling.startScope(name);
}

pub fn endScope(name: []const u8) void {
    internal.profiling.endScope(name);
}