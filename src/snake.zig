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
    const nb_command_by_body_part = 3;
    const result = try allocator.alloc(Command, (s.body.len - 1) * nb_command_by_body_part + 1);
    var j: u8 = 1;
    result[0] = .{ .arc = .{ .position = s.body[0].position, .radius = s.body[0].radius, .angle = s.body[0].angle } };
    for (0..s.body.len - 1) |i| {
        const b1 = s.body[i];
        const b2 = s.body[i + 1];
        const spine_point = rl.Vector2{ .x = b1.position.x + b1.radius * std.math.cos(b1.angle), .y = b1.position.y + b1.radius * std.math.sin(b1.angle) };

        const l_x1 = b1.position.x + b1.radius * @cos(b1.angle - 0.5 * std.math.pi);
        const l_y1 = b1.position.y + b1.radius * @sin(b1.angle - 0.5 * std.math.pi);
        const l_x2 = b2.position.x + b2.radius * @cos(b2.angle - 0.5 * std.math.pi);
        const l_y2 = b2.position.y + b2.radius * @sin(b2.angle - 0.5 * std.math.pi);
        const l_point_b1 = rl.Vector2{ .x = l_x1, .y = l_y1 };
        const l_point_b2 = rl.Vector2{ .x = l_x2, .y = l_y2 };

        const r_x1 = b1.position.x + b1.radius * @cos(b1.angle + 0.5 * std.math.pi);
        const r_y1 = b1.position.y + b1.radius * @sin(b1.angle + 0.5 * std.math.pi);
        const r_x2 = b2.position.x + b2.radius * @cos(b2.angle + 0.5 * std.math.pi);
        const r_y2 = b2.position.y + b2.radius * @sin(b2.angle + 0.5 * std.math.pi);
        const r_point_b1 = rl.Vector2{ .x = r_x1, .y = r_y1 };
        const r_point_b2 = rl.Vector2{ .x = r_x2, .y = r_y2 };

        result[j] = .{ .line = .{ .point1 = l_point_b1, .point2 = l_point_b2 } };
        result[j + 1] = .{ .line = .{ .point1 = r_point_b1, .point2 = r_point_b2 } };
        result[j + 2] = .{ .line = .{ .point1 = b1.position, .point2 = spine_point } };
        j += nb_command_by_body_part;
    }
    return result;
}

pub fn move(s: *Snake) void {
    s.body[0].deplaceCircleInDirectionOfMouse();

    inline for (1..s.body.len) |i| {
        const prev_position = s.body[i - 1].position;
        s.body[i].deplaceCircleInDirectionOfPoint(prev_position);
    }
}
