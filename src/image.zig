const std = @import("std");

const vec3 = @import("vec3.zig");
const Interval = @import("interval.zig").Interval;

const Vec3 = vec3.Vec3;

pub fn linear_to_gamma(x: f32) f32 {
    return @sqrt(x);
}

pub const PPMImage = struct {
    buffered_writer: std.io.BufferedWriter(4096, std.fs.File.Writer),
    out_fd: std.fs.File,

    const Self = @This();

    /// Initializes a new PPMImage instance.
    /// @param fd: The file descriptor to write the image data to.
    /// @return: A new PPMImage instance.
    pub fn init(fd: std.fs.File) Self {
        const writer = fd.writer();

        const bw = std.io.bufferedWriter(writer);
        return .{ .buffered_writer = bw, .out_fd = fd };
    }

    /// Cleans up a PPMImage instance.
    /// This function flushes any remaining data in the buffered writer and closes the file descriptor.
    /// @param self: The PPMImage instance to clean up.
    pub fn deinit(self: *Self) void {
        self.buffered_writer.flush() catch {};
        self.out_fd.close();
    }

    fn println(self: *Self, comptime format: []const u8, args: anytype) !void {
        self.buffered_writer.writer().print(format ++ "\n", args) catch {};
    }

    /// Writes the header of a PPM image file to the output stream.
    /// The header contains the magic number "P3", the width and height of the image, and the maximum color value (255).
    /// @param self: The PPMImage instance to write the header to.
    /// @param width: The width of the image.
    /// @param height: The height of the image.
    pub fn write_header(self: *Self, width: usize, height: usize) void {
        self.println("P3", .{}) catch {};
        self.println("{d} {d}", .{ width, height }) catch {};
        self.println("255", .{}) catch {};
    }

    fn write_pixel(self: *Self, r: usize, g: usize, b: usize) void {
        self.println("{d} {d} {d}", .{ r, g, b }) catch {};
    }

    /// Writes a color to the PPM image file.
    /// The color is represented as a Vec3, with each component being a floating-point value between 0 and 1.
    /// These values are scaled to the range 0-255 and converted to integers to write to the file.
    /// @param self: The PPMImage instance to write the color to.
    /// @param c: The color to write, represented as a Vec3.
    pub fn write_color(self: *Self, c: Vec3, samples_per_pixel: usize) void {
        var r = c.x;
        var g = c.y;
        var b = c.z;

        const scale = 1.0 / @as(f32, @floatFromInt(samples_per_pixel));
        r *= scale;
        g *= scale;
        b *= scale;

        r = linear_to_gamma(r);
        g = linear_to_gamma(g);
        b = linear_to_gamma(b);

        var intensity = Interval.init(0, 0.999);

        self.write_pixel(
            @as(usize, @intFromFloat(255.0 * intensity.clamp(r))),
            @as(usize, @intFromFloat(255.0 * intensity.clamp(g))),
            @as(usize, @intFromFloat(255.0 * intensity.clamp(b))),
        );
    }
};

/// Creates a new PPMImage and writes the header to it.
/// @param fd: The file descriptor to write the image data to.
/// @param width: The width of the image.
/// @param height: The height of the image.
/// @return: A new PPMImage instance with the header already written.
fn makePPMImage(fd: std.fs.File, width: usize, height: usize) !PPMImage {
    var ppm = PPMImage.init(fd);
    ppm.write_header(width, height);
    return ppm;
}

/// Creates a new PPMImage file.
/// This function initializes a new PPMImage instance, writes the header to it, and returns the instance.
/// @param filename: The name of the file to create.
/// @param width: The width of the image.
/// @param height: The height of the image.
/// @return: A new PPMImage instance with the header already written.
pub fn makePPMImageFile(filename: []const u8, width: usize, height: usize) !PPMImage {
    const fd = try std.fs.cwd().createFile(filename, .{ .read = true });
    return makePPMImage(fd, width, height);
}

/// Creates a new PPMImage and writes the header to the standard output.
/// This function initializes a new PPMImage instance, writes the header to it, and returns the instance.
/// @param width: The width of the image.
/// @param height: The height of the image.
/// @return: A new PPMImage instance with the header already written to the standard output.
pub fn makePPMImageStdOut(width: usize, height: usize) !PPMImage {
    const fd = std.io.getStdOut();
    return makePPMImage(fd, width, height);
}

//test "makePPMImageFile creates a file with the correct dimensions" {
//    const filename = "test.ppm";
//    const width = 100;
//    const height = 50;
//
//    defer std.fs.cwd().deleteFile(filename) catch {};
//
//    var img = try makePPMImageFile(filename, width, height);
//
//    defer img.deinit();
//    //const file = try std.fs.cwd().openFile(filename, .{});
//
//    //const expectedHeader = std.fmt.allocPrint("P3\n{} {}\n255\n", .{ width, height });
//    //defer std.fmt.free(expectedHeader);
//
//    //const actualHeader = try file.
//    //defer std.mem.free(actualHeader);
//    //
//    //std.testing.expectEqualStrings("expectedHeader", actualHeader);
//}
