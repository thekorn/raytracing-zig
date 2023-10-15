const std = @import("std");

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
            const r = @as(f32, @floatFromInt(i)) / (image_width - 1);
            const g = @as(f32, @floatFromInt(j)) / (image_height - 1);
            const b = 0;
            try stdout.print("{d} {d} {d}\n", .{
                @as(usize, @intFromFloat(256 * r)),
                @as(usize, @intFromFloat(256 * g)),
                @as(usize, @intFromFloat(256 * b)),
            });
        }
    }
    std.debug.print("\rDone.                  \n", .{});

    try bw.flush();
}
