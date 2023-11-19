const std = @import("std");

const math = std.math;
const expect = std.testing.expect;
const rtweekend = @import("rtweekend.zig");

const Infinity = rtweekend.Infinity;

pub const Interval = struct {
    min: f64,
    max: f64,

    const Self = @This();

    pub fn init(min: f64, max: f64) Self {
        return .{ .min = min, .max = max };
    }

    pub fn defaultInit() Self {
        return .{ .min = -Infinity, .max = Infinity };
    }

    pub fn contains(self: *Self, value: f64) bool {
        return self.min <= value and value <= self.max;
    }

    pub fn surrounds(self: *Self, value: f64) bool {
        return self.min < value and value < self.max;
    }

    pub fn clamp(self: *Self, value: f64) f64 {
        return math.clamp(value, self.min, self.max);
    }
};

pub const Empty = Interval.init(Infinity, -Infinity);
pub const Universe = Interval.init(-Infinity, Infinity);

test "[0, 10] interval" {
    const interval = Interval.init(0, 10);
    try expect(interval.min == 0);
}

test "interval [0, 10] contains" {
    var interval = Interval.init(0, 10);
    try expect(interval.contains(5));
    try expect(interval.contains(10));
    try expect(!interval.contains(50));
    try expect(!interval.contains(-50));
}

test "interval [0, 10] sourrounds" {
    var interval = Interval.init(0, 10);
    try expect(interval.surrounds(5));
    try expect(!interval.surrounds(10));
    try expect(!interval.surrounds(0));
}

test "get default interval" {
    var interval = Interval.defaultInit();
    try expect(interval.min == -Infinity);
    try expect(interval.min < 0);
    try expect(interval.max == Infinity);
    try expect(interval.max > 0);
}

test "clamp value to interval [0, 10]" {
    var interval = Interval.init(0, 10);
    try expect(interval.clamp(5) == 5);
    try expect(interval.clamp(10) == 10);
    try expect(interval.clamp(50) == 10);
    try expect(interval.clamp(-50) == 0);
}
