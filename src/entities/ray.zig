const vec3 = @import("../vec3.zig");

const sphere = @import("sphere.zig");

const Vec3 = vec3.Vec3;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3,

    pub fn init(origin: Vec3, direction: Vec3) Ray {
        return Ray{ .origin = origin, .direction = direction };
    }

    pub fn at(self: Ray, t: f32) Vec3 {
        return self.origin.add(self.direction.scale(t));
    }

    pub fn color(self: Ray) Vec3 {
        if (sphere.hit_sphere(Vec3.init(0.0, 0.0, -1.0), 0.5, self)) {
            return Vec3.init(1.0, 0.0, 0.0);
        }

        const unit_direction = self.direction.unit_vector();
        const a = 0.5 * (unit_direction.y + 1.0);
        return (Vec3.init(1.0, 1.0, 1.0)
            .scalar(1.0 - a))
            .add((Vec3.init(0.5, 0.7, 1.0).scalar(a)));
    }
};
