const std = @import("std");

const vec3 = @import("vec3.zig");
const ray = @import("ray.zig");
const image = @import("image.zig");

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;

pub fn main() !void {
    // Image

    const aspect_ratio = 16.0 / 9.0;
    const image_width = 384;

    // Calculate the image height, and ensure that it's at least 1.

    var image_height = @as(usize, @intFromFloat(@as(f32, image_width) / aspect_ratio));
    if (image_height < 1) image_height = 1;

    var img = try image.makePPMImageFile("out.ppm", image_width, image_height);
    //var img = try image.makePPMImageStdOut(image_height, image_width);
    defer img.deinit();

    // Camera

    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * (image_width / @as(f32, @floatFromInt(image_height)));
    const camera_center = Vec3.init(0, 0, 0);

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u.scalar(1 / @as(f32, @floatFromInt(image_width)));
    const pixel_delta_v = viewport_v.scalar(1 / @as(f32, @floatFromInt(image_height)));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center.sub(viewport_u.scalar(1.0 / 2.0)).add(viewport_v.scalar(1.0 / 2.0)).sub(Vec3.init(0, 0, focal_length));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.scalar(1.0 / 2.0)).sub(pixel_delta_v.scalar(1.0 / 2.0));

    for (0..image_height) |a| {
        const y = image_height - a - 1;
        for (0..image_width) |x| {
            const pixel_center = pixel00_loc
                .add(pixel_delta_u.scalar(@as(f32, @floatFromInt(x))))
                .sub(pixel_delta_v.scalar(@as(f32, @floatFromInt(y))));
            const ray_direction = pixel_center.sub(camera_center);

            const r = Ray.init(camera_center, ray_direction);
            const pixel_color = r.color();

            img.write_color(pixel_color);
        }
    }
}
