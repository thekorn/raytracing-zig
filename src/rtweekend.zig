const std = @import("std");
const expect = @import("std").testing.expect;

const math = std.math;
const pi = math.pi;

pub fn getInfinity(comptime T: type) T {
    return switch (@typeInfo(T)) {
        .ComptimeFloat, .Float => math.floatMax(T),
        .ComptimeInt, .Int => math.maxInt(T),
        else => @compileError("not implemented for " ++ @typeName(T)),
    };
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

test "getInfinity(u8)" {
    const infinity = getInfinity(u8);
    const expected = 255;
    try expect(infinity == expected);
}

test "getInfinity(u16)" {
    const infinity = getInfinity(u16);
    const expected = 65535;
    try expect(infinity == expected);
}

test "getInfinity(u32)" {
    const infinity = getInfinity(u32);
    const expected = 4294967295;
    try expect(infinity == expected);
}

test "getInfinity(u64)" {
    const infinity = getInfinity(u64);
    const expected = 18446744073709551615;
    try expect(infinity == expected);
}

test "getInfinity(i8)" {
    const infinity = getInfinity(i8);
    const expected = 127;
    try expect(infinity == expected);
}

test "getInfinity(i16)" {
    const infinity = getInfinity(i16);
    const expected = 32767;
    try expect(infinity == expected);
}

test "getInfinity(i32)" {
    const infinity = getInfinity(i32);
    const expected = 2147483647;
    try expect(infinity == expected);
}

test "getInfinity(i64)" {
    const infinity = getInfinity(i64);
    const expected = 9223372036854775807;
    try expect(infinity == expected);
}
