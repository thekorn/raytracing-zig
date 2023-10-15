const std = @import("std");

const vec3 = @import("vec3.zig");
const color = @import("color.zig");
const ray = @import("ray.zig");

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;

pub fn main() !void {
    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    // Image

    const aspect_ratio = 16.0 / 9.0;
    const image_width = 384;

    // Calculate the image height, and ensure that it's at least 1.

    var image_height = @as(usize, @intFromFloat(@as(f32, image_width) / aspect_ratio));
    if (image_height < 1) image_height = 1;

    //// Camera
    //
    //const focal_length = 1.0;
    //const viewport_height = 2.0;
    //const viewport_width = viewport_height * (image_width / @as(f32, @floatFromInt(image_height)));
    //const camera_center = Vec3.init(0, 0, 0);
    //
    //// Calculate the vectors across the horizontal and down the vertical viewport edges.
    //const viewport_u = Vec3.init(viewport_width, 0, 0);
    //const viewport_v = Vec3.init(0, -viewport_height, 0);
    //
    //// Calculate the horizontal and vertical delta vectors from pixel to pixel.
    //const pixel_delta_u = viewport_u.scalar(1 / @as(f32, @floatFromInt(image_width)));
    //const pixel_delta_v = viewport_v.scalar(1 / @as(f32, @floatFromInt(image_height)));
    //
    //// Calculate the location of the upper left pixel.
    //const viewport_upper_left = camera_center.sub(viewport_u.scalar(1.0 / 2.0)).add(viewport_v.scalar(1.0 / 2.0)).sub(Vec3.init(0, 0, focal_length));
    //const pixel00_loc = viewport_upper_left.add(pixel_delta_u.scalar(1.0 / 2.0)).sub(pixel_delta_v.scalar(1.0 / 2.0));

    const origin = Vec3.init(0, 0, 0);
    const horizontal = Vec3.init(4, 0, 0);
    const vertical = Vec3.init(0, 2.25, 0);

    const lower_left_corner = origin.sub(horizontal.div(2)).sub(vertical.div(2)).sub(Vec3.init(0, 0, 1));

    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });

    for (0..image_height) |a| {
        const y = image_height - a - 1;
        //std.debug.print("\rScanlines remaining: {d} ", .{image_height - y});
        for (0..image_width) |x| {
            //const pixel_center = pixel00_loc
            //    .add(pixel_delta_u.scalar(@as(f32, @floatFromInt(i))))
            //    .sub(pixel_delta_v.scalar(@as(f32, @floatFromInt(j))));
            //const ray_direction = pixel_center.sub(camera_center);
            //
            //const r = Ray.init(camera_center, ray_direction);
            //const pixel_color = r.color();
            const u = @as(f32, @floatFromInt(x)) / @as(f32, @floatFromInt(image_width));
            const v = @as(f32, @floatFromInt(y)) / @as(f32, @floatFromInt(image_height));

            const direction = lower_left_corner.add(horizontal.scalar(u)).add(vertical.scalar(v));
            //vec3.debug_vec3(direction);
            const r = Ray.init(origin, direction);
            const pixel_color = r.color();

            try color.write_color(stdout, pixel_color);
        }
    }
    //std.debug.print("\rDone.                  \n", .{});

    try bw.flush();
}
