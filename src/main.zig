const std = @import("std");
const rl = @import("raylib");

const Ball = struct { posX: i32, posY: i32, directX: i32, directY: i32, speed: i32, radius: i32 };

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1920;
    const screenHeight = 1080;
    const lowerBound: i32 = 0;

    var ball: Ball = Ball{ .posX = 50, .posY = 50, .directX = 1, .directY = 1, .speed = 3, .radius = 50 };

    rl.initWindow(screenWidth, screenHeight, "Fractal-Maggot");
    rl.toggleFullscreen();
    defer rl.closeWindow(); // Close window and OpenGL context

    // Shader setup
    // const vertexShader = "resources/do_nothing.vert.glsl";
    const fragementShader = "resources/do_nothing.frag.glsl";
    const shader: rl.Shader = try rl.loadShader(null, fragementShader);
    defer rl.unloadShader(shader);

    // Texture Setup
    const target: rl.RenderTexture2D = try rl.loadRenderTexture(screenWidth, screenHeight);
    defer rl.unloadRenderTexture(target);

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        if (((ball.posX - ball.radius) < lowerBound) or ((ball.posX + ball.radius) > screenWidth)) {
            ball.directX *= -1;
        }
        if (((ball.posY - ball.radius) < lowerBound) or ((ball.posY + ball.radius) > screenHeight)) {
            ball.directY *= -1;
        }
        ball.posX += ball.directX * ball.speed;
        ball.posY += ball.directY * ball.speed;
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        {
            rl.beginTextureMode(target);
            rl.endTextureMode();

            rl.drawRectangle(0, 0, screenWidth, screenHeight, rl.Color.black);
        }
        {
            rl.beginDrawing();
            defer rl.endDrawing();

            {
                rl.beginShaderMode(shader);
                defer rl.endShaderMode();

                rl.drawTextureEx(target.texture, rl.Vector2{ .x = 0.0, .y = 0.0 }, 0.0, 1.0, rl.Color.blank);
            }

            rl.drawCircleGradient(ball.posX, ball.posY, @floatFromInt(ball.radius), rl.Color.red, rl.Color.sky_blue);
        }
        //----------------------------------------------------------------------------------
    }
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
