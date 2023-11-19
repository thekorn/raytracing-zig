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

    pub fn init(albedo: Vec3) Self {
        return .{ .albedo = albedo };
    }

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        _ = r_in;
        var scatter_direction = rec.normal.add(random_unit_vector());

        if (scatter_direction.near_zero()) {
            scatter_direction = rec.normal;
        }

        scattered.* = Ray.init(rec.p, scatter_direction);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const Metal = struct {
    albedo: Vec3,
    const Self = @This();

    pub fn init(albedo: Vec3) Self {
        return .{ .albedo = albedo };
    }

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        const reflected = r_in.direction.unit_vector().reflect(rec.normal);
        scattered.* = Ray.init(rec.p, reflected);
        attenuation.* = self.albedo;
        return true;
    }
};

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,
    const Self = @This();

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        return switch (self.*) {
            .Lambertian => |*m| m.scatter(r_in, rec, attenuation, scattered),
            .Metal => |*m| m.scatter(r_in, rec, attenuation, scattered),
        };
    }

    pub fn lambertian(color: Vec3) Self {
        return Self{ .Lambertian = Lambertian.init(color) };
    }

    pub fn metal(color: Vec3) Self {
        return Self{ .Metal = Metal.init(color) };
    }
};
