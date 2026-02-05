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