const std = @import("std");
const rl = @import("raylib");

// const Ball = @import("ballz/ballz.zig").Ball;

// const julia = @import("fractalz/julia_set.zig");
const mandelbrot = @import("fractalz/mandelbrot_set.zig");

pub fn main() anyerror!void {
    try mandelbrot.run();
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
