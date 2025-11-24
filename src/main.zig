const std = @import("std");
const rl = @import("raylib");
const tools = @import("tools.zig");
const debug = std.debug;

const CommandType = enum { circle, line };

const Command = struct { type: CommandType, position: rl.Vector2, radius: f32, angle: f32 };

const Circle = struct { radius: f32, position: rl.Vector2, angle: f32 };

const SnakeLen = 15;
const Snake = struct { body: [SnakeLen]Circle };

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const screenWidth = 1000;
    const screenHeight = 900;
    var snake = createSnake();

    rl.setTargetFPS(60);
    rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });

    rl.initWindow(screenWidth, screenHeight, "ProceduralAnimation");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.blank);
        rl.drawFPS(10, 10);
        deplaceSnake(&snake);
        const commands: []Command = try getSnakeCommands(&snake, allocator);
        defer allocator.free(commands);
        drawCommands(commands);
    }
}

fn getSnakeCommands(snake: *const Snake, allocator: std.mem.Allocator) ![]Command {
    const head = try allocator.alloc(Command, snake.body.len * 2);
    var i: u16 = 0;
    for (snake.body) |body| {
        head[i] = .{ .type = CommandType.circle, .position = body.position, .radius = body.radius, .angle = body.angle };
        head[i + 1] = .{ .type = CommandType.line, .position = body.position, .radius = body.radius, .angle = body.angle };
        i = i + 2;
    }
    return head;
}

fn createSnake() Snake {
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

fn drawCommands(commands: []const Command) void {
    for (commands) |command| drawCommand(&command);
}

fn drawCommand(command: *const Command) void {
    switch (command.type) {
        CommandType.circle => {
            rl.drawCircleLinesV(command.position, command.radius, rl.Color.red);
        },
        CommandType.line => {
            rl.drawLineV(command.position, rl.Vector2{ .x = command.position.x + command.radius * std.math.cos(command.angle), .y = command.position.y + command.radius * std.math.sin(command.angle) }, rl.Color.red);
        },
    }
}

fn deplaceSnake(snake: *Snake) void {
    deplaceCircleInDirectionOfMouse(&snake.body[0]);

    inline for (1..snake.body.len) |i| {
        deplaceCircleInDirectionOfPoint(&snake.body[i], snake.body[i - 1].position);
    }
}

fn deplaceCircleInDirectionOfMouse(c: *Circle) void {
    deplaceCircleInDirectionOfPoint(c, rl.getMousePosition());
}

fn deplaceCircleInDirectionOfPoint(circle: *Circle, target: rl.Vector2) void {
    const distanceConstraint = circle.radius;
    const distance = rl.Vector2.distance(circle.position, target);
    if (distance >= distanceConstraint - 5 and distance <= distanceConstraint + 5) return;

    const directionVector = if (distance > distanceConstraint)
        tools.computeDirectionVector(circle.position, target)
    else
        tools.computeDirectionVector(target, circle.position);

    updateCirclePosition(circle, directionVector, tools.computeSpeed(distance));
    updateCircleAngle(circle, target);
}

inline fn updateCirclePosition(circle: *Circle, directionVector: rl.Vector2, speed: f32) void {
    circle.position = rl.Vector2.add(circle.position, rl.Vector2.scale(directionVector, speed));
}

inline fn updateCircleAngle(circle: *Circle, target: rl.Vector2) void {
    circle.angle = std.math.atan2(target.y - circle.position.y, target.x - circle.position.x);
}
