pub const Snake = @This();
const std = @import("std");
const rl = @import("raylib");
const drawing = @import("drawing.zig");
const Circle = drawing.Circle;
const Command = drawing.Command;
const CommandType = drawing.CommandType;

const SnakeLen = 15;
body: [SnakeLen]Circle,

pub fn init() Snake {
    const r1 = 25.0;
    var x: f32 = 400;
    var body: [SnakeLen]Circle = undefined;

    inline for (0..SnakeLen) |i| {
        const r = r1 - @as(f32, @floatFromInt(i)) * (r1 / @as(f32, @floatFromInt(SnakeLen - 1)));
        x = x - r;
        body[i] = .{ .radius = r, .position = rl.Vector2{ .x = x, .y = 225 }, .angle = 0 };
    }

    return Snake{
        .body = body,
    };
}

pub fn generateCommand(s: *const Snake, allocator: std.mem.Allocator) ![]Command {
    const head = try allocator.alloc(Command, s.body.len * 2);
    var i: u16 = 0;
    for (s.body) |body| {
        head[i] = .{ .type = CommandType.circle, .position = body.position, .radius = body.radius, .angle = body.angle };
        head[i + 1] = .{ .type = CommandType.line, .position = body.position, .radius = body.radius, .angle = body.angle };
        i = i + 2;
    }
    return head;
}

pub fn move(s: *Snake) void {
    s.body[0].deplaceCircleInDirectionOfMouse();

    inline for (1..s.body.len) |i| {
        const prev_position = s.body[i - 1].position;
        s.body[i].deplaceCircleInDirectionOfPoint(prev_position);
    }
}
