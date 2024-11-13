const std = @import("std");
const rl = @import("raylib");

const Circle = struct { position: rl.Vector2, radius: f32 };

pub fn main() !void {
    const allocator = std.heap.c_allocator;
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
        rl.clearBackground(rl.Color.blank);
        rl.drawFPS(10, 10);
        drawCircles(circles);
        deplaceCircles(circles);
        fixUnaturalAngles(circles);
        rl.endDrawing();
    }
}

fn createCircles(number: usize, allocator: std.mem.Allocator) ![]Circle {
    var x: f32 = 400.0;
    const y: f32 = 225.0;
    const baseRadius: f32 = 25.0;

    const head = try allocator.alloc(Circle, number);

    for (0..number) |i| {
        const source = @min(@as(f32, @floatFromInt(@mod(i, @divFloor(number, 2)))), 1.0);
        const circleRadius = baseRadius + source * 4.0;
        head[i] = .{ .position = .{ .x = x, .y = y }, .radius = circleRadius };
        x -= circleRadius * 2.0;
    }
    return head;
}

fn drawCircles(circles: []Circle) void {
    for (circles) |circle|
        drawCircle(circle);
}

fn drawCircle(circle: Circle) void {
    rl.drawCircleLinesV(circle.position, circle.radius, rl.Color.red);
}

fn deplaceCircles(circles: []Circle) void {
    deplaceCircleInDirectionOfMouse(&circles[0]);

    for (1..circles.len) |i| {
        const distantConstraint = circles[i].radius + circles[i - 1].radius;
        deplaceCircleInDirectionOfPoint(&circles[i], circles[i - 1].position, distantConstraint);
    }
}

fn deplaceCircleInDirectionOfMouse(circle: *Circle) void {
    const mousePosition = rl.getMousePosition();
    const distance = euclideanDistance(circle.position, mousePosition);
    if (distance <= circle.radius)
        return;

    updateCirclePosition(circle, computeDirectionVector(circle.position, mousePosition), computeSpeed(distance));
}

fn deplaceCircleInDirectionOfPoint(circleToMove: *Circle, targetPosition: rl.Vector2, distanceConstraint: f32) void {
    const distance = euclideanDistance(circleToMove.position, targetPosition);
    if (distance <= distanceConstraint)
        return;

    const directionVector = computeDirectionVector(circleToMove.position, targetPosition);
    const speed = computeSpeed(distance);
    updateCirclePosition(circleToMove, directionVector, speed);
}

fn computeDirectionVector(pointA: rl.Vector2, pointB: rl.Vector2) rl.Vector2 {
    const dx = pointB.x - pointA.x;
    const dy = pointB.y - pointA.y;
    const distance = @sqrt(dx * dx + dy * dy);

    return .{ .x = dx / distance, .y = dy / distance };
}

fn euclideanDistance(pointA: rl.Vector2, pointB: rl.Vector2) f32 {
    const dx = pointB.x - pointA.x;
    const dy = pointB.y - pointA.y;
    return @sqrt(dx * dx + dy * dy);
}

fn computeSpeed(distance: f32) f32 {
    const minSpeed = 1.0;
    const maxSpeed = 8.0;
    const speedFactor = 0.1;
    const speed = @min(distance * speedFactor, maxSpeed);

    return @max(minSpeed, speed);
}

fn updateCirclePosition(circle: *Circle, directionVector: rl.Vector2, speed: f32) void {
    circle.position.x += directionVector.x * speed;
    circle.position.y += directionVector.y * speed;
}

fn fixUnaturalAngles(circles: []Circle) void {
    std.debug.print("Start\n", .{});
    for (0..circles.len - 2) |i| {
        const angle = computeAngle(circles[i].position, circles[i + 1].position, circles[i + 2].position);
        std.debug.print("{d} between {d} {d} {d}\n", .{ angle, i, i + 1, i + 2 });
    }
    std.debug.print("End\n", .{});
}

fn computeAngle(c: rl.Vector2, a: rl.Vector2, b: rl.Vector2) f32 {
    const xu = b.x - a.x;
    const yu = b.y - a.y;
    const xv = c.x - a.x;
    const yv = c.y - a.y;
    const scalarProduct = xu * xv + yu * yv;
    const abDistance = euclideanDistance(a, b);
    const acDistance = euclideanDistance(a, c);

    return std.math.acos(scalarProduct / (abDistance * acDistance));
}
