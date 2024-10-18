const std = @import("std");
const rl = @import("raylib");

pub fn main() !void {
    const screenWidth = 800;
    const screenHeight = 450;
    var circlePosition: rl.Vector2 = .{ .x = 400, .y = 225 };

    rl.setTargetFPS(60);
    rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });

    rl.initWindow(screenWidth, screenHeight, "ProceduralAnimation");
    defer rl.closeWindow();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        rl.clearBackground(rl.Color.white);
        rl.drawFPS(10, 10);
        drawCircle(circlePosition.*);
        deplaceCircleInDirectionOfMouse(&circlePosition);
        rl.endDrawing();
    }
}

pub fn drawCircle(circlePosition: rl.Vector2) void {
    rl.drawCircleLinesV(circlePosition, 30, rl.Color.red);
}

pub fn deplaceCircleInDirectionOfMouse(circlePosition: *rl.Vector2) void {
    const mousePosition = rl.getMousePosition();

    if (distanceBetween(circlePosition.*, mousePosition) < 5)
        return;

    const directionVector = computeDirectionVector(circlePosition.*, mousePosition);
    updateCirclePosition(circlePosition, directionVector);
}

pub fn computeDirectionVector(pointA: rl.Vector2, pointB: rl.Vector2) rl.Vector2 {
    const displacementVector = .{ .x = pointB.x - pointA.x, .y = pointB.y - pointA.y };
    const magnitudeDeplacementVector = absoluteValue(displacementVector.x) + absoluteValue(displacementVector.y);

    return .{ .x = displacementVector.x / magnitudeDeplacementVector, .y = displacementVector.y / magnitudeDeplacementVector };
}

pub fn absoluteValue(number: f32) f32 {
    return if (number < 0) number * -1 else number;
}

pub fn distanceBetween(pointA: rl.Vector2, pointB: rl.Vector2) f32 {
    return absoluteValue(pointB.x - pointA.x) + absoluteValue(pointB.y - pointA.y);
}

pub fn updateCirclePosition(circlePosition: *rl.Vector2, directionVector: rl.Vector2) void {
    const speed = 5;

    circlePosition.x += directionVector.x * speed;
    circlePosition.y += directionVector.y * speed;
}
