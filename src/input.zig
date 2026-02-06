const std = @import("std");
const internal = @import("internal.zig");
const sdl3 = @import("sdl3");

pub const Keycode = internal.input.Keycode;

pub fn isKeyDown(key: Keycode) bool {
    if(internal.input.getKeyState(key)) |state|
    {
        return state.down;
    } 

    return false;
}

pub fn isKeyUp(key: Keycode) bool {
    return !isKeyDown(key);
}

pub fn isKeyPressed(key: Keycode) bool {
    if(internal.input.getKeyState(key)) |state|
    {
        return state.down_first_frame;
    } 

    return false;
}

var input_captured: bool = false;

pub const KeyboardInput = struct {

    captured: bool = false,

    pub fn captureInput(self: *KeyboardInput) !void {

        if (@cmpxchgWeak(bool, &input_captured, false, true, .monotonic, .monotonic)) |_|
        {
            return error.InputAlreadyCaptured;
        }
        
        self.captured = true;
        internal.input.startKeyboardCapture();
        return;
    }

    pub fn get(self: *KeyboardInput) ?[]const u8 {

        if (self.captured and @atomicLoad(bool, &input_captured, .monotonic))
        {
            return internal.input.getKeyboardInput();
        }

        return null;
    }

    pub fn releaseInput(self: *KeyboardInput) !void {
        
        if (!self.captured) {
            return;
        }

        if (@cmpxchgWeak(bool, &input_captured, true, false, .monotonic, .monotonic)) |_|
        {
            return error.InputAlreadyCaptured;
        }

        self.captured = false;
        internal.input.stopKeyboardCapture();
        return;
    }
};