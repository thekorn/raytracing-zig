const std = @import("std");
const expect = @import("std").testing.expect;

const math = std.math;
const pi = math.pi;

pub const Infinity = std.math.floatMax(f64);

pub fn degress_to_radians(degrees: f32) f32 {
    return degrees * pi / 180.0;
}

test "degrees_to_radians" {
    const epsilon = 0.0001;
    const degrees = 90.0;
    const expected = pi / 2.0;
    const result = degress_to_radians(degrees);
    const diff = expected - result;
    const abs_diff = if (diff < 0.0) -diff else diff;
    try expect(abs_diff < epsilon);
}

test "use global Infinity" {
    try expect(Infinity > 0);
    try expect(-Infinity < 0);
}
