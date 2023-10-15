const std = @import("std");
const ArrayList = std.ArrayList;

const hittable = @import("hittable.zig");
const ray = @import("ray.zig");

const Hittable = hittable.Hittable;
const HitRecord = hittable.HitRecord;
const Ray = ray.Ray;

pub const HittableList = struct {
    objects: ArrayList(Hittable),

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator) Self {
        return .{ .objects = ArrayList(Hittable).init(allocator) };
    }

    pub fn deinit(self: *Self) void {
        self.objects.deinit();
    }

    pub fn add(self: *Self, s: Hittable) anyerror!*Self {
        try self.objects.append(s);
        return self;
    }

    pub fn hit(self: *Self, r: Ray, t_min: f32, t_max: f32, rec: *HitRecord) bool {
        var temp_rec: HitRecord = undefined;
        var hit_anything: bool = false;
        var closest_so_far = t_max;

        for (self.objects.items) |*object| {
            if (object.hit(r, t_min, closest_so_far, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        return hit_anything;
    }
};
