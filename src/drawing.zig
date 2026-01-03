const std = @import("std");
const rl = @import("raylib");
const tools = @import("tools.zig");

const targetFPS = 120;

pub const CommandType = enum { circle, arc, line };

pub const Command = union(CommandType) {
    circle: struct {
        position: rl.Vector2,
        radius: f32,
        angle: f32,
    },
    arc: struct {
        position: rl.Vector2,
        radius: f32,
        angle: f32,
    },
    line: struct {
        point1: rl.Vector2,
        point2: rl.Vector2,
    },

    pub fn draw(command: *const Command) void {
        switch (command.*) {
            .arc => |arc| {
                rl.drawCircleSectorLines(arc.position, arc.radius, arc.angle * (180.0 / std.math.pi) - 90.0, arc.angle * (180.0 / std.math.pi) + 90.0, 20, rl.Color.red);
            },
            .circle => |circle| {
                rl.drawCircleLinesV(circle.position, circle.radius, rl.Color.red);
            },
            .line => |line| {
                rl.drawLineV(line.point1, line.point2, rl.Color.red);
            },
        }
    }
};

pub const Circle = struct {
    radius: f32,
    position: rl.Vector2,
    angle: f32,

    pub fn deplaceCircleInDirectionOfMouse(c: *Circle) void {
        deplaceCircleInDirectionOfPoint(c, rl.getMousePosition());
    }

    pub fn deplaceCircleInDirectionOfPoint(circle: *Circle, target: rl.Vector2) void {
        const distanceConstraint = circle.radius;
        const distance = rl.Vector2.distance(circle.position, target);
        if (distance >= distanceConstraint - 5 and distance <= distanceConstraint + 5) return;

        const directionVector = if (distance > distanceConstraint)
            tools.computeDirectionVector(circle.position, target)
        else
            tools.computeDirectionVector(target, circle.position);

        updateCirclePosition(circle, directionVector, tools.computeFrameSpeed());
        updateCircleAngle(circle, target);
    }

    pub fn updateCirclePosition(circle: *Circle, directionVector: rl.Vector2, speed: f32) void {
        circle.position = rl.Vector2.add(circle.position, rl.Vector2.scale(directionVector, speed));
    }

    pub fn updateCircleAngle(circle: *Circle, target: rl.Vector2) void {
        circle.angle = std.math.atan2(target.y - circle.position.y, target.x - circle.position.x);
    }
};

pub fn drawCommands(commands: []const Command) void {
    for (commands) |command| command.draw();
}

pub fn initWindow(screenWidth: u16, screenHeight: u16) void {
    rl.setTargetFPS(targetFPS);
    rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });

    rl.initWindow(screenWidth, screenHeight, "ProceduralAnimation");
}
pub fn closeWindow() void {
    rl.closeWindow();
}

pub fn windowShouldClose() bool {
    return rl.windowShouldClose();
}

pub fn beginDrawing() void {
    rl.beginDrawing();
}
pub fn endDrawing() void {
    rl.endDrawing();
}
pub fn clearBackground() void {
    rl.clearBackground(rl.Color.black);
}
pub fn drawFPS() void {
    rl.drawFPS(10, 10);
}
