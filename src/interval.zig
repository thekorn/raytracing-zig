const expect = @import("std").testing.expect;
const rtweekend = @import("rtweekend.zig");

const getInfinity = rtweekend.getInfinity;

pub const Interval = struct {
    min: u32,
    max: u32,

    const Self = @This();

    pub fn init(min: u32, max: u32) Self {
        return .{ .min = min, .max = max };
    }

    pub fn defaultInit() Self {
        return .{ .min = getInfinity(u32), .max = getInfinity(u32) };
    }
};

test "get interval [0, 10] interval" {
    const interval = Interval.init(0, 10);
    try expect(interval.min == 0);
}
