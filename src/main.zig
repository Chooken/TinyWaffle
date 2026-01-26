const std = @import("std");
const TW = @import("TinyWaffle");

pub fn main() !void {

    const scene = TW.SceneManagement.Scene {
        .on_enter = on_enter,
        .on_update = update,
        .on_exit = exit,
    };  

    TW.run("Tiny Waffle", 800, 600, scene);
}

pub fn on_enter() !void {

}

pub fn update() !void {
    TW.Renderer.drawLine(.{ .x = 0, .y = 0 }, .{ .x = 1, .y = 1, }, .Green);
}

pub fn exit() !void {
    std.debug.print("Hello from Exit\n", .{});
}
