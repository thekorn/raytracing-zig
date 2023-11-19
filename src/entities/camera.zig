const std = @import("std");
const rtweekend = @import("../rtweekend.zig");

const math = std.math;

const Ray = @import("ray.zig").Ray;
const hittable = @import("hittable.zig");
const image = @import("../image.zig");

const Interval = @import("../interval.zig").Interval;
const Infinity = rtweekend.Infinity;
const RandGen = rtweekend.RandGen;
const getRandomInRange = rtweekend.getRandomInRange;
const degress_to_radians = rtweekend.degress_to_radians;

const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;
const PPMImage = image.PPMImage;

const Vec3 = @import("../vec3.zig").Vec3;

var rnd = RandGen.init(0);

pub const Camera = struct {
    image_height: usize,
    image_width: usize,
    center: Vec3,
    pixel00_loc: Vec3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,
    samples_per_pixel: usize,
    max_depth: usize,
    vfov: f32,
    lookfrom: Vec3,
    lookat: Vec3,
    vup: Vec3,
    u: Vec3,
    v: Vec3,
    w: Vec3,

    const Self = @This();

    pub fn init(image_width: usize, image_height: usize, samples_per_pixel: usize, max_depth: usize, vfov: f32, lookfrom: Vec3, lookat: Vec3, vup: Vec3) Self {
        const aspect_ratio = @as(f32, @floatFromInt(image_width)) / @as(f32, @floatFromInt(image_height));

        const center = lookfrom;

        const focal_length = lookfrom.sub(lookat).length();
        const theta = degress_to_radians(vfov);
        const h = math.tan(theta / 2.0);
        const viewport_height = 2.0 * h * focal_length;
        const viewport_width = aspect_ratio * viewport_height;

        // calculate the u,v,w unit vectors for the camera coordinate system
        const w = lookfrom.sub(lookat).unit_vector();
        const u = vup.cross(w).unit_vector();
        const v = w.cross(u);

        const viewport_u = u.scalar(viewport_width);
        const viewport_v = v.scalar(-1).scalar(viewport_height);

        const pixel_delta_u = viewport_u.div(@as(f32, @floatFromInt(image_width)));
        const pixel_delta_v = viewport_v.div(@as(f32, @floatFromInt(image_height)));

        const viewport_upper_left = center.sub(w.scalar(focal_length)).sub(viewport_u.div(2)).sub(viewport_v.div(2));
        const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).div(2));

        return .{
            .image_width = image_width,
            .image_height = image_height,
            .center = center,
            .pixel00_loc = pixel00_loc,
            .pixel_delta_u = pixel_delta_u,
            .pixel_delta_v = pixel_delta_v,
            .samples_per_pixel = samples_per_pixel,
            .max_depth = max_depth,
            .vfov = vfov,
            .lookfrom = lookfrom,
            .lookat = lookat,
            .vup = vup,
            .u = u,
            .v = v,
            .w = w,
        };
    }

    pub fn render(self: *Self, img: *PPMImage, world: *Hittable) void {
        for (0..self.image_height) |a| {
            const y = self.image_height - a - 1;
            for (0..self.image_width) |x| {
                var pixel_color = Vec3.init(0, 0, 0);
                for (0..self.samples_per_pixel) |_| {
                    var r = self.get_ray(x, y);
                    pixel_color = pixel_color.add(r.color(self.max_depth, world));
                }

                img.write_color(pixel_color, self.samples_per_pixel);
            }
        }
    }

    pub fn get_ray(self: *Self, x: usize, y: usize) Ray {
        const pixel_center = self.pixel00_loc
            .add(self.pixel_delta_u.scalar(@as(f32, @floatFromInt(x))))
            .sub(self.pixel_delta_v.scalar(@as(f32, @floatFromInt(y))));

        const pixel_sample = pixel_center.add(self.pixel_sample_square());

        const ray_origin = self.center;
        const ray_direction = pixel_sample.sub(ray_origin);

        return Ray.init(ray_origin, ray_direction);
    }

    pub fn pixel_sample_square(self: *Self) Vec3 {
        const px = getRandomInRange(&rnd, f32, -0.5, 0.5);
        const py = getRandomInRange(&rnd, f32, -0.5, 0.5);
        return self.pixel_delta_u.scalar(px).add(self.pixel_delta_v.scalar(py));
    }
};
