const vec3 = @import("../vec3.zig");
const ray = @import("ray.zig");

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;

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
