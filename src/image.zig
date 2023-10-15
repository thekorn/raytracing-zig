const std = @import("std");

const vec3 = @import("vec3.zig");

const Vec3 = vec3.Vec3;

pub const PPMImage = struct {
    buffered_writer: std.io.BufferedWriter(4096, std.fs.File.Writer),
    out_fd: std.fs.File,

    pub fn init(fd: std.fs.File) PPMImage {
        const writer = fd.writer();

        var bw = std.io.bufferedWriter(writer);
        return .{ .buffered_writer = bw, .out_fd = fd };
    }

    pub fn deinit(self: *PPMImage) void {
        self.buffered_writer.flush() catch {};
        self.out_fd.close();
    }

    fn println(self: *PPMImage, comptime format: []const u8, args: anytype) !void {
        self.buffered_writer.writer().print(format ++ "\n", args) catch {};
    }

    pub fn write_header(self: *PPMImage, width: usize, height: usize) void {
        self.println("P3", .{}) catch {};
        self.println("{d} {d}", .{ width, height }) catch {};
        self.println("255", .{}) catch {};
    }

    fn write_pixel(self: *PPMImage, r: usize, g: usize, b: usize) void {
        self.println("{d} {d} {d}", .{ r, g, b }) catch {};
    }

    pub fn write_color(self: *PPMImage, c: Vec3) void {
        const normColor = c.scalar(255);
        const r = @as(usize, @intFromFloat(normColor.x));
        const g = @as(usize, @intFromFloat(normColor.y));
        const b = @as(usize, @intFromFloat(normColor.z));
        self.write_pixel(r, g, b);
    }
};

pub fn makePPMImageFile(filename: []const u8, width: usize, height: usize) !PPMImage {
    const fd = try std.fs.cwd().createFile(filename, .{ .read = true });
    var ppm = PPMImage.init(fd);
    ppm.write_header(width, height);
    return ppm;
}

pub fn makePPMImageStdOut(width: usize, height: usize) !PPMImage {
    const fd = std.io.getStdOut();
    var ppm = PPMImage.init(fd);
    ppm.write_header(width, height);
    return ppm;
}
