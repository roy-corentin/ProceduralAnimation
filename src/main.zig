const std = @import("std");
const rl = @import("raylib");
const tools = @import("tools.zig");

const CommandType = enum { circle };

const Command = struct { type: CommandType, position: rl.Vector2, radius: f32 };

const Circle = struct { radius: f32, position: rl.Vector2 };

const Snake = struct { body: [7]Circle };

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
    const head = try allocator.alloc(Command, snake.body.len);
    for (0..snake.body.len) |i| {
        head[i] = .{ .type = CommandType.circle, .position = snake.body[i].position, .radius = snake.body[i].radius };
    }
    return head;
}

fn createSnake() Snake {
    const snake = Snake{
        .body = [7]Circle{
            .{ .radius = 25.0, .position = rl.Vector2{ .x = 400, .y = 225 } },
            .{ .radius = 25.0, .position = rl.Vector2{ .x = 350, .y = 225 } },
            .{ .radius = 25.0, .position = rl.Vector2{ .x = 300, .y = 225 } },
            .{ .radius = 25.0, .position = rl.Vector2{ .x = 250, .y = 225 } },
            .{ .radius = 25.0, .position = rl.Vector2{ .x = 200, .y = 225 } },
            .{ .radius = 25.0, .position = rl.Vector2{ .x = 150, .y = 225 } },
            .{ .radius = 25.0, .position = rl.Vector2{ .x = 100, .y = 225 } },
        },
    };

    return snake;
}

fn drawCommands(commands: []const Command) void {
    for (commands) |command| drawCommand(&command);
}

fn drawCommand(command: *const Command) void {
    if (command.type == CommandType.circle)
        rl.drawCircleLinesV(command.position, command.radius, rl.Color.red);
}

fn deplaceSnake(snake: *Snake) void {
    deplaceCircleInDirectionOfMouse(&snake.body[0]);

    for (1..snake.body.len) |i| {
        const distantConstraint = snake.body[i].radius + snake.body[i - 1].radius;
        deplaceCircleInDirectionOfPoint(&snake.body[i], snake.body[i - 1].position, distantConstraint);
    }
    fixUnaturalAngles(snake);
}

fn deplaceCircleInDirectionOfMouse(c: *Circle) void {
    deplaceCircleInDirectionOfPoint(c, rl.getMousePosition(), c.radius);
}

fn deplaceCircleInDirectionOfPoint(circle: *Circle, target: rl.Vector2, distanceConstraint: f32) void {
    const distance = rl.Vector2.distance(circle.position, target);
    if (distance >= distanceConstraint - 5 and distance <= distanceConstraint + 5) return;

    const directionVector = if (distance > distanceConstraint)
        tools.computeDirectionVector(circle.position, target)
    else
        tools.computeDirectionVector(target, circle.position);

    updateCirclePosition(circle, directionVector, tools.computeSpeed(distance));
}

inline fn updateCirclePosition(circle: *Circle, directionVector: rl.Vector2, speed: f32) void {
    circle.position = rl.Vector2.add(circle.position, rl.Vector2.scale(directionVector, speed));
}

fn fixUnaturalAngles(snake: *Snake) void {
    std.debug.print("Start\n", .{});
    for (0..snake.body.len - 2) |i| {
        const angle = tools.computeAngle(snake.body[i].position, snake.body[i + 1].position, snake.body[i + 2].position);
        std.debug.print("{d} between {d} {d} {d}\n", .{ angle, i, i + 1, i + 2 });
    }
    std.debug.print("End\n", .{});
}
