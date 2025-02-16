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

    pub fn revertX(self: *Ball) void {
        self.directX = -self.directX;
    }

    pub fn revertY(self: *Ball) void {
        self.directY = -self.directY;
    }

    pub fn bounceUpdate(self: *Ball, max_x: i32, max_y: i32) void {
        if (((self.posX - self.radius) < 0) or ((self.posX + self.radius) > max_x)) {
            self.revertX();
        }

        if (((self.posY - self.radius) < 0) or ((self.posY + self.radius) > max_y)) {
            self.revertY();
        }

        self.posX += self.directX * self.speed;
        self.posY += self.directY * self.speed;
    }

    pub fn draw(self: *Ball) void {
        rl.drawCircleGradient(self.posX, self.posY, @floatFromInt(self.radius), rl.Color.red, rl.Color.sky_blue);
    }
};
