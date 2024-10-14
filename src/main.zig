const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    const allocator = std.heap.c_allocator;

    rl.setTargetFPS(60);
    rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });

    rl.initWindow(screenWidth, screenHeight, "ProceduralAnimation");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);
        try drawFps(allocator);
        rl.endDrawing();
    }
}

pub fn drawFps(allocator: std.mem.Allocator) !void {
    const fps: [:0]const u8 = try i32ToString(rl.getFPS());
    defer allocator.free(fps);

    rl.drawText(fps, 10, 10, 24, rl.Color.green);
}

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
