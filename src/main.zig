const std = @import("std");
const Snake = @import("snake.zig");
const drawing = @import("drawing.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const screenWidth = 1000;
    const screenHeight = 900;
    var snake = Snake.init();

    drawing.initWindow(screenWidth, screenHeight);

    defer drawing.closeWindow();

    while (!drawing.windowShouldClose()) {
        drawing.beginDrawing();
        defer drawing.endDrawing();

        drawing.clearBackground();
        drawing.drawFPS();

        snake.move();
        const commands = try snake.generateCommand(allocator);
        defer allocator.free(commands);
        drawing.drawCommands(commands);
    }
}
