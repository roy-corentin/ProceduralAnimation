const std = @import("std");
const rl = @import("raylib");
const tools = @import("tools.zig");

const CommandType = enum { circle };

const Command = struct { type: CommandType, position: rl.Vector2, radius: f32 };

const Circle = struct { radius: f32, position: rl.Vector2 };

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const screenWidth = 1000;
    const screenHeight = 900;
    const circles = try createCircles(7, allocator);
    defer allocator.free(circles);

    rl.setTargetFPS(60);
    rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });

    rl.initWindow(screenWidth, screenHeight, "ProceduralAnimation");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(rl.Color.blank);
        rl.drawFPS(10, 10);
        deplaceCircles(circles);
        const commands: []Command = try getCircleCommands(circles, allocator);
        drawCommands(commands);
    }
}

fn getCircleCommands(circles: []Circle, allocator: std.mem.Allocator) ![]Command {
    const head = try allocator.alloc(Command, circles.len);
    for (0..circles.len) |i| {
        head[i] = .{ .type = CommandType.circle, .position = circles[i].position, .radius = circles[i].radius };
    }
    return head;
}

fn createCircles(number: usize, allocator: std.mem.Allocator) ![]Circle {
    var x: f32 = 400.0;
    const y = 225.0;
    const baseRadius = 25.0;

    const head = try allocator.alloc(Circle, number);

    for (0..number) |i| {
        const source = @min(@as(f32, @floatFromInt(@mod(i, @divFloor(number, 2)))), 1.0);
        const circleRadius = baseRadius + source * 4.0;
        head[i] = .{ .position = .{ .x = x, .y = y }, .radius = circleRadius };
        x -= circleRadius * 2.0;
    }
    return head;
}

fn drawCommands(commands: []Command) void {
    for (commands) |command| drawCommand(&command);
}

fn drawCommand(command: *const Command) void {
    if (command.type == CommandType.circle)
        rl.drawCircleLinesV(command.position, command.radius, rl.Color.red);
}

fn deplaceCircles(circles: []Circle) void {
    deplaceCircleInDirectionOfMouse(&circles[0]);

    for (1..circles.len) |i| {
        const distantConstraint = circles[i].radius + circles[i - 1].radius;
        deplaceCircleInDirectionOfPoint(&circles[i], circles[i - 1].position, distantConstraint);
    }
    fixUnaturalAngles(circles);
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

fn fixUnaturalAngles(circles: []Circle) void {
    std.debug.print("Start\n", .{});
    for (0..circles.len - 2) |i| {
        const angle = tools.computeAngle(circles[i].position, circles[i + 1].position, circles[i + 2].position);
        std.debug.print("{d} between {d} {d} {d}\n", .{ angle, i, i + 1, i + 2 });
    }
    std.debug.print("End\n", .{});
}
