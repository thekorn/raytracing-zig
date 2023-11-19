const expect = @import("std").testing.expect;
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
};

test "get interval [0, 10] interval" {
    const interval = Interval.init(0, 10);
    try expect(interval.min == 0);
}

test "get default interval" {
    const interval = Interval.defaultInit();
    try expect(interval.min == -Infinity);
    try expect(interval.min < 0);
    try expect(interval.max == Infinity);
    try expect(interval.max > 0);
}
