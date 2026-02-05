const root = @import("../root.zig");

pub var active_scene: ?root.scene_management.Scene = null;
pub var next_scene: ?root.scene_management.Scene = null;

pub fn setNext(scene: root.scene_management.Scene) void {
    next_scene = scene;
}

pub fn update() !void {

    if (active_scene) |scene| {
        try scene.on_update();
    }

    if (next_scene) |scene| {
        if (active_scene) |a_scene| {
            try a_scene.on_exit();
        }

        try scene.on_enter();

        active_scene = scene;
        next_scene = null;
    }
}

pub fn exit() void {
    if (active_scene) |scene| {
        root.assert.ok(scene.on_exit());
    }
}