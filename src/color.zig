const std = @import("std");
const vec3 = @import("vec3");

const Vec3 = vec3.Vec3;

pub fn write_color(out: type, pixel_color: Vec3) !void {
    out.print("{d} {d} {d}\n", .{
        @as(usize, @intFromFloat(256 * pixel_color.x)),
        @as(usize, @intFromFloat(256 * pixel_color.y)),
        @as(usize, @intFromFloat(256 * pixel_color.z)),
    });
}
