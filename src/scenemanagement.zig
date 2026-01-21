const root = @import("root.zig");
const internal = @import("internal.zig");

pub const Scene = struct {
    on_enter: *const fn () anyerror!void,
    on_update: *const fn () anyerror!void,
    on_exit: *const fn () anyerror!void,
};

pub fn switchScene(scene: Scene) void {
    internal.scene_management.setNext(scene);
}