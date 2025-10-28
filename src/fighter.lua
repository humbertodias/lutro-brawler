
Actions = {
	IDLE = 1, RUN = 2, JUMP = 3, ATTACK1 = 4, ATTACK2 = 5, HIT = 6, DEATH = 7,
}

AttackType = {
	NONE = 0, ATTACK1 = 1, ATTACK2 = 2,
}

HitBoxType = {
	ATTACK1 = 1, ATTACK2 = 2, HURT = 3
}

PLAYER_SPEED = 300
PLAYER_GRAVITY = 3000

Fighter = process(function(self, player, x, y, flip, data, sprite_sheet, attack_sound, target)
    self.player = player
    self.size = data.size
    self.scale = data.scale
    self.offset = data.offset
    self.steps = data.steps
    self.sprite_sheet = sprite_sheet
    self.attack_sound = attack_sound
    self.flip = flip
    self.hitbox_config = data.hitbox_config or {}
    self.active_hitboxes = {}
    self.current_target = target
    self.invulnerable_timer = 0.0
    self.invulnerability_duration = 0.5

    local function load_animations()
        local animations = {}
        local sw, sh = self.sprite_sheet:getWidth(), self.sprite_sheet:getHeight()
        for row, frames in ipairs(self.steps) do
            animations[row] = {}
            for i = 0, frames - 1 do
                table.insert(animations[row], love.graphics.newQuad(i * self.size, (row - 1) * self.size, self.size, self.size, sw, sh))
            end
        end
        return animations
    end
    self.animations = load_animations()

    self.action = Actions.IDLE
    self.frame_index = 1
    self.frame_timer = 0
    self.image = self.animations[self.action][self.frame_index]

    self.rect = { x = x, y = y, w = 80, h = 180 }
    self.vel_y = 0
    self.running = false
    self.jump = false
    self.attacking = false
    self.attack_type = AttackType.NONE
    self.attack_cooldown = 0
    self.hit = false
    self.health = 100
    self.alive = true
    self.hurtbox = data.hitbox_config[HitBoxType.HURT]
    self.hurtbox.active = true

    local function check_collision(a, b)
        return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
    end

    while self.alive do
        local dt = self.delta

        local JOY_LEFT = Input.isDown(self.player, BTN_LEFT)
        local JOY_RIGHT = Input.isDown(self.player, BTN_RIGHT)
        local JOY_UP = Input.isDown(self.player, BTN_UP)
        local DO_ATTACK1 = Input.once(self.player, BTN_B)
        local DO_ATTACK2 = Input.once(self.player, BTN_Y)

        local dx, dy = 0, 0
        self.running = false
        self.attack_type = AttackType.NONE

        if self.alive and not self.attacking then
            local move_dir = (JOY_LEFT and -1) or (JOY_RIGHT and 1) or 0
            if move_dir ~= 0 then
                dx = PLAYER_SPEED * move_dir
                self.running = true
            end

            if JOY_UP and not self.jump then
                self.vel_y = -900
                self.jump = true
            end

            if DO_ATTACK1 then self.attack_type = AttackType.ATTACK1 end
            if DO_ATTACK2 then self.attack_type = AttackType.ATTACK2 end

            if self.attack_type ~= AttackType.NONE and self.attack_cooldown <= 0 then
                self.attacking = true
                self.attack_sound:play()
            end
        end

        self.vel_y = self.vel_y + PLAYER_GRAVITY * dt
        dy = self.vel_y * dt

        if self.rect.x + dx * dt < 0 then dx = -self.rect.x / dt end
        if self.rect.x + self.rect.w + dx * dt > SCREEN_WIDTH then dx = (SCREEN_WIDTH - self.rect.x - self.rect.w) / dt end

        if self.rect.y + self.rect.h + dy > SCREEN_HEIGHT - 35 then
            self.vel_y = 0; self.jump = false
            dy = SCREEN_HEIGHT - 35 - self.rect.y - self.rect.h
        end

        self.rect.x = self.rect.x + dx * dt
        self.rect.y = self.rect.y + dy
        self.flip = self.current_target.rect.x <= self.rect.x
        if self.attack_cooldown > 0 then self.attack_cooldown = self.attack_cooldown - 1 end

        local new_action = Actions.IDLE
        if self.health <= 0 then new_action = Actions.DEATH; self.alive = false
        elseif self.hit then new_action = Actions.HIT
        elseif self.attacking then new_action = (self.attack_type == AttackType.ATTACK1 and Actions.ATTACK1) or Actions.ATTACK2
        elseif self.jump then new_action = Actions.JUMP
        elseif self.running then new_action = Actions.RUN
        end
        if new_action ~= self.action then self.action = new_action; self.frame_index = 1 end

        self.frame_timer = self.frame_timer + dt
        if self.frame_timer > 0.05 then
            self.frame_timer = 0
            self.frame_index = self.frame_index + 1
            local current_animation = self.animations[self.action]
            if self.frame_index > #current_animation then
                self.frame_index = 1
                if self.action == Actions.DEATH then self.frame_index = #current_animation end
                if self.action == Actions.ATTACK1 or self.action == Actions.ATTACK2 or self.action == Actions.HIT then
                    self.attacking, self.hit = false, false
                    self.attack_cooldown = 20
                end
            end
        end

        if self.attacking and self.hitbox_config[self.action] then
            for _, hitbox_def in ipairs(self.hitbox_config[self.action]) do
                if hitbox_def.frame == self.frame_index then
                    local actual_x = self.flip and self.rect.x + (self.rect.w - hitbox_def.x_offset - hitbox_def.w) or self.rect.x + hitbox_def.x_offset
                    local actual_y = self.rect.y + hitbox_def.y_offset
                    table.insert(self.active_hitboxes, { x = actual_x, y = actual_y, w = hitbox_def.w, h = hitbox_def.h })
                end
            end
        end

        if self.attacking and self.current_target and #self.active_hitboxes > 0 then
            local target_hurtbox_rect = {
                x = self.current_target.rect.x + self.current_target.hurtbox.offset_x,
                y = self.current_target.rect.y + self.current_target.hurtbox.offset_y,
                w = self.current_target.hurtbox.w,
                h = self.current_target.hurtbox.h,
            }

            if self.current_target.hurtbox.active then
                for _, hitbox_rect in ipairs(self.active_hitboxes) do
                    if check_collision(hitbox_rect, target_hurtbox_rect) then
                        self.current_target.health = self.current_target.health - 10
                        self.current_target.hit = true
                        self.current_target.invulnerable_timer = self.current_target.invulnerability_duration
                        self.current_target.hurtbox.active = false
                        break
                    end
                end
            end
        end

        local quad = self.animations[self.action][self.frame_index]
        local x, y = self.rect.x - self.offset[1], self.rect.y - self.offset[2]
        local sx = self.flip and -1 or 1
        love.graphics.draw(self.sprite_sheet, quad, x, y, 0, sx, 1, self.size/2, self.size/2)

        frame()
    end
end)
