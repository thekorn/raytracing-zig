const math = @import("std").math;
const vec3 = @import("../vec3.zig");
const hittable = @import("hittable.zig");
const ray = @import("ray.zig");
const rtweekend = @import("../rtweekend.zig");

const Vec3 = vec3.Vec3;
const randomUnitVector = vec3.randomUnitVector;
const Ray = ray.Ray;
const HitRecord = hittable.HitRecord;
const getRandom = rtweekend.getRandom;

var rnd = rtweekend.RandGen.init(0);

pub const Lambertian = struct {
    albedo: Vec3,
    const Self = @This();

    pub fn init(albedo: Vec3) Self {
        return .{ .albedo = albedo };
    }

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        _ = r_in;
        var scatter_direction = rec.normal.add(randomUnitVector());

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
    fuzz: f64,
    const Self = @This();

    pub fn init(albedo: Vec3, f: f64) Self {
        return .{ .albedo = albedo, .fuzz = if (f < 1.0) f else 1.0 };
    }

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        const reflected = r_in.direction.unit_vector().reflect(rec.normal);
        scattered.* = Ray.init(rec.p, reflected.add(randomUnitVector().scalar(self.fuzz)));
        attenuation.* = self.albedo;
        return scattered.direction.dot(rec.normal) > 0.0;
    }
};

pub const Dielectric = struct {
    ir: f64,
    const Self = @This();

    pub fn init(index_of_refraction: f64) Self {
        return .{ .ir = index_of_refraction };
    }

    pub fn scatter(self: *Self, r_in: *Ray, rec: *HitRecord, attenuation: *Vec3, scattered: *Ray) bool {
        attenuation.* = Vec3.init(1.0, 1.0, 1.0);
        const refraction_ratio = if (rec.front_face) 1.0 / self.ir else self.ir;

        const unit_direction = r_in.direction.unit_vector();

        const cos_theta = @min(unit_direction.scalar(-1).dot(rec.normal), 1.0);
        const sin_theta = @sqrt(1.0 - cos_theta * cos_theta);

        const cannot_refract = refraction_ratio * sin_theta > 1.0;
        var direction: Vec3 = undefined;

        if (cannot_refract or Self.reflectance(cos_theta, refraction_ratio) > getRandom(&rnd, f64)) {
            direction = unit_direction.reflect(rec.normal);
        } else {
            direction = unit_direction.refract(rec.normal, refraction_ratio);
        }

        scattered.* = Ray.init(rec.p, direction);
        return true;
    }

    fn reflectance(cosine: f64, ref_idx: f64) f64 {
        // use Schlick's approximation for reflectance
        var r0 = (1 - ref_idx) / (1 + ref_idx);
        r0 = r0 * r0;
        return r0 + (1 - r0) * math.pow(f64, (1 - cosine), 5);
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

    pub fn metal(color: Vec3, fuzz: f64) Self {
        return Self{ .Metal = Metal.init(color, fuzz) };
    }

    pub fn dielectric(index_of_refraction: f64) Self {
        return Self{ .Dielectric = Dielectric.init(index_of_refraction) };
    }
};
