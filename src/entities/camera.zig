const std = @import("std");

const Ray = @import("ray.zig").Ray;
const hittable = @import("hittable.zig");
const image = @import("../image.zig");

const Interval = @import("../interval.zig").Interval;
const Infinity = @import("../rtweekend.zig").Infinity;

const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;
const PPMImage = image.PPMImage;

const Vec3 = @import("../vec3.zig").Vec3;

pub const Camera = struct {
    image_height: usize,
    image_width: usize,
    center: Vec3,
    pixel00_loc: Vec3,
    pixel_delta_u: Vec3,
    pixel_delta_v: Vec3,

    const Self = @This();

    pub fn init(image_width: usize, image_height: usize) Self {
        const aspect_ratio = @as(f32, @floatFromInt(image_width)) / @as(f32, @floatFromInt(image_height));

        const center = Vec3.init(0, 0, 0);

        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = aspect_ratio * viewport_height;

        const viewport_u = Vec3.init(viewport_width, 0, 0);
        const viewport_v = Vec3.init(0, -viewport_height, 0);

        const pixel_delta_u = viewport_u.div(@as(f32, @floatFromInt(image_width)));
        const pixel_delta_v = viewport_v.div(@as(f32, @floatFromInt(image_height)));

        const viewport_upper_left = center.sub(viewport_u.div(2)).add(viewport_v.div(2)).sub(Vec3.init(0, 0, focal_length));
        const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).div(2));

        return .{
            .image_width = image_width,
            .image_height = image_height,
            .center = center,
            .pixel00_loc = pixel00_loc,
            .pixel_delta_u = pixel_delta_u,
            .pixel_delta_v = pixel_delta_v,
        };
    }

    pub fn render(self: *Self, img: *PPMImage, world: *Hittable) void {
        for (0..self.image_height) |a| {
            const y = self.image_height - a - 1;
            for (0..self.image_width) |x| {
                const pixel_center = self.pixel00_loc
                    .add(self.pixel_delta_u.scalar(@as(f32, @floatFromInt(x))))
                    .sub(self.pixel_delta_v.scalar(@as(f32, @floatFromInt(y))));
                const ray_direction = pixel_center.sub(self.center);

                const r = Ray.init(self.center, ray_direction);
                const pixel_color = r.color(world);

                img.write_color(pixel_color);
            }
        }
    }

    pub fn ray_color(r: *Ray, world: *Hittable) Vec3 {
        var rec: HitRecord = undefined;

        if (world.hit(r, Interval.init(0, Infinity), rec)) {
            return Vec3.new(1, 1, 1).add(rec.normal).mul(0.5);
        }

        const unit_direction = r.direction.unit_vector();
        const a = 0.5 * (unit_direction.y + 1.0);
        return Vec3.new(1.0, 1.0, 1.0).mul(1.0 - a).add(Vec3.new(0.5, 0.7, 1.0).mul(a));
    }
};
