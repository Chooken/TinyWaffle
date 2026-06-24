const std = @import("std");
const internal = @import("internal.zig");

pub const assert = @import("assert.zig");
pub const application = @import("application.zig");
pub const audio = @import("audio.zig");
pub const window = @import("window.zig");
pub const renderer = @import("renderer.zig");
pub const assets = @import("assets.zig");
pub const input = @import("input.zig");
pub const time = @import("time.zig");
pub const scene_management = @import("scenemanagement.zig");
pub const profiling = @import("profiling.zig");

pub const StartOptions = internal.application.StartOptions;

pub const Color = struct { 
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    pub const Red = Color.from(255, 0, 0, 255);
    pub const Yellow = Color.from(255, 255, 0, 255);
    pub const Green = Color.from(0, 255, 0, 255);
    pub const Cyan = Color.from(0, 255, 255, 255);
    pub const Blue = Color.from(0, 0, 255, 255);
    pub const Pink = Color.from(255, 0, 255, 255);
    pub const Black = Color.from(0, 0, 0, 255);
    pub const Gray = Color.from(125, 125, 125, 255);
    pub const White = Color.from(255, 255, 255, 255);

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

pub const OklabColor = struct {
    l: f32,
    a: f32,
    b: f32,

    pub fn toRgb(self: OklabColor) Color {
        const _l = self.l + 0.3963377774 * self.a + 0.2158037573 * self.b;
        const _m = self.l - 0.1055613458 * self.a - 0.0638541728 * self.b;
        const _s = self.l - 0.0894841775 * self.a - 1.2914855480 * self.b;

        const l = _l * _l * _l;
        const m = _m * _m * _m;
        const s = _s * _s * _s;

        const f_r =  4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s;
        const f_g = -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s;
        const f_b = -0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s;

        return .{
            .r = linearToU8(f_r),
            .g = linearToU8(f_g),
            .b = linearToU8(f_b),
            .a = 255,
        };
    }

    fn linearToU8(linear: f32) u8 {
        if (linear <= 0) {
            return 0;
        } else if (linear >= 1) {
            return 0xff;
        } else {
            const v: f32 = 
                if (linear < 0.0031308) linear * 12.92 
                else 1.055 * std.math.pow(f32, linear, 1.2/2.4) - 0.055;
            return @intFromFloat(v * 255);
        }
    }
};

pub const OklchColor = struct {
    l: f32,
    c: f32,
    h: f32,

    pub fn from01(l: f32, c: f32, h: f32) OklchColor {
        return .{
            .l = l,
            .c = 0.4 * c,
            .h = 360 * h,
        };
    }

    pub fn rotateHue(self: *OklchColor, delta: f32) void {
        self.h = @mod(self.h + delta, 360);
    }

    pub fn toOklab(self: OklchColor) OklabColor {
        const half_radius = self.h * std.math.pi / 180;
        return .{ 
            .l = self.l,
            .a = self.c * std.math.cos(half_radius),
            .b = self.c * std.math.sin(half_radius),
        };
    }

    pub fn toRgb(self: OklchColor) Color {
        return self.toOklab().toRgb();
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

        pub fn max(self: *const Rect(T)) Vec2(T) {
            return .{ 
                .x = @max(self.x, self.x + self.w), 
                .y = @max(self.y, self.y + self.h)
            };
        }

        pub fn min(self: *const Rect(T)) Vec2(T) {
            return .{ 
                .x = @min(self.x, self.x + self.w), 
                .y = @min(self.y, self.y + self.h)
            };
        }

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

        pub fn contains(self: *const Rect(T), other: Vec2(T)) bool {
            const self_min = self.min();
            const self_max = self.max();

            if (other.x < self_min.x or other.y < self_min.y or 
                other.x >= self_max.x or other.y >= self_max.y)
            {
                return false;
            }

            return true;
        }

        pub fn overlaps(self: *const Rect(T), other: Rect(T)) bool {
            const self_min = self.min();
            const self_max = self.max();
            const other_min = other.min();
            const other_max = other.max();

            if (other_max.x <= self_min.x or other_min.x >= self_max.x or 
                other_max.y <= self_min.y or other_min.y >= self_max.y)
                return false;

            return true;
        }

        pub fn getOverlap(self: *const Rect(T), other: Rect(T)) ?Rect(T) {
            const self_min = self.min();
            const self_max = self.max();
            const other_min = other.min();
            const other_max = other.max();

            if (other_max.x <= self_min.x or other_min.x >= self_max.x or 
                other_max.y <= self_min.y or other_min.y >= self_max.y)
                return null;

            const overlap_max = Vec2(T) {
                .x = @min(self_max.x, other_max.x),
                .y = @min(self_max.y, other_max.y),
            };

            const overlap_min = Vec2(T) {
                .x = @max(self_min.x, other_min.x),
                .y = @max(self_min.y, other_min.y),
            };

            return .{
                .x = overlap_min.x,
                .y = overlap_min.y,
                .w = overlap_max.x - overlap_min.x,
                .h = overlap_max.y - overlap_min.y,
            };
        }
    };
}

pub const Texture = struct {
    name: []const u8,
    bounds: Rect(usize),

    pub fn getColorAt(self: *const Texture, pos: Vec2(usize)) ?Color
    {
        var texture: *internal.assets.InternalTexture = assert.ok(internal.assets.getInternalTexture(self.name, internal.allocator));
        
        const width, const height = texture.sdl_texture.getSize() catch return null;

        if (self.bounds.x + pos.x > @as(usize, @intFromFloat(width)) or self.bounds.y + pos.y > @as(usize, @intFromFloat(height))) return null;

        const pixel = texture.sdl_surface.readPixel(self.bounds.x + pos.x, self.bounds.y + pos.y) catch return null;

        return Color.from(pixel.r, pixel.g, pixel.b, pixel.a);
    }

    pub fn setColorAt(self: *const Texture, pos: Vec2(usize), color: Color) void
    {
        var texture: *internal.assets.InternalTexture = assert.ok(internal.assets.getInternalTexture(self.name, internal.allocator));
        
        const width, const height = texture.sdl_texture.getSize() catch return;

        if (self.bounds.x + pos.x > @as(usize, @intFromFloat(width)) or self.bounds.y + pos.y > @as(usize, @intFromFloat(height))) return;

        texture.sdl_surface.writePixel(0, 0, .{
            .r = color.r,
            .g = color.g,
            .b = color.b,
            .a = color.a,
        }) catch return;

        const colorArray = [_]u8 { color.r, color.g, color.b, color.a };

        texture.sdl_texture.update(
            .{
                .x = @intCast(self.bounds.x + pos.x),
                .y = @intCast(self.bounds.y + pos.y),
                .w = 1,
                .h = 1,
            }, 
            @ptrCast(colorArray),
            texture.sdl_surface.getPitch());
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

pub fn run(start_options: StartOptions, start_scene: scene_management.Scene) void {
    internal.application.run(start_options, start_scene);
}
