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
		DEBUG = not DEBUG
	end

	-- Process movement and actions if fighter is active
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

		local attack = DO_ATTACK1 and 1 or DO_ATTACK2 and 2 or 0
		if attack ~= AttackType.NONE then
			self:attack(target)
			self.attack_type = attack
		end
	end

	-- Apply gravity
	self.vel_y = self.vel_y + PLAYER_GRAVITY * dt
	dy = self.vel_y * dt

	-- Horizontal bounds check
	local future_x = self.rect.x + dx * dt
	if future_x < 0 then
		dx = -self.rect.x / dt
	elseif future_x + self.rect.w > screen_width then
		dx = (screen_width - self.rect.x - self.rect.w) / dt
	end

	-- Vertical ground collision
	local ground_y = -35
	local future_y = self.rect.y + self.rect.h + dy
	if future_y > screen_height - ground_y then
		self.vel_y = 0
		self.jump = false
		dy = screen_height - ground_y - self.rect.y - self.rect.h
	end

	-- Flip sprite based on target position
	self.flip = target.rect.x <= self.rect.x

	-- Decrease attack cooldown if active
	if self.attack_cooldown > 0 then
		self.attack_cooldown = self.attack_cooldown - 1
	end

	-- Apply movement
	self.rect.x = self.rect.x + dx * dt
	self.rect.y = self.rect.y + dy
end

local action_map = {
	[AttackType.ATTACK1] = Actions.ATTACK1,
	[AttackType.ATTACK2] = Actions.ATTACK2,
}

function Fighter:update()
	-- Update action based on state
	if self.health <= 0 then
		self.alive = false
		self:update_action(Actions.DEATH)
	elseif self.hit then
		self:update_action(Actions.HIT)
	elseif self.attacking then
		local action = action_map[self.attack_type]
		if action then
			self:update_action(action)
		end
	elseif self.jump then
		self:update_action(Actions.JUMP)
	elseif self.running then
		self:update_action(Actions.RUN)
	else
		self:update_action(Actions.IDLE)
	end

	-- Advance animation frame
	self.frame_timer = self.frame_timer + love.timer.getDelta()
	if self.frame_timer <= 0.05 then
		return
	end
	self.frame_timer = 0
	self.frame_index = self.frame_index + 1

	local current_animation = self.animations[self.action]
	if self.frame_index > #current_animation then
		if not self.alive then
			self.frame_index = #current_animation -- Freeze on last death frame
			return
		end

		self.frame_index = 1

		-- Reset states after animation completes
		if self.action == Actions.ATTACK1 or self.action == Actions.ATTACK2 then
			self.attacking = false
			self.attack_cooldown = 20
			self.attack_box = nil
		elseif self.action == Actions.HIT then
			self.hit = false
			self.attacking = false
			self.attack_cooldown = 20
			self.attack_box = nil
		end
	end
end

function Fighter:attack(target)
	if self.attack_cooldown <= 0 then
		self.attacking = true
		self.attack_sound:play()
		local attack_range = {
			--			x = self.rect.x - (2 * self.rect.w * (self.flip and 1 or -1)),
			x = self.rect.x,
			y = self.rect.y,
			--			w = 2 * self.rect.w,
			w = self.rect.w,
			h = self.rect.h,
		}
		self.attack_box = attack_range

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
	-- local x = (self.rect.x - self.offset[1] * self.scale)
	-- local y = (self.rect.y - self.offset[2] * self.scale)
	-- local sx = self.scale * (self.flip and -1 or 1)
	-- local sy = self.scale
	-- local ox = self.flip and self.size or 0
	-- local oy = 0
	-- print('quad', quad, 'x', x, 'y', y, 'sx', sx, 'sy', sy, 'ox', ox, 'oy', oy)
	-- love.graphics.draw(self.sprite_sheet, quad, x, y, r, sx, sy, ox, oy)

	local qx, qy, qw, qh = quad:getViewport()

	local x = (self.rect.x - self.offset[1])
	local y = (self.rect.y - self.offset[2])
	local r = 0
	local sx = (self.flip and -1 or 1)
	local sy = 1
	local ox = qw / 2
	local oy = qh / 2

	if DEBUG then
		w = (self.size / self.scale) + 4
		h = (self.size / self.scale) + 4
		w2 = (w / 2)
		h2 = (h / 2)
		love.graphics.rectangle('line', x - w2, y - h2, w, h)

		if self.attack_box then
			love.graphics.rectangle('line', self.attack_box.x, self.attack_box.y, self.attack_box.w, self.attack_box.h)
		end
	end

	-- TODO: This should behave the same as in LÖVE2D
	if isLutro() then
		ox, oy = 1, 1
		local xx = self.player == 2 and 120 or 80
		local yy = self.player == 2 and 126 or 80
		x = x - xx
		y = y - yy
	end
	love.graphics.draw(self.sprite_sheet, quad, x, y, r, sx, sy, ox, oy)
end

function Fighter:check_collision(a, b)
	return a.x < b.x + b.w and a.x + a.w > b.x and a.y < b.y + b.h and a.y + a.h > b.y
end

return Fighter
