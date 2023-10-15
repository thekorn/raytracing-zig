const std = @import("std");
const vec3 = @import("vec3.zig");

const Vec3 = vec3.Vec3;

pub fn write_color(out: anytype, pixel_color: Vec3) !void {
    try out.print("{d} {d} {d}\n", .{
        @as(usize, @intFromFloat(256 * pixel_color.x)) - 1,
        @as(usize, @intFromFloat(256 * pixel_color.y)) - 1,
        @as(usize, @intFromFloat(256 * pixel_color.z)) - 1,
    });
}
