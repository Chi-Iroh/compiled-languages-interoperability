const std = @import("std");

export fn zig_hello() void {
    std.debug.print("Hello, world from Zig !\n", .{});
}
