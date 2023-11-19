const std = @import("std");
const math = std.math;

const vec3 = @import("vec3.zig");
const ray = @import("entities/ray.zig");
const Camera = @import("entities/camera.zig").Camera;
const hittable = @import("entities/hittable.zig");
const image = @import("image.zig");
const Material = @import("entities/material.zig").Material;

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;
const Hittable = hittable.Hittable;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    var arena = std.heap.ArenaAllocator.init(gpa.allocator());
    defer arena.deinit();
    var allocator = arena.allocator();

    // Image
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;

    // Calculate the image height, and ensure that it's at least 1.
    var image_height = @as(usize, @intFromFloat(@as(f32, image_width) / aspect_ratio));
    if (image_height < 1) image_height = 1;

    var img = try image.makePPMImageFile("out.ppm", image_width, image_height);
    //var img = try image.makePPMImageStdOut(image_height, image_width);
    defer img.deinit();

    // World
    var world = Hittable.hittable_list(allocator);
    defer world.deinit();

    const R = math.cos(math.pi / 4.0);
    var material_left = Material.lambertian(Vec3.init(0, 0, 1));
    var material_right = Material.lambertian(Vec3.init(1, 0, 0));

    try world.add(Hittable.sphere(Vec3.init(-R, 0, -1), R, &material_left));
    try world.add(Hittable.sphere(Vec3.init(R, 0, -1), R, &material_right));

    // Camera
    var cam = Camera.init(image_width, image_height, 100, 50, 90);
    cam.render(&img, &world);
}
