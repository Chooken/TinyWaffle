const sdl3 = @import("sdl3");

pub inline fn ok(x: anytype) @TypeOf(x catch unreachable) {
    return x catch |err| @panic(if (err == sdl3.errors.Error.SdlError) sdl3.errors.get().? else @errorName(err));
}

pub inline fn @"true"(value: bool, message: []const u8) void {
    if (!value) @panic(message);
}

pub inline fn @"false"(value: bool, message: []const u8) void {
    if (value) @panic(message);
}