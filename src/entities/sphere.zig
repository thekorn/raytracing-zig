const vec3 = @import("../vec3.zig");
const ray = @import("ray.zig");

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;

pub fn hit_sphere(center: Vec3, radius: f32, r: Ray) bool {
    const oc = r.origin.sub(center);
    const a = r.direction.dot(r.direction);
    const b = 2.0 * oc.dot(r.direction);
    const c = oc.dot(oc) - radius * radius;

    const discriminant = b * b - 4 * a * c;
    return discriminant >= 0;
}
