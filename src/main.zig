const std = @import("std");
const rl = @import("raylib");

const Circle = struct { position: rl.Vector2, radius: f32 };

pub fn main() !void {
    const allocator = std.heap.c_allocator;
    const screenWidth = 800;
    const screenHeight = 450;
    const circles = try generateCircles(7);
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
        // deplaceCircleInDirectionOfMouse(&headCircle);
        rl.endDrawing();
    }
}

fn generateCircles(number: usize) ![]Circle {
    const allocator = std.heap.c_allocator;
    const x: f32 = 400.0;
    const y: f32 = 225.0;
    const radius: f32 = 25.0;

    const head = try allocator.alloc(Circle, number);
    for (0..number) |i| {
        const distance: f32 = radius * 2.0 * @as(f32, @floatFromInt(i));
        head[i].position = .{ .x = x - distance, .y = y };
        head[i].radius = radius;
    }
    return head;
}

fn drawCircles(circles: []Circle) void {
    for (circles) |circle| {
        drawCircle(circle);
    }
}

fn drawCircle(circle: Circle) void {
    rl.drawCircleLinesV(circle.position, circle.radius, rl.Color.red);
}

fn deplaceCircles(circles: []Circle) void {
    deplaceCircleInDirectionOfMouse(&circles[0]);
    for (1..circles.len) |i| {
        if (distanceBetween(circles[i].position, circles[i - 1].position) <= circles[i].radius * 2)
            return;
        const directionVector = computeDirectionVector(circles[i].position, circles[i - 1].position);
        updateCirclePosition(&circles[i], directionVector);
    }
}

fn deplaceCircleInDirectionOfMouse(circle: *Circle) void {
    const mousePosition = rl.getMousePosition();

    if (distanceBetween(circle.position, mousePosition) <= circle.radius)
        return;

    const directionVector = computeDirectionVector(circle.position, mousePosition);
    updateCirclePosition(circle, directionVector);
}

fn computeDirectionVector(pointA: rl.Vector2, pointB: rl.Vector2) rl.Vector2 {
    const displacementVector = .{ .x = pointB.x - pointA.x, .y = pointB.y - pointA.y };
    const magnitudeDeplacementVector = absoluteValue(displacementVector.x) + absoluteValue(displacementVector.y);

    return .{ .x = displacementVector.x / magnitudeDeplacementVector, .y = displacementVector.y / magnitudeDeplacementVector };
}

fn absoluteValue(number: f32) f32 {
    return if (number < 0) number * -1 else number;
}

fn distanceBetween(pointA: rl.Vector2, pointB: rl.Vector2) f32 {
    return absoluteValue(pointB.x - pointA.x) + absoluteValue(pointB.y - pointA.y);
}

fn updateCirclePosition(circle: *Circle, directionVector: rl.Vector2) void {
    const speed = 5;

    circle.position.x += directionVector.x * speed;
    circle.position.y += directionVector.y * speed;
}
