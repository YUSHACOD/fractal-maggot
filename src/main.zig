const std = @import("std");
const rl = @import("raylib");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1920;
    const screenHeight = 1080;
    const lowerBound: i32 = 0;

    var ballPosX: i32 = 50;
    var directionX: i32 = 1;
    var ballPosY: i32 = 50;
    var directionY: i32 = 1;
    const speed: i32 = 2;

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
        if (((ballPosX - 50) < lowerBound) or ((ballPosX + 50) > screenWidth)) {
            directionX = -directionX;
        }
        if (((ballPosY - 50) < lowerBound) or ((ballPosY + 50) > screenHeight)) {
            directionY = -directionY;
        }
        ballPosX += directionX * speed;
        ballPosY += directionY * speed;
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

            rl.drawCircleGradient(ballPosX, ballPosY, 50.0, rl.Color.blue, rl.Color.sky_blue);
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
