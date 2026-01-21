const std = @import("std");
const internal = @import("internal.zig");

pub const Assert = @import("assert.zig");
pub const Application = @import("application.zig");
pub const Audio = @import("audio.zig");
pub const Window = @import("window.zig");
pub const Renderer = @import("renderer.zig");
pub const Assets = @import("assets.zig");
pub const Input = @import("input.zig");
pub const Time = @import("time.zig");

pub const Color = struct { 
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub fn from(r: u8, g: u8, b: u8, a: u8) Color {
        return Color {
            .r = r,
            .g = g,
            .b = b,
            .a = a,
        };
    }

    pub fn fromRgb(r: u8, g: u8, b: u8) Color {
        return Color {
            .r = r,
            .g = g,
            .b = b,
            .a = 255,
        };
    }
};

pub fn Vec2(comptime T: type) type {
    return struct {
        x: T,
        y: T,

        pub fn from(x: T, y: T) Vec2(T)
        {
            return Vec2(T) {
                .x = x,
                .y = y,
            };
        }
    };
}

pub fn Rect(comptime T: type) type {
    return struct {
        x: T,
        y: T,
        w: T,
        h: T,

        pub fn from(x: T, y: T, w: T, h: T) Rect(T) {
            return Rect(T) {
                .x = x,
                .y = y,
                .w = w,
                .h = h,
            };
        }

        pub fn to(self: Rect(T), comptime T0: type) Rect(T0) {
            return Rect(T0) {
                .x = std.math.cast(T0, self.x),
                .y = std.math.cast(T0, self.y),
                .w = std.math.cast(T0, self.w),
                .h = std.math.cast(T0, self.h),
            };
        }
    };
}

pub const Texture = struct {
    name: []const u8,
    bounds: Rect(usize),

    pub fn getColorAt(self: *const Texture, pos: Vec2(usize)) ?Color
    {
        var texture: *internal.assets.InternalTexture = Assert.ok(internal.assets.getInternalTexture(self.name, internal.allocator));
        
        const width, const height = texture.sdl_texture.getSize() catch return null;

        if (pos.x > @as(usize, @intFromFloat(width)) or pos.y > @as(usize, @intFromFloat(height))) return null;

        const surface = texture.sdl_texture.lockToSurface(.{
            .x = @intCast(self.bounds.x + pos.x),
            .y = @intCast(self.bounds.y + pos.y),
            .w = 1,
            .h = 1,
        }) catch return null;
        defer { 
            texture.sdl_texture.unlock();
        }

        const pixel = surface.readPixel(0, 0) catch return null;

        return Color.from(pixel.r, pixel.g, pixel.b, pixel.a);
    }

    pub fn setColorAt(self: *const Texture, pos: Vec2(usize), color: Color) void
    {
        var texture: *internal.assets.InternalTexture = Assert.ok(internal.assets.getInternalTexture(self.name, internal.allocator));
        
        const width, const height = texture.sdl_texture.getSize() catch return;

        if (self.bounds.x + pos.x > @as(usize, @intFromFloat(width)) or self.bounds.y + pos.y > @as(usize, @intFromFloat(height))) return;

        const surface = Assert.ok(texture.sdl_texture.lockToSurface(.{
            .x = @intCast(self.bounds.x + pos.x),
            .y = @intCast(self.bounds.y + pos.y),
            .w = 1,
            .h = 1,
        }));
        defer { 
            texture.sdl_texture.unlock();
        }

        surface.writePixel(0, 0, .{
            .r = color.r,
            .g = color.g,
            .b = color.b,
            .a = color.a,
        }) catch return;
    }
};

pub const TextureAtlas = struct {
    name: []const u8,
    size: Vec2(usize),
    dimensions: Vec2(usize),

    pub fn get(self: *const TextureAtlas, index: usize) Texture {

        const width = self.size.x / self.dimensions.x;
        const height = self.size.y / self.dimensions.y;

        const x = index % self.dimensions.x;
        const y = @divFloor(index, self.dimensions.x);

        return Texture {
            .name = self.name,
            .bounds = Rect(usize).from(
                x * width,
                y * height,
                width,
                height,
            ),
        };
    }
};

pub fn run(title: [:0]const u8, width: usize, height: usize, update_callback: *const fn() anyerror!void) void {
    internal.run(title, width, height, update_callback);
}
