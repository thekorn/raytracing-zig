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
    fuzz: f32,
    const Self = @This();

    pub fn init(albedo: Vec3, f: f32) Self {
        return .{ .albedo = albedo, .fuzz = if (f < 1.0) f else 1.0 };
    }

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        const reflected = r_in.direction.unit_vector().reflect(rec.normal);
        scattered.* = Ray.init(rec.p, reflected.add(random_unit_vector().scalar(self.fuzz)));
        attenuation.* = self.albedo;
        return scattered.direction.dot(rec.normal) > 0.0;
    }
};

pub const Dielectric = struct {
    ir: f32,
    const Self = @This();

    pub fn init(index_of_refraction: f32) Self {
        return .{ .ir = index_of_refraction };
    }

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        attenuation.* = Vec3.init(1.0, 1.0, 1.0);
        const refraction_ratio = if (rec.front_face) 1.0 / self.ir else self.ir;

        const unit_direction = r_in.direction.unit_vector();
        const refracted = unit_direction.refract(rec.normal, refraction_ratio);

        scattered.* = Ray.init(rec.p, refracted);
        return true;
    }
};

pub const Material = union(enum) {
    Lambertian: Lambertian,
    Metal: Metal,
    Dielectric: Dielectric,
    const Self = @This();

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        return switch (self.*) {
            .Lambertian => |*m| m.scatter(r_in, rec, attenuation, scattered),
            .Metal => |*m| m.scatter(r_in, rec, attenuation, scattered),
            .Dielectric => |*d| d.scatter(r_in, rec, attenuation, scattered),
        };
    }

    pub fn lambertian(color: Vec3) Self {
        return Self{ .Lambertian = Lambertian.init(color) };
    }

    pub fn metal(color: Vec3, fuzz: f32) Self {
        return Self{ .Metal = Metal.init(color, fuzz) };
    }

    pub fn dielectric(index_of_refraction: f32) Self {
        return Self{ .Dielectric = Dielectric.init(index_of_refraction) };
    }
};
