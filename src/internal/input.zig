const std = @import("std");
const sdl3 = @import("sdl3");
const internal = @import("../internal.zig");

pub const KeyState = struct {
    down_first_frame: bool,
    down: bool,
};

var key_states: std.AutoHashMap(sdl3.keycode.Keycode, KeyState) = undefined;

pub fn init() !void {
    key_states = std.AutoHashMap(sdl3.keycode.Keycode, KeyState).init(internal.allocator);
}

pub fn deinit() void {
    key_states.deinit();
}

pub fn resetKeyStates() void {
    var iter = key_states.valueIterator();

    while (iter.next()) |value| {
        value.down_first_frame = false;
    }
}

pub fn OnKeyDownEvent(event: sdl3.events.Keyboard) void {
    if (event.key) |key| {

        var state = key_states.getOrPut(key) catch unreachable;
        state.value_ptr.down = true;

        if (!event.repeat) {
            state.value_ptr.down_first_frame = true;
        }
    }
}

pub fn onKeyUpEvent(event: sdl3.events.Keyboard) void {
    if (event.key) |key| {
        var state = key_states.getOrPut(key) catch unreachable;
        state.value_ptr.down = false;
    }
}