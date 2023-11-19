const std = @import("std");
const ArrayList = std.ArrayList;

const hittable = @import("hittable.zig");
const ray = @import("ray.zig");
const Interval = @import("../interval.zig").Interval;

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

    pub fn hit(self: *Self, r: Ray, ray_t: *Interval, rec: *HitRecord) bool {
        var temp_rec: HitRecord = undefined;
        var hit_anything: bool = false;
        var closest_so_far = ray_t.max;

        for (self.objects.items) |*object| {
            var i = Interval.init(ray_t.min, closest_so_far);
            if (object.hit(r, &i, &temp_rec)) {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }
        return hit_anything;
    }
};
