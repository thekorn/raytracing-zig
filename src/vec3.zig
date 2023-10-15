const std = @import("std");

const fmt = std.fmt;
const expect = @import("std").testing.expect;

pub fn debug_vec3(v: Vec3) void {
    std.debug.print("Vec3(x={d}, y={d}, z={d})", .{ v.x, v.y, v.z });
}

pub const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    pub fn init(x: f32, y: f32, z: f32) Vec3 {
        return Vec3{
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn scalar(self: Vec3, s: f32) Vec3 {
        return Vec3{
            .x = self.x * s,
            .y = self.y * s,
            .z = self.z * s,
        };
    }

    pub fn div(self: Vec3, x: f32) Vec3 {
        const y = 1.0 / x;
        return self.scalar(y);
    }

    pub fn add(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x + other.x,
            .y = self.y + other.y,
            .z = self.z + other.z,
        };
    }

    pub fn sub(self: Vec3, other: Vec3) Vec3 {
        return self.add(other.scalar(-1.0));
    }

    pub fn dot(self: Vec3, other: Vec3) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }

    pub fn mul(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.x * other.x,
            .y = self.y * other.y,
            .z = self.z * other.z,
        };
    }

    pub fn cross(self: Vec3, other: Vec3) Vec3 {
        return Vec3{
            .x = self.y * other.z - self.z * other.y,
            .y = self.z * other.x - self.x * other.z,
            .z = self.x * other.y - self.y * other.x,
        };
    }

    pub fn length(self: Vec3) f32 {
        return @sqrt(self.length_squared());
    }

    pub fn length_squared(self: Vec3) f32 {
        return self.dot(self);
    }

    pub fn unit_vector(self: Vec3) Vec3 {
        return self.div(self.length());
    }

    pub fn is_equal(self: Vec3, other: Vec3) bool {
        return self.x == other.x and self.y == other.y and self.z == other.z;
    }

    pub fn to_string(self: Vec3) []const u8 {
        _ = self;
        //var all_together: []u8 = undefined;
        //var start: usize = 0;
        //const all_together_slice = all_together[start..];
        //const hello_world = try fmt.bufPrint(all_together_slice, "{s} {s}", .{ "hello", "world" });
        return "Vec3(" ++ "" ++ ")";
    }
};

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

// TODO: add more tests

//test "to string" {
//    const v1 = Vec3.init(1.5, 2.0, 3.0);
//    debug_vec3(v1);
//}
