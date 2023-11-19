const std = @import("std");

const vec3 = @import("vec3.zig");
const ray = @import("entities/ray.zig");
const Camera = @import("entities/camera.zig").Camera;
const hittable = @import("entities/hittable.zig");
const image = @import("image.zig");

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

    try world.add(Hittable.sphere(Vec3.init(0, 0, -1), 0.5));
    try world.add(Hittable.sphere(Vec3.init(0, -100.5, -1), 100));

    // Camera
    var cam = Camera.init(image_width, image_height, 100, 50);
    cam.render(&img, &world);
}
