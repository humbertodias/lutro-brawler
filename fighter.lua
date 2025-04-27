local Fighter = {}
Fighter.__index = Fighter

function Fighter.new(player, x, y, flip, data, sprite_sheet, attack_sound)
    local self = setmetatable({}, Fighter)

    self.player = player
    self.size = data.size
    self.scale = data.scale
    self.offset = data.offset
    self.steps = data.steps
    self.sprite_sheet = sprite_sheet
    self.attack_sound = attack_sound
    self.flip = flip

    self.animations = Fighter.load_animations(self)
    self.action = 1
    self.frame_index = 1
    self.frame_timer = 0
    self.image = self.animations[self.action][self.frame_index]
    
    self.rect = {x = x, y = y, w = 80, h = 180}
    self.vel_y = 0
    self.running = false
    self.jump = false
    self.attacking = false
    self.attack_type = 0
    self.attack_cooldown = 0
    self.hit = false
    self.health = 100
    self.alive = true

    return self
end

function Fighter.load_animations(self)
    local animations = {}
    local sw = self.sprite_sheet:getWidth()
    local sh = self.sprite_sheet:getHeight()

    for row, frames in ipairs(self.steps) do
        animations[row] = {}
        for i = 0, frames - 1 do
            local quad = love.graphics.newQuad(
                i * self.size, (row - 1) * self.size,
                self.size, self.size,
                sw, sh
            )
            table.insert(animations[row], quad)
        end
    end
    return animations
end

function Fighter:move(screen_width, screen_height, target, round_over)
    local SPEED = 700
    local GRAVITY = 2000
    local dx, dy = 0, 0

    self.running = false
    self.attack_type = 0

    -- Only allow movement and actions if not attacking and round is not over
    if not self.attacking and self.alive and not round_over then
        if self.player == 1 then
            if love.keyboard.isDown("a") then
                dx = -SPEED
                self.running = true
            elseif love.keyboard.isDown("d") then
                dx = SPEED
                self.running = true
            end
            if love.keyboard.isDown("w") and not self.jump then
                self.vel_y = -900
                self.jump = true
            end
            if love.keyboard.isDown("r") or love.keyboard.isDown("t") then
                self:attack(target)
                if love.keyboard.isDown("r") then
                    self.attack_type = 1
                elseif love.keyboard.isDown("t") then
                    self.attack_type = 2
                end
            end
        elseif self.player == 2 then
            if love.keyboard.isDown("left") then
                dx = -SPEED
                self.running = true
            elseif love.keyboard.isDown("right") then
                dx = SPEED
                self.running = true
            end
            if love.keyboard.isDown("up") and not self.jump then
                self.vel_y = -900
                self.jump = true
            end
            if love.keyboard.isDown("kp1") or love.keyboard.isDown("kp2") then
                self:attack(target)
                if love.keyboard.isDown("kp1") then
                    self.attack_type = 1
                elseif love.keyboard.isDown("kp2") then
                    self.attack_type = 2
                end
            end
        end
    end

    -- Gravity
    self.vel_y = self.vel_y + GRAVITY * love.timer.getDelta()
    dy = self.vel_y * love.timer.getDelta()

    -- Wall bounds
    if self.rect.x + dx * love.timer.getDelta() < 0 then
        dx = -self.rect.x / love.timer.getDelta()
    elseif self.rect.x + self.rect.w + dx * love.timer.getDelta() > screen_width then
        dx = (screen_width - self.rect.x - self.rect.w) / love.timer.getDelta()
    end

    if self.rect.y + self.rect.h + dy > screen_height - 110 then
        self.vel_y = 0
        self.jump = false
        dy = (screen_height - 110 - self.rect.y - self.rect.h)
    end

    if target.rect.x > self.rect.x then
        self.flip = false
    else
        self.flip = true
    end

    if self.attack_cooldown > 0 then
        self.attack_cooldown = self.attack_cooldown - 1
    end

    self.rect.x = self.rect.x + dx * love.timer.getDelta()
    self.rect.y = self.rect.y + dy 
end


function Fighter:update()
    if self.health <= 0 then
        self.alive = false
        self:update_action(7)
    elseif self.hit then
        self:update_action(6)
    elseif self.attacking then
        if self.attack_type == 1 then
            self:update_action(4)
        elseif self.attack_type == 2 then
            self:update_action(5)
        end
    elseif self.jump then
        self:update_action(3)
    elseif self.running then
        self:update_action(2)
    else
        self:update_action(1)
    end

    self.frame_timer = self.frame_timer + love.timer.getDelta()
    if self.frame_timer > 0.05 then
        self.frame_timer = 0
        self.frame_index = self.frame_index + 1
        if self.frame_index > #self.animations[self.action] then
            if not self.alive then
                self.frame_index = #self.animations[self.action]
            else
                self.frame_index = 1
                if self.action == 4 or self.action == 5 then
                    self.attacking = false
                    self.attack_cooldown = 20
                elseif self.action == 6 then
                    self.hit = false
                    self.attacking = false
                    self.attack_cooldown = 20
                end
            end
        end
    end
end

function Fighter:attack(target)
    if self.attack_cooldown <= 0 then
        self.attacking = true
        self.attack_sound:play()
        local attack_range = {x = self.rect.x - (2 * self.rect.w * (self.flip and 1 or -1)), y = self.rect.y, w = 2 * self.rect.w, h = self.rect.h}
        if self:check_collision(attack_range, target.rect) then
            target.health = target.health - 10
            target.hit = true
        end
    end
end

function Fighter:update_action(new_action)
    if new_action ~= self.action then
        self.action = new_action
        self.frame_index = 1
    end
end

function Fighter:draw()
    local quad = self.animations[self.action][self.frame_index]
    local sx = self.scale * (self.flip and -1 or 1)
    local ox = self.flip and self.size or 0
    love.graphics.draw(self.sprite_sheet, quad,
        self.rect.x - self.offset[1] * self.scale,
        self.rect.y - self.offset[2] * self.scale,
        0, sx, self.scale, ox, 0)
end

function Fighter:check_collision(a, b)
    return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

return Fighter
