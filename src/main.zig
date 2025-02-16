const std = @import("std");
const rl = @import("raylib");

// const Ball = @import("ballz/ballz.zig").Ball;

const julia = @import("fractalz/julia_set.zig");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1920;
    const screenHeight = 1080;

    // Window Context setup
    rl.initWindow(screenWidth, screenHeight, "Fractal-Maggot");
    rl.toggleFullscreen();
    defer rl.closeWindow();

    // Shader setup
    const fragementShader = "resources/julia_set.frag.glsl";
    const shader: rl.Shader = try rl.loadShader(null, fragementShader);
    defer rl.unloadShader(shader);

    // Texture Setup
    const target: rl.RenderTexture2D = try rl.loadRenderTexture(screenWidth, screenHeight);
    defer rl.unloadRenderTexture(target);

    // Get shader locations
    julia.getLocations(shader);

    // Set shader uniform values
    julia.setValues(shader);

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        julia.updateCurrentPoI(shader);

        julia.updateResetZoomOffset(shader);

        julia.updatePause();

        julia.updateControlDiplayState();

        julia.updateIncrementSpeed();

        julia.updateZoom(shader, screenWidth, screenHeight);

        julia.updateCurrentPoI(shader);
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

                rl.drawTextureEx(target.texture, rl.Vector2{ .x = 0.0, .y = 0.0 }, 0.0, 1.0, rl.Color.white);
            }

            julia.drawControls();
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
