const std = @import("std");

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

    var material_ground = Material.lambertian(Vec3.init(0.8, 0.8, 0.0));
    var material_center = Material.lambertian(Vec3.init(0.1, 0.2, 0.5));
    var material_left = Material.dielectric(1.5);
    var material_right = Material.metal(Vec3.init(0.8, 0.6, 0.2), 0);

    try world.add(Hittable.sphere(Vec3.init(0, -100.5, -1), 100, &material_ground));
    try world.add(Hittable.sphere(Vec3.init(0, 0, -1), 0.5, &material_center));
    try world.add(Hittable.sphere(Vec3.init(-1, 0, -1), 0.5, &material_left));
    try world.add(Hittable.sphere(Vec3.init(1, 0, -1), 0.5, &material_right));

    // Camera
    var cam = Camera.init(image_width, image_height, 100, 50);
    cam.render(&img, &world);
}
