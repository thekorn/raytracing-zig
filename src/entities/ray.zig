const vec3 = @import("../vec3.zig");

const sphere = @import("sphere.zig");

const Vec3 = vec3.Vec3;

pub const Ray = struct {
    origin: Vec3,
    direction: Vec3,

    const Self = @This();

    pub fn init(origin: Vec3, direction: Vec3) Self {
        return .{ .origin = origin, .direction = direction };
    }

    pub fn at(self: Self, t: f32) Vec3 {
        return self.origin.add(self.direction.scalar(t));
    }

    pub fn color(self: Self) Vec3 {
        const t = sphere.hit_sphere(Vec3.init(0.0, 0.0, -1.0), 0.5, self);
        if (t > 0.0) {
            const N = self.at(t).sub(Vec3.init(0.0, 0.0, -1.0)).unit_vector();
            return Vec3.init(N.x + 1.0, N.y + 1.0, N.z + 1.0).scalar(0.5);
        }

        const unit_direction = self.direction.unit_vector();
        const a = 0.5 * (unit_direction.y + 1.0);
        return (Vec3.init(1.0, 1.0, 1.0)
            .scalar(1.0 - a))
            .add((Vec3.init(0.5, 0.7, 1.0).scalar(a)));
    }
};
