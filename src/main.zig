const std = @import("std");

const vec3 = @import("vec3.zig");
const color = @import("color.zig");

const Vec3 = vec3.Vec3;

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const image_height = 256;
    const image_width = 256;

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_height, image_width });

    for (0..image_height) |j| {
        std.debug.print("\rScanlines remaining: {d} ", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_color = Vec3.init(
                @as(f32, @floatFromInt(i)) / (image_width - 1),
                @as(f32, @floatFromInt(j)) / (image_height - 1),
                0,
            );

            try color.write_color(stdout, pixel_color);
        }
    }
    std.debug.print("\rDone.                  \n", .{});

    try bw.flush();
}
