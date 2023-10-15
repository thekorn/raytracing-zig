const vec3 = @import("../vec3.zig");
const ray = @import("ray.zig");
const hitable = @import("hitable.zig");

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;
const HitRecord = hitable.HitRecord;

pub const Sphere = struct {
    center: Vec3,
    radius: f32,

    pub fn init(center: Vec3, radius: f32) Sphere {
        return .{ .center = center, .radius = radius };
    }

    pub fn hit(self: *Sphere, r: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
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

pub fn hit_sphere(center: Vec3, radius: f32, r: Ray) f32 {
    const oc = r.origin.sub(center);
    const a = r.direction.length_squared();
    const half_b = oc.dot(r.direction);
    const c = oc.length_squared() - radius * radius;

    const discriminant = half_b * half_b - a * c;

    if (discriminant < 0) {
        return -1.0;
    } else {
        return (-half_b - @sqrt(discriminant)) / a;
    }
}