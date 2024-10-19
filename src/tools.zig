const std = @import("std");

pub fn i32ToString(number: i32) ![:0]const u8 {
    var modulo: i32 = 1;
    var size: u8 = 1;
    var tmp = number;
    const allocator = std.heap.c_allocator;

    while (@divFloor(number, modulo) > 10) {
        modulo *= 10;
        size += 1;
    }

    var string: [:0]u8 = try allocator.allocSentinel(u8, size, 0);

    while (size > 0) {
        string[string.len - size] = @intCast(@divFloor(tmp, modulo) + 48);
        size -= 1;
        tmp = @mod(tmp, modulo);
        modulo = @divFloor(modulo, 10);
    }

    std.debug.print("String: {s}, FPS: {d}\n", .{ string, number });
    return string;
}
