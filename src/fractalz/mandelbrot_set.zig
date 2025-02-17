const rl = @import("raylib");
const KeyboardKey = @import("raylib").KeyboardKey;

const ZoomSpeed: f32 = 1.01;
const OffsetSpeedMul: f32 = 2.0;
const StartingZoom: f32 = 0.3;

var offSet: [2]f32 = [2]f32{ 0.0, 0.0 };
var zoom = StartingZoom;

var currentPoILocation: i32 = 0;
var zoomLocation: i32 = 0;
var offSetLocation: i32 = 0;

var incrementSpeed: i32 = 0;
var showControls: bool = true;

// Get variable (uniform) locations on the shader to connect with the program
// NOTE: If uniform variable could not be found in the shader, function returns -1
pub fn getLocations(shader: rl.Shader) void {
    currentPoILocation = rl.getShaderLocation(shader, "c");
    zoomLocation = rl.getShaderLocation(shader, "zoom");
    offSetLocation = rl.getShaderLocation(shader, "offset");
}

// Upload the shader uniform values!
pub fn setValues(shader: rl.Shader) void {
    rl.setShaderValue(shader, zoomLocation, &zoom, rl.ShaderUniformDataType.float);
    rl.setShaderValue(shader, offSetLocation, &offSet, rl.ShaderUniformDataType.vec2);
}

// If "R" is pressed, reset zoom and offset.
pub fn updateResetZoomOffset(shader: rl.Shader) void {
    if (rl.isKeyPressed(KeyboardKey.r)) {
        zoom = StartingZoom;
        offSet = [2]f32{ 0.0, 0.0 };

        rl.setShaderValue(shader, zoomLocation, &zoom, rl.ShaderUniformDataType.float);
        rl.setShaderValue(shader, offSetLocation, &offSet, rl.ShaderUniformDataType.vec2);
    }
}

// Pause animation (c change)
pub fn updatePause() void {
    if (rl.isKeyPressed(KeyboardKey.space)) {
        incrementSpeed = 0;
    }
}

// Toggle whether or not to show controls
pub fn updateControlDiplayState() void {
    if (rl.isKeyPressed(KeyboardKey.f1)) {
        showControls = !showControls;
    }
}

// Increment speed control
pub fn updateIncrementSpeed() void {
    if (rl.isKeyPressed(KeyboardKey.right) or rl.isKeyPressed(KeyboardKey.left)) {
        switch (rl.getKeyPressed()) {
            KeyboardKey.right => incrementSpeed += 1,
            KeyboardKey.left => incrementSpeed -= 1,
            else => {},
        }
    }
}

// Zoom Controls
pub fn updateZoom(shader: rl.Shader, width: i32, height: i32) void {
    if (rl.isMouseButtonDown(rl.MouseButton.left) or rl.isMouseButtonDown(rl.MouseButton.right)) {
        zoom *= if (rl.isMouseButtonDown(rl.MouseButton.left)) ZoomSpeed else (1.0 / ZoomSpeed);

        const mousePos: rl.Vector2 = rl.getMousePosition();
        var offsetVelocity: rl.Vector2 = rl.Vector2.init(0, 0);

        offsetVelocity.x = (mousePos.x / @as(f32, @floatFromInt(width)) - 0.5) * OffsetSpeedMul / zoom;
        offsetVelocity.y = (mousePos.y / @as(f32, @floatFromInt(height)) - 0.5) * OffsetSpeedMul / zoom;

        offSet[0] += rl.getFrameTime() * offsetVelocity.x;
        offSet[1] += rl.getFrameTime() * offsetVelocity.y;

        rl.setShaderValue(shader, zoomLocation, &zoom, rl.ShaderUniformDataType.float);
        rl.setShaderValue(shader, offSetLocation, &offSet, rl.ShaderUniformDataType.vec2);
    }
}

// Draw Controls
pub fn drawControls() void {
    if (showControls) {
        rl.drawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, rl.Color.ray_white);
        rl.drawText("Press KEY_F1 to toggle these controls", 10, 30, 10, rl.Color.ray_white);
        rl.drawText("Press KEY_R to recenter the camera", 10, 45, 10, rl.Color.ray_white);
    }
}

// The Final Run for Mandelbrot Set
pub fn run() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 1000;
    const screenHeight = 1000;

    // Window Context setup
    rl.initWindow(screenWidth, screenHeight, "Fractal-Maggot");
    defer rl.closeWindow();

    // Shader setup
    const fragementShader = "resources/mandelbrot_set.frag.glsl";
    const shader: rl.Shader = try rl.loadShader(null, fragementShader);
    defer rl.unloadShader(shader);

    // Texture Setup
    const target: rl.RenderTexture2D = try rl.loadRenderTexture(screenWidth, screenHeight);
    defer rl.unloadRenderTexture(target);

    // Get shader locations
    getLocations(shader);

    // Set shader uniform values
    setValues(shader);

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key
        // Update
        //----------------------------------------------------------------------------------
        updateResetZoomOffset(shader);

        updatePause();

        updateControlDiplayState();

        updateIncrementSpeed();

        updateZoom(shader, screenWidth, screenHeight);
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

            drawControls();
        }
        //----------------------------------------------------------------------------------
    }
}
