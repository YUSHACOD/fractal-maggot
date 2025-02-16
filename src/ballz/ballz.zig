const rl = @import("raylib");

pub const Ball = struct {
    posX: i32,
    posY: i32,
    directX: i32,
    directY: i32,
    speed: i32,
    radius: i32,

    pub fn init(x: i32, y: i32, radius: i32, speed: i32) Ball {
        return Ball{ .posX = x, .posY = y, .directX = 1, .directY = 1, .radius = radius, .speed = speed };
    }

    pub fn revertX(ball: *Ball) void {
        ball.directX = -ball.directX;
    }

    pub fn revertY(ball: *Ball) void {
        ball.directY = -ball.directY;
    }

    pub fn bounceUpdate(ball: *Ball, max_x: i32, max_y: i32) void {
        if (((ball.posX - ball.radius) < 0) or ((ball.posX + ball.radius) > max_x)) {
            ball.revertX();
        }

        if (((ball.posY - ball.radius) < 0) or ((ball.posY + ball.radius) > max_y)) {
            ball.revertY();
        }

        ball.posX += ball.directX * ball.speed;
        ball.posY += ball.directY * ball.speed;
    }

    pub fn draw(ball: *Ball) void {
        rl.drawCircleGradient(ball.posX, ball.posY, @floatFromInt(ball.radius), rl.Color.red, rl.Color.sky_blue);
    }
};
