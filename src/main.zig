const std = @import("std");
const TW = @import("TinyWaffle");

pub fn main() !void {
    TW.run("Tiny Waffle", 800, 600, update);
}

pub fn update() anyerror!void {
    TW.Application.quit();
}
