local Fighter = {}
Fighter.__index = Fighter

local Actions = {
	IDLE = 1,
	RUN = 2,
	JUMP = 3,
	ATTACK1 = 4,
	ATTACK2 = 5,
	HIT = 6,
	DEATH = 7,
}

local AttackType = {
	NONE = 0,
	ATTACK1 = 1,
	ATTACK2 = 2,
}

local HitBoxType = {
	ATTACK1 = 1,
	ATTACK2 = 2,
	HURT = 3
}

PLAYER_SPEED = 300
PLAYER_GRAVITY = 3000

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
	self.hitbox_config = data.hitbox_config or {}
	self.active_hitboxes = {}
	self.current_target = nil
	self.invulnerable_timer = 0.0
	self.invulnerability_duration = 0.5

	self.animations = Fighter.load_animations(self)
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
	self.attack_box = nil
	self.hurtbox = data.hitbox_config[HitBoxType.HURT]
	self.hurtbox.active = true

	return self
end

function Fighter.load_animations(self)
	local animations = {}
	local sw = self.sprite_sheet:getWidth()
	local sh = self.sprite_sheet:getHeight()

	for row, frames in ipairs(self.steps) do
		animations[row] = {}
		for i = 0, frames - 1 do
			local quad = love.graphics.newQuad(i * self.size, (row - 1) * self.size, self.size, self.size, sw, sh)
			table.insert(animations[row], quad)
		end
	end
	return animations
end

function Fighter:move(screen_width, screen_height, target, round_over)
	local dt = love.timer.getDelta()
	local dx, dy = 0, 0

	self.running = false
	self.attack_type = AttackType.NONE

	local JOY_LEFT = Input.isDown(self.player, BTN_LEFT)
	local JOY_RIGHT = Input.isDown(self.player, BTN_RIGHT)
	local JOY_UP = Input.isDown(self.player, BTN_UP)
	local DO_ATTACK1 = Input.once(self.player, BTN_B)
	local DO_ATTACK2 = Input.once(self.player, BTN_Y)
	local DO_SELECT = Input.once(self.player, BTN_SELECT)

	if DO_SELECT then
		SHOW_HITBOX_HURTBOX_VISUALS = not SHOW_HITBOX_HURTBOX_VISUALS
	end

	if self.alive and not self.attacking and not round_over then
		local move_dir = JOY_LEFT and -1 or JOY_RIGHT and 1 or 0
		if move_dir ~= 0 then
			dx = PLAYER_SPEED * move_dir
			self.running = true
		end

		if JOY_UP and not self.jump then
			self.vel_y = -900
			self.jump = true
		end

		local attack = DO_ATTACK1 and AttackType.ATTACK1 or DO_ATTACK2 and AttackType.ATTACK2 or AttackType.NONE
		if attack ~= AttackType.NONE then
			self:attack(target)
			self.attack_type = attack
		end
	end

	self.vel_y = self.vel_y + PLAYER_GRAVITY * dt
	dy = self.vel_y * dt

	local future_x = self.rect.x + dx * dt
	if future_x < 0 then
		dx = -self.rect.x / dt
	elseif future_x + self.rect.w > screen_width then
		dx = (screen_width - self.rect.x - self.rect.w) / dt
	end

	local ground_y = -35
	local future_y = self.rect.y + self.rect.h + dy
	if future_y > screen_height - ground_y then
		self.vel_y = 0
		self.jump = false
		dy = screen_height - ground_y - self.rect.y - self.rect.h
	end

	self.flip = target.rect.x <= self.rect.x

	if self.attack_cooldown > 0 then
		self.attack_cooldown = self.attack_cooldown - 1
	end

	self.rect.x = self.rect.x + dx * dt
	self.rect.y = self.rect.y + dy
end

local action_map = {
	[AttackType.ATTACK1] = Actions.ATTACK1,
	[AttackType.ATTACK2] = Actions.ATTACK2,
}

function Fighter:update()
	self.active_hitboxes = {}
	local dt = love.timer.getDelta()

	if self.invulnerable_timer > 0 then
		self.invulnerable_timer = self.invulnerable_timer - dt
		if self.invulnerable_timer <= 0 and self.alive and self.action ~= Actions.HIT then
			self.hurtbox.active = true
		end
	end

	if self.health <= 0 then
		self.alive = false
		self:update_action(Actions.DEATH)
	elseif self.hit then
		self:update_action(Actions.HIT)
	elseif self.attacking then
		local action = action_map[self.attack_type]
		if action then self:update_action(action) end
	elseif self.jump then
		self:update_action(Actions.JUMP)
	elseif self.running then
		self:update_action(Actions.RUN)
	else
		self:update_action(Actions.IDLE)
	end

	self.frame_timer = self.frame_timer + dt
	if self.frame_timer <= 0.05 then return end
	self.frame_timer = 0
	self.frame_index = self.frame_index + 1

	local current_animation = self.animations[self.action]
	if self.frame_index > #current_animation then
		if not self.alive then
			self.frame_index = #current_animation
			return
		end
		self.frame_index = 1
		if self.action == Actions.ATTACK1 or self.action == Actions.ATTACK2 then
			self.attacking = false
			self.attack_cooldown = 20
			self.current_target = nil
			self.active_hitboxes = {}
		elseif self.action == Actions.HIT then
			self.hit = false
			self.attacking = false
			self.attack_cooldown = 20
			self.current_target = nil
			self.active_hitboxes = {}
			if self.invulnerable_timer <= 0 then
				self.hurtbox.active = true
			end
		end
	end

	if self.attacking and self.hitbox_config[self.action] then
		for _, hitbox_def in ipairs(self.hitbox_config[self.action]) do
			if hitbox_def.frame == self.frame_index then
				local actual_x = self.flip and self.rect.x + (self.rect.w - hitbox_def.x_offset - hitbox_def.w)
					or self.rect.x + hitbox_def.x_offset
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
				if self:check_collision(hitbox_rect, target_hurtbox_rect) then
					self.current_target.health = self.current_target.health - 10
					self.current_target.hit = true
					self.current_target.invulnerable_timer = self.current_target.invulnerability_duration
					self.current_target.hurtbox.active = false
					break
				end
			end
		end
	end
end

function Fighter:attack(target)
	if self.attack_cooldown <= 0 then
		self.attacking = true
		self.attack_sound:play()
		self.current_target = target
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
	local qx, qy, qw, qh = quad:getViewport()
	local x = (self.rect.x - self.offset[1])
	local y = (self.rect.y - self.offset[2])
	local r = 0
	local sx = (self.flip and -1 or 1)
	local sy = 1
	local ox = qw / 2
	local oy = qh / 2

	if DEBUG then
		local w = (self.size / self.scale) + 4
		local h = (self.size / self.scale) + 4
		love.graphics.rectangle('line', x - w/2, y - h/2, w, h)
	end

	if SHOW_HITBOX_HURTBOX_VISUALS then
		if self.alive then
			local actual_hurtbox_x = self.rect.x + self.hurtbox.offset_x
			local actual_hurtbox_y = self.rect.y + self.hurtbox.offset_y
			love.graphics.setColor(self.hurtbox.active and {0,0,255,255} or {128,128,128,200})
			love.graphics.rectangle('line', actual_hurtbox_x, actual_hurtbox_y, self.hurtbox.w, self.hurtbox.h)
		end

		for _, hbox in ipairs(self.active_hitboxes) do
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.rectangle('line', hbox.x, hbox.y, hbox.w, hbox.h)
		end
		love.graphics.setColor(255, 255, 255, 255)
	end

	if isLutro() then
		ox, oy = 1, 1
		local xx_lutro_adjust = self.player == 2 and 120 or 80
		local yy_lutro_adjust = self.player == 2 and 126 or 80
		x = x - xx_lutro_adjust
		y = y - yy_lutro_adjust
	end

	love.graphics.draw(self.sprite_sheet, quad, x, y, r, sx, sy, ox, oy)
end

function Fighter:check_collision(a, b)
	return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

return { Fighter = Fighter, Actions = Actions, HitBoxType = HitBoxType }