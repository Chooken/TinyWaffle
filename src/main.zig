const std = @import("std");
const tw = @import("TinyWaffle");

pub fn main() !void {

    const scene = tw.scene_management.Scene {
        .on_enter = on_enter,
        .on_update = update,
        .on_exit = exit,
    };  

    tw.run("Tiny Waffle", 800, 600, scene);
}

var keyboard_input = tw.input.KeyboardInput { };

pub fn on_enter() !void {

    try keyboard_input.captureInput();
}

pub fn update() !void {
    tw.profiling.startScope("test");
    tw.renderer.drawLine(.{ .x = 0, .y = 0 }, .{ .x = 1, .y = 1, }, .Green);
    if (keyboard_input.get()) |input| {
        tw.renderer.drawText(
            .{ .w = 100, .h = 100, .x = 0, .y = 0}, 
            "Waffle_Debug_", 
            input, 
            .Red);
    }
    tw.profiling.endScope("test");
}

pub fn exit() !void {

    try keyboard_input.releaseInput();

    std.debug.print("Hello from Exit\n", .{});
}
