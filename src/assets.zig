const std = @import("std");
const root = @import("root.zig");
const assert = @import("assert.zig");
const internal = @import("internal.zig");

pub fn getTexture(name: []const u8) !root.Texture {

    const texture = try internal.assets.getInternalTexture(name, internal.allocator);
    const width, const height = assert.ok(texture.sdl_texture.getSize());

    return root.Texture {
        .name = name,
        .bounds = root.Rect(usize).from(0, 0, @as(usize, @intFromFloat(width)), @as(usize, @intFromFloat(height))),
    };
}

pub fn getTextureAtlas(name: []const u8, dimensions: root.Vec2(usize)) !root.TextureAtlas {

    const texture = try internal.assets.getInternalTexture(name, internal.allocator);
    const width, const height = assert.ok(texture.sdl_texture.getSize());

    return root.TextureAtlas {
        .name = name,
        .size = root.Vec2(usize).from(@as(usize, @intFromFloat(width)), @as(usize, @intFromFloat(height))),
        .dimensions = dimensions,
    };
}