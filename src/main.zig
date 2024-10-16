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
        rl.drawCircleLinesV(circlePosition, 30, rl.Color.red);
        rl.drawFPS(10, 10);
        updateCirclePosition(&circlePosition);
        rl.endDrawing();
    }
}

pub fn updateCirclePosition(circlePosition: *rl.Vector2) void {
    const mousePosition = rl.getMousePosition();
    const directionVector = computeDirection(circlePosition.*, mousePosition);
    const speed = 5;
    circlePosition.x += directionVector.x * speed;
    circlePosition.y += directionVector.y * speed;
}

pub fn computeDirection(pointA: rl.Vector2, pointB: rl.Vector2) rl.Vector2 {
    const displacementVector = .{ .x = pointB.x - pointA.x, .y = pointB.y - pointA.y };
    const magnitudeDeplacementVector = absoluteValue(displacementVector.x) + absoluteValue(displacementVector.y);

    return .{ .x = displacementVector.x / magnitudeDeplacementVector, .y = displacementVector.y / magnitudeDeplacementVector };
}

pub fn absoluteValue(number: f32) f32 {
    return if (number < 0) number * -1 else number;
}
