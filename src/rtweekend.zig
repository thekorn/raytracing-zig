const std = @import("std");
const expect = @import("std").testing.expect;

const math = std.math;
const pi = math.pi;

pub const RandGen = std.rand.DefaultPrng;

pub const Infinity = std.math.floatMax(f32);

pub fn getRandom(rnd: *RandGen, comptime T: type) T {
    return switch (@typeInfo(T)) {
        .ComptimeFloat, .Float => rnd.*.random().float(T),
        .ComptimeInt, .Int => return rnd.*.random().int(T),
        else => @compileError("not implemented for " ++ @typeName(T)),
    };
}

pub fn getRandomInRange(rnd: *RandGen, comptime T: type, min: T, max: T) T {
    return getRandom(rnd, T) * (max - min) + min;
}

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

test "random" {
    var i: u32 = 0;
    var rnd = RandGen.init(0);
    while (i < 10) {
        const a = getRandom(&rnd, f32);
        try expect(a <= 1);
        try expect(a >= 0);
        i += 1;
    }
}

test "randomInRange" {
    var i: u32 = 0;
    var rnd = RandGen.init(0);
    while (i < 10) {
        const a = getRandomInRange(&rnd, f32, -2, -1);
        try expect(a <= -1);
        try expect(a >= -2);
        i += 1;
    }
}
