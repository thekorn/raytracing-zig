const vec3 = @import("../vec3.zig");
const hittable = @import("hittable.zig");
const ray = @import("ray.zig");

const Vec3 = vec3.Vec3;
const random_unit_vector = vec3.random_unit_vector;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;

pub const Lambertian = struct {
    albedo: Vec3,
    const Self = @This();

    pub fn init(albedo: *Vec3) Self {
        return .{albedo};
    }

    pub fn scatter(self: *Self, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        const scatter_direction = rec.normal.add(random_unit_vector());

        if (scatter_direction.near_zero()) {
            scatter_direction = rec.normal;
        }

        scattered = Ray.init(rec.p, scatter_direction);
        attenuation = self.albedo;
        return true;
    }
};

pub const Material = union(enum) {
    Lambertian: Lambertian,
    const Self = @This();

    pub fn scatter(self: *Self, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        return switch (self.*) {
            .Lambertian => |*m| m.scatter(rec, attenuation, scattered),
        };
    }
};
