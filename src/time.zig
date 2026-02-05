const internal = @import("internal.zig");

pub fn getDeltaTime() f32 {
    return internal.application.last_frame_time;
}