const std = @import("std");
const rtweekend = @import("rtweekend.zig");

const fmt = std.fmt;
const math = std.math;
const expect = std.testing.expect;

const RandGen = rtweekend.RandGen;
const getRandom = rtweekend.getRandom;
const getRandomInRange = rtweekend.getRandomInRange;

var rnd = RandGen.init(0);

pub fn debug_vec3(v: Vec3) void {
    std.debug.print("Vec3(x={d}, y={d}, z={d})\n", .{ v.x, v.y, v.z });
}

pub const Vec3 = struct {
    data: @Vector(3, f32),

    const Self = @This();

    pub fn init(x: f32, y: f32, z: f32) Self {
        return .{
            .data = @Vector(3, f32)(x, y, z),
        };
    }

    pub fn scalar(self: Self, s: f32) Self {
        const m: @Vector(3, f32) = @splat(s);
        return .{ .data = self.data * m };
    }

    pub fn div(self: Self, x: f32) Self {
        const y = 1.0 / x;
        return self.scalar(y);
    }

    pub fn add(self: Self, other: Vec3) Self {
        return .{
            .data = self.data + other.data,
        };
    }

    pub fn sub(self: Self, other: Vec3) Self {
        return self.add(other.scalar(-1.0));
    }

    pub fn dot(self: Self, other: Vec3) f32 {
        const s = self.mul(other);
        return .{
            .data = @reduce(.Add, s),
        };
    }

    pub fn mul(self: Self, other: Vec3) Self {
        return .{
            .data = self.data * other.data,
        };
    }

    pub fn cross(self: Self, other: Vec3) Self {
        return .{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn length(self: Self) f32 {
        return @sqrt(self.length_squared());
    }

    pub fn length_squared(self: Self) f32 {
        return self.dot(self);
    }

    pub fn reflect(self: Self, normal: Vec3) Self {
        return self.sub(normal.scalar(2.0 * self.dot(normal)));
    }

    pub fn refract(self: Self, normal: Vec3, etai_over_etat: f32) Self {
        const cos_theta = @min(self.scalar(-1.0).dot(normal), 1.0);
        const r_out_perp = self.add(normal.scalar(cos_theta)).scalar(etai_over_etat);
        const r_out_parallel = normal.scalar(-@sqrt(@abs(1.0 - r_out_perp.length_squared())));
        return r_out_perp.add(r_out_parallel);
    }

    pub fn near_zero(self: *Self) bool {
        // return true if the vector is close to zero in all dimensions.
        const s = 1e-8;
        return (@abs(self.x) < s) and (@abs(self.y) < s) and (@abs(self.z) < s);
    }

    pub fn unit_vector(self: Self) Self {
        return self.div(self.length());
    }

    pub fn is_equal(self: Self, other: Vec3) bool {
        return self.x == other.x and self.y == other.y and self.z == other.z;
    }

    pub fn to_string(self: Self) []const u8 {
        _ = self;
        //var all_together: []u8 = undefined;
        //var start: usize = 0;
        //const all_together_slice = all_together[start..];
        //const hello_world = try fmt.bufPrint(all_together_slice, "{s} {s}", .{ "hello", "world" });
        return "Vec3(" ++ "" ++ ")";
    }
};

pub fn random_on_hemisphere(normal: *Vec3) Vec3 {
    const on_unit_sphere = random_unit_vector();
    if (on_unit_sphere.dot(normal.*) > 0.0) {
        return on_unit_sphere;
    } else {
        return on_unit_sphere.scalar(-1.0);
    }
}

pub fn random_in_unit_sphere() Vec3 {
    while (true) {
        const p = random_in_range(-1.0, 1.0);
        if (p.length_squared() < 1.0) {
            return p;
        }
    }
}

pub fn random_unit_vector() Vec3 {
    return random_in_unit_sphere().unit_vector();
}

pub fn random() Vec3 {
    return .{
        .x = getRandom(rnd),
        .y = getRandom(rnd),
        .z = getRandom(rnd),
    };
}

pub fn random_in_range(min: f32, max: f32) Vec3 {
    return .{
        .x = getRandomInRange(&rnd, f32, min, max),
        .y = getRandomInRange(&rnd, f32, min, max),
        .z = getRandomInRange(&rnd, f32, min, max),
    };
}

test "create null vector" {
    const v = Vec3.init(0.0, 0.0, 0.0);
    try expect(v.x == 0.0);
    try expect(v.y == 0.0);
    try expect(v.z == 0.0);
}

test "create vector" {
    const v = Vec3.init(1.0, 2.0, 3.0);
    try expect(v.x == 1.0);
    try expect(v.y == 2.0);
    try expect(v.z == 3.0);
}

test "vec3 scalar" {
    const v = Vec3.init(1.0, 2.0, 3.0);
    const s = 2.0;
    const r = v.scalar(s);
    try expect(r.x == 2.0);
    try expect(r.y == 4.0);
    try expect(r.z == 6.0);
}

test "vec3 dot product" {
    const v1 = Vec3.init(1.0, 0.0, 0.0);
    const v2 = Vec3.init(0.0, 1.0, 0.0);
    try expect(v1.dot(v2) == 0.0);
}

test "vec3 is equal" {
    const v1 = Vec3.init(1.0, 2.0, 3.0);
    const v2 = Vec3.init(1.0, 2.0, 3.0);
    try expect(v1.is_equal(v2));
}

test "cross product of two vectors" {
    var a = Vec3{ .x = 1.0, .y = 2.0, .z = 3.0 };
    const b = Vec3{ .x = 4.0, .y = 5.0, .z = 6.0 };
    const expected = Vec3{ .x = -3.0, .y = 6.0, .z = -3.0 };
    var result = a.cross(b);
    try expect(result.is_equal(expected));
}

test "length of a vector" {
    var v = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const expected = 3.0;
    const result = v.length();
    try expect(result == expected);
}

test "squared length of a vector" {
    var v = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const expected = 9.0;
    const result = v.length_squared();
    try expect(result == expected);
}

test "unit vector of a vector" {
    var v = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const expected = Vec3{ .x = 1.0 / 3.0, .y = 2.0 / 3.0, .z = 2.0 / 3.0 };
    var result = v.unit_vector();
    try expect(result.is_equal(expected));
}

test "equality of two vectors" {
    var v1 = Vec3{ .x = 1.0, .y = 2.0, .z = 3.0 };
    const v2 = Vec3{ .x = 1.0, .y = 2.0, .z = 3.0 };
    const v3 = Vec3{ .x = 4.0, .y = 5.0, .z = 6.0 };
    try expect(v1.is_equal(v2));
    try expect(!v1.is_equal(v3));
}

test "scalar multiplication of a vector" {
    var v = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const s = 3.0;
    const expected = Vec3{ .x = 3.0, .y = 6.0, .z = 6.0 };
    var result = v.scalar(s);
    try expect(result.is_equal(expected));
}

test "division of a vector by a scalar" {
    var v = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const x = 2.0;
    const expected = Vec3{ .x = 0.5, .y = 1.0, .z = 1.0 };
    var result = v.div(x);
    try expect(result.is_equal(expected));
}

test "addition of two vectors" {
    var v1 = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const v2 = Vec3{ .x = 3.0, .y = 4.0, .z = 4.0 };
    const expected = Vec3{ .x = 4.0, .y = 6.0, .z = 6.0 };
    var result = v1.add(v2);
    try expect(result.is_equal(expected));
}

test "subtraction of two vectors" {
    var v1 = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const v2 = Vec3{ .x = 3.0, .y = 4.0, .z = 4.0 };
    const expected = Vec3{ .x = -2.0, .y = -2.0, .z = -2.0 };
    var result = v1.sub(v2);
    try expect(result.is_equal(expected));
}

test "dot product of two vectors" {
    var v1 = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const v2 = Vec3{ .x = 3.0, .y = 4.0, .z = 4.0 };
    const expected = 19.0;
    const result = v1.dot(v2);
    try expect(result == expected);
}

test "element-wise multiplication of two vectors" {
    var v1 = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    const v2 = Vec3{ .x = 3.0, .y = 4.0, .z = 4.0 };
    const expected = Vec3{ .x = 3.0, .y = 8.0, .z = 8.0 };
    var result = v1.mul(v2);
    try expect(result.is_equal(expected));
}

test "near zero" {
    var v1 = Vec3{ .x = 1.0, .y = 2.0, .z = 2.0 };
    var v2 = Vec3{ .x = 0.0, .y = 0.0, .z = 0.0 };
    var v3 = Vec3{ .x = 1e-9, .y = -1e-9, .z = 0.0 };
    try expect(!v1.near_zero());
    try expect(v2.near_zero());
    try expect(v3.near_zero());
}
