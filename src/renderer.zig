const std = @import("std");
const sdl3 = @import("sdl3");
const assert = @import("assert.zig");
const TW = @import("root.zig");
const internal_assets = @import("assets_internal.zig");
const internal = @import("internal.zig");

var Fov: f32 = 17;

pub fn setClearColor(color: TW.Color) void {
    internal.clear_color = color;
}

pub fn setFov(fov: f32) void {
    Fov = fov;
}

pub fn drawLine(start: TW.Vec2(f32), end: TW.Vec2(f32), color: TW.Color) void {

    assert.ok(internal.sdl_renderer.setDrawColor(.{ 
        .r = color.r, 
        .g = color.g, 
        .b = color.b, 
        .a = color.a }));

    const screenPosStart = worldToScreenspace(start);
    const screenPosEnd = worldToScreenspace(end);

    assert.ok(internal.sdl_renderer.renderLine(
        .{ .x = screenPosStart.x, .y = screenPosStart.y },
        .{ .x = screenPosEnd.x, .y = screenPosEnd.y }));
}

pub fn drawRect(rect: TW.Rect(f32), color: TW.Color) void {

    assert.ok(internal.sdl_renderer.setDrawColor(.{ 
        .r = color.r, 
        .g = color.g, 
        .b = color.b, 
        .a = color.a }));

    const unitSize = getUnitSize();
    const screenPos = worldToScreenspace(. {
        .x = rect.x,
        .y = rect.y,
    });

    assert.ok(internal.sdl_renderer.renderFillRect(.{
        .x = screenPos.x,
        .y = screenPos.y,
        .w = rect.w * unitSize,
        .h = rect.h * unitSize }));
}

pub fn drawTexture(texture: TW.Texture, pos: TW.Vec2(f32), color: TW.Color) void {
    
    const sprite_rect = sdl3.rect.Rect(f32) { 
        .x = @as(f32, @floatFromInt(texture.bounds.x)), 
        .y = @as(f32, @floatFromInt(texture.bounds.y)), 
        .w = @as(f32, @floatFromInt(texture.bounds.w)), 
        .h = @as(f32, @floatFromInt(texture.bounds.h))};

    const unitSize = getUnitSize();

    const screenPos = worldToScreenspace(pos);

    const dst_rect = sdl3.rect.Rect(f32) { 
        .x = screenPos.x, 
        .y = screenPos.y, 
        .w = unitSize, 
        .h = unitSize};

    const internal_texture = internal_assets.getInternalTexture(texture.name, internal.allocator) catch {
        // If fail to load texture draw a pink rect in its place.
        drawRect(
            TW.Rect(f32).from(dst_rect.x, dst_rect.y, dst_rect.w, dst_rect.h), 
            color);
        return;
    };
    
    //assert.ok(internal_texture.sdl_texture.setColorMod(color.r, color.g, color.b));

    assert.ok(internal.sdl_renderer.renderTexture(internal_texture.sdl_texture, sprite_rect, dst_rect));
}

pub fn drawText(bounds: TW.Rect(f32), fontName: []const u8, text: []const u8, color: TW.Color) void {

    const unitSize = getUnitSize();

    const font: *internal_assets.InternalFont = assert.ok(internal_assets.getInternalFont(fontName, internal.allocator));
    assert.ok(font.sdl_font.setSize(0.6 * unitSize));
    
    // Need to Cache.
    const sdl_text: sdl3.ttf.Text = assert.ok(sdl3.ttf.Text.init(.{ .value = internal.sdl_text_engine.value }, font.sdl_font, text));
    assert.ok(sdl_text.setWrapWidth(@intFromFloat(bounds.w * unitSize)));
    assert.ok(sdl_text.setColor(color.r, color.g, color.b, color.a));
    defer sdl_text.deinit();

    const position = worldToScreenspace(.{ .x = bounds.x, .y = bounds.y });

    assert.ok(sdl3.ttf.drawRendererText(sdl_text, position.x, position.y));
}

pub fn getUnitSize() f32 {
    _, const renderheight = internal.sdl_renderer.getOutputSize() catch {
        return 1;
    };

    return @as(f32, @floatFromInt(renderheight)) / Fov;
}

pub fn worldToScreenspace(from: TW.Vec2(f32)) TW.Vec2 (f32)
{
    const renderwidth, const renderheight = internal.sdl_renderer.getOutputSize() catch {
        return .{ .x = 0, .y = 0 };
    };

    const unitSize = @as(f32, @floatFromInt(renderheight)) / Fov;

    return .{
        .x = @as(f32, @floatFromInt(renderwidth)) / 2 - unitSize / 2 + from.x * unitSize,
        .y = @as(f32, @floatFromInt(renderheight)) / 2 - unitSize / 2 + from.y * unitSize,
    };
}

pub fn getScreenRect() TW.Rect(f32) {
    const renderwidth, const renderheight = internal.sdl_renderer.getOutputSize() catch {
        return .{ .x = 0, .y = 0, .w = 0, .h = 0 };
    };

    const unitSize = @as(f32, @floatFromInt(renderheight)) / Fov;

    return .{
        .x = 0,
        .y = 0,
        .w = @as(f32, @floatFromInt(renderwidth)) / unitSize,
        .h = @as(f32, @floatFromInt(renderheight)) / unitSize,
    };
}