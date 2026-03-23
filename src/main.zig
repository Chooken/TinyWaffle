const std = @import("std");
const tw = @import("TinyWaffle");

pub fn main() !void {

    const scene = tw.scene_management.Scene {
        .on_enter = on_enter,
        .on_update = update,
        .on_exit = exit,
    };  

    const start_options = tw.StartOptions {
        .title = "Tiny Waffle",
        .resizeable = true,
    };

    tw.run(start_options, scene);
}

var keyboard_input = tw.input.KeyboardInput { };

pub fn on_enter() !void {

    try keyboard_input.captureInput();
}

pub fn update() !void {
    tw.profiling.startScope("test");
    const size = tw.window.GetSize();
    tw.renderer.drawScreenspaceRect(.from(0,0,@floatFromInt(size.x),@floatFromInt(size.y)), .Red);
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
