const vec3 = @import("../vec3.zig");
const ray = @import("ray.zig");
const hitable = @import("hittable.zig");

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;
const HitRecord = hitable.HitRecord;

pub const Sphere = struct {
    center: Vec3,
    radius: f32,

    const Self = @This();

    pub fn init(center: Vec3, radius: f32) Self {
        return .{ .center = center, .radius = radius };
    }

    pub fn hit(self: *Self, r: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        const oc = r.origin.sub(self.center);
        const a = r.direction.length_squared();
        const half_b = oc.dot(r.direction);
        const c = oc.length_squared() - self.radius * self.radius;

        const discriminant = half_b * half_b - a * c;

        if (discriminant < 0) {
            return false;
        }
        const sqrtd = @sqrt(discriminant);

        // Find the nearest root that lies in the acceptable range.
        var root = (-half_b - sqrtd) / a;
        if (root <= t_min or t_max <= root) {
            root = (-half_b + sqrtd) / a;
            if (root <= t_min or t_max <= root) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal = (rec.p.sub(self.center)).div(self.radius);
        rec.set_face_normal(r, outward_normal);
        return true;
    }
};
