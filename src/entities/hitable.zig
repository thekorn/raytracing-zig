const vec3 = @import("../vec3.zig");
const ray = @import("ray.zig");

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;

pub const HitRecord = struct {
    p: Vec3,
    normal: Vec3,
    t: f32,
    front_face: bool = false,

    pub fn init(p: Vec3, normal: Vec3, t: f32) HitRecord {
        return HitRecord{ .p = p, .normal = normal, .t = t };
    }

    pub fn set_face_normal(self: *HitRecord, r: *Ray, outward_normal: Vec3) void {
        // Sets the hit record normal vector.
        // NOTE: the parameter `outward_normal` is assumed to have unit length.

        self.front_face = r.direction.dot(outward_normal) < 0.0;
        self.normal = if (self.front_face) outward_normal else -outward_normal;
    }
};
