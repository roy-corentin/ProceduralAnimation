const std = @import("std");
const rl = @import("raylib");

pub export fn computeDirectionVector(pa: rl.Vector2, pb: rl.Vector2) rl.Vector2 {
    const dx = pb.x - pa.x;
    const dy = pb.y - pa.y;
    const distance = @sqrt(dx * dx + dy * dy);

    return .{ .x = dx / distance, .y = dy / distance };
}

pub export fn computeSpeed(distance: f32) f32 {
    const minSpeed = 1.0;
    const maxSpeed = 8.0;
    const speed = @min(distance, maxSpeed);

    return @max(minSpeed, speed);
}

pub export fn computeAngle(c: rl.Vector2, a: rl.Vector2, b: rl.Vector2) f32 {
    const xu = b.x - a.x;
    const yu = b.y - a.y;
    const xv = c.x - a.x;
    const yv = c.y - a.y;
    const scalarProduct = xu * xv + yu * yv;
    const abDistance = rl.Vector2.distance(a, b);
    const acDistance = rl.Vector2.distance(a, c);

    const angleRadians = std.math.acos(scalarProduct / (abDistance * acDistance));

    return angleRadians * (180.0 / std.math.pi);
}

fn i32ToString(number: i32) ![:0]const u8 {
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
