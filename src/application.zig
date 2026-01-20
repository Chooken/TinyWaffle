const std = @import("std");
const internal = @import("internal.zig");

pub fn getApplicationPath() []u8 {
    return internal.application_path;
}