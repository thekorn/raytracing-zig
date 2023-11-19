const std = @import("std");

const vec3 = @import("../vec3.zig");
const Interval = @import("../interval.zig").Interval;
const Infinity = @import("../rtweekend.zig").Infinity;
const hittable = @import("hittable.zig");

const Vec3 = vec3.Vec3;
const HitRecord = hittable.HitRecord;
const Hittable = hittable.Hittable;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3,

    const Self = @This();

    pub fn init(origin: Vec3, direction: Vec3) Self {
        return .{ .origin = origin, .direction = direction };
    }

    pub fn at(self: Self, t: f64) Vec3 {
        return self.origin.add(self.direction.scalar(t));
    }

    pub fn color(self: Self, world: *Hittable) Vec3 {
        var rec: HitRecord = undefined;
        var i = Interval.init(0, Infinity);
        if (world.hit(self, &i, &rec)) {
            return rec.normal.add(Vec3.init(1.0, 1.0, 1.0)).scalar(0.5);
        }

        const unit_direction = self.direction.unit_vector();
        const a = 0.5 * (unit_direction.y() + 1.0);
        return (Vec3.init(1.0, 1.0, 1.0)
            .scalar(1.0 - a))
            .add((Vec3.init(0.5, 0.7, 1.0).scalar(a)));
    }
};
