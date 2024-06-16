const std = @import("std");

const vec3 = @import("../vec3.zig");
const Interval = @import("../interval.zig").Interval;
const ray = @import("ray.zig");
const Material = @import("material.zig").Material;
const sphere = @import("sphere.zig");
const hittableList = @import("hittableList.zig");

const Vec3 = vec3.Vec3;
const Ray = ray.Ray;
const Sphere = sphere.Sphere;
const HittableList = hittableList.HittableList;

pub const HitRecord = struct {
    p: Vec3,
    normal: Vec3,
    mat: Material,
    t: f32,
    front_face: bool = false,

    const Self = @This();

    pub fn init(p: Vec3, normal: Vec3, t: f32) Self {
        return .{ .p = p, .normal = normal, .t = t };
    }

    pub fn set_face_normal(self: *Self, r: Ray, outward_normal: Vec3) void {
        // Sets the hit record normal vector.
        // NOTE: the parameter `outward_normal` is assumed to have unit length.

        self.front_face = r.direction.dot(outward_normal) < 0.0;
        self.normal = if (self.front_face) outward_normal else outward_normal.scalar(-1.0);
    }
};

pub const Hittable = union(enum) {
    Sphere: Sphere,
    HittableList: HittableList,

    const Self = @This();

    pub fn hit(self: *Self, r: Ray, ray_t: *Interval, rec: *HitRecord) bool {
        return switch (self.*) {
            .Sphere => |*s| s.hit(r, ray_t, rec),
            .HittableList => |*l| l.hit(r, ray_t, rec),
        };
    }

    pub fn deinit(self: *Self) void {
        return switch (self.*) {
            .HittableList => |*l| l.deinit(),
            inline else => unreachable,
        };
    }

    pub fn add(self: *Self, s: Hittable) !void {
        _ = try switch (self.*) {
            .HittableList => |*l| l.add(s),
            inline else => unreachable,
        };
    }

    pub fn sphere(center: Vec3, radius: f32, meterial: *Material) Self {
        return Self{ .Sphere = Sphere.init(center, radius, meterial) };
    }

    pub fn hittable_list(allocator: std.mem.Allocator) Self {
        return Self{ .HittableList = HittableList.init(allocator) };
    }
};
