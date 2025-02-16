const rl = @import("raylib");

const KeyboardKey = @import("raylib").KeyboardKey;

const PointOfInterest = [6][2]f32{
    [2]f32{ -0.348827, 0.607167 },
    [2]f32{ -0.786268, 0.169728 },
    [2]f32{ -0.8, 0.156 },
    [2]f32{ 0.285, 0.0 },
    [2]f32{ -0.835, -0.2321 },
    [2]f32{ -0.70176, -0.3842 },
};

const ZoomSpeed: f32 = 1.01;
const OffsetSpeedMul: f32 = 2.0;
const StartingZoom: f32 = 0.75;

var currentPoI: [2]f32 = PointOfInterest[2];
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
    rl.setShaderValue(shader, currentPoILocation, &currentPoI, rl.ShaderUniformDataType.vec2);
    rl.setShaderValue(shader, zoomLocation, &zoom, rl.ShaderUniformDataType.float);
    rl.setShaderValue(shader, offSetLocation, &offSet, rl.ShaderUniformDataType.vec2);
}

// Press [1 - 6] to reset c to a point of interest
pub fn updatePoI(shader: rl.Shader) void {
    if (rl.isKeyPressed(KeyboardKey.one) or
        rl.isKeyPressed(KeyboardKey.two) or
        rl.isKeyPressed(KeyboardKey.three) or
        rl.isKeyPressed(KeyboardKey.four) or
        rl.isKeyPressed(KeyboardKey.five) or
        rl.isKeyPressed(KeyboardKey.six))
    {
        switch (rl.getKeyPressed()) {
            KeyboardKey.one => currentPoI = PointOfInterest[0],
            KeyboardKey.two => currentPoI = PointOfInterest[1],
            KeyboardKey.three => currentPoI = PointOfInterest[2],
            KeyboardKey.four => currentPoI = PointOfInterest[3],
            KeyboardKey.five => currentPoI = PointOfInterest[4],
            KeyboardKey.six => currentPoI = PointOfInterest[5],
            else => {},
        }

        rl.setShaderValue(shader, currentPoILocation, &currentPoI, rl.ShaderUniformDataType.vec2);
    }
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

// Increment c value with time
pub fn updateCurrentPoI(shader: rl.Shader) void {
    const dc: f32 = rl.getFrameTime() * @as(f32, @floatFromInt(incrementSpeed)) * 0.0005;

    currentPoI[0] += dc;
    currentPoI[1] += dc;

    rl.setShaderValue(shader, currentPoILocation, &currentPoI, rl.ShaderUniformDataType.vec2);
}

// Draw Controls
pub fn drawControls() void {
    if (showControls) {
        rl.drawText("Press Mouse buttons right/left to zoom in/out and move", 10, 15, 10, rl.Color.ray_white);
        rl.drawText("Press KEY_F1 to toggle these controls", 10, 30, 10, rl.Color.ray_white);
        rl.drawText("Press KEYS [1 - 6] to change point of interest", 10, 45, 10, rl.Color.ray_white);
        rl.drawText("Press KEY_LEFT | KEY_RIGHT to change speed", 10, 60, 10, rl.Color.ray_white);
        rl.drawText("Press KEY_SPACE to stop movement animation", 10, 75, 10, rl.Color.ray_white);
        rl.drawText("Press KEY_R to recenter the camera", 10, 90, 10, rl.Color.ray_white);
    }
}
