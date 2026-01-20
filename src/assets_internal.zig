const std = @import("std");
const sdl3 = @import("sdl3");
const assert = @import("assert.zig");
const internal = @import("internal.zig");

pub const InternalTexture = struct {
    sdl_texture: sdl3.render.Texture,
};

pub const InternalFont = struct {
    sdl_font: sdl3.ttf.Font,
};

pub var textures: std.StringHashMap(InternalTexture) = undefined;
pub var fonts: std.StringHashMap(InternalFont) = undefined;

pub fn init(allocator: std.mem.Allocator) !void {
    textures = std.StringHashMap(InternalTexture).init(allocator);
    fonts = std.StringHashMap(InternalFont).init(allocator);
}

pub fn deinit() void {
    textures.deinit();
    fonts.deinit();
}

pub fn getInternalTexture(name: []const u8, allocator: std.mem.Allocator) !*InternalTexture {

    if (!textures.contains(name))
    {   
        const path: [:0]u8 = std.fmt.allocPrintSentinel(allocator, "{s}/assets/{s}", .{ internal.application_path, name}, 0) catch unreachable;
        defer allocator.free(path);

        const surface = try sdl3.image.loadFile(path);

        const texture = try sdl3.render.Texture.init(internal.sdl_renderer, surface.getFormat().?, .streaming, surface.getWidth(), surface.getHeight());

        try texture.update(null, @ptrCast(surface.getPixels().?), surface.getPitch());

        const internal_texture = InternalTexture {
            .sdl_texture = texture,
        };

        assert.ok(internal_texture.sdl_texture.setScaleMode(.nearest));
        assert.ok(textures.put(name, internal_texture));
    }

    return textures.getPtr(name).?;
}

pub fn addInternalTextureFromData(name: []const u8, data: []const u8) !void {

    const reader = try sdl3.io_stream.Stream.initFromConstMem(data);

    const surface = try sdl3.image.loadPngIo(reader);

    const texture = try sdl3.render.Texture.init(internal.sdl_renderer, surface.getFormat().?, .streaming, surface.getWidth(), surface.getHeight());

    try texture.update(null, @ptrCast(surface.getPixels().?), surface.getPitch());

    const internal_texture = InternalTexture {
        .sdl_texture = texture,
    };

    assert.ok(internal_texture.sdl_texture.setScaleMode(.nearest));
    assert.ok(textures.put(name, internal_texture));
}

pub fn getInternalFont(name: []const u8, allocator: std.mem.Allocator) !*InternalFont {
     if (!fonts.contains(name))
    {   
        const path: [:0]u8 = std.fmt.allocPrintSentinel(allocator, "{s}/assets/{s}", .{ internal.application_path, name}, 0) catch unreachable;
        defer allocator.free(path);

        const internal_font = InternalFont {
            .sdl_font = try sdl3.ttf.Font.init(path, 16),
        };

        assert.ok(fonts.put(name, internal_font));
    }

    return fonts.getPtr(name).?;
}

pub fn removeInternalTexture(name: []const u8) void
{
    if (textures.get(name)) |texture| {
        texture.sdl_texture.deinit();
        textures.remove(name);
    }
}