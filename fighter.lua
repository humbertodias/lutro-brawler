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
	local SPEED = 300
	local GRAVITY = 3000
	local dx, dy = 0, 0

	self.running = false
	self.attack_type = AttackType.NONE

	-- Only allow movement and actions if not attacking and round is not over
	if not self.attacking and self.alive and not round_over then
		local move_dir = Input.getMovement(self.player)
		if move_dir ~= 0 then
			dx = SPEED * move_dir
			self.running = true
		end

		if Input.isJumpPressed(self.player) and not self.jump then
			self.vel_y = -900
			self.jump = true
		end

		local attack = Input.getAttackType(self.player)
		if attack ~= AttackType.NONE then
			self:attack(target)
			self.attack_type = attack
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

	ground_y = -35

	if self.rect.y + self.rect.h + dy > screen_height - ground_y then
		self.vel_y = 0
		self.jump = false
		dy = (screen_height - ground_y - self.rect.y - self.rect.h)
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
		self:update_action(Actions.DEATH)
	elseif self.hit then
		self:update_action(Actions.HIT)
	elseif self.attacking then
		if self.attack_type == AttackType.ATTACK1 then
			self:update_action(Actions.ATTACK1)
		elseif self.attack_type == AttackType.ATTACK2 then
			self:update_action(Actions.ATTACK2)
		end
	elseif self.jump then
		self:update_action(Actions.JUMP)
	elseif self.running then
		self:update_action(Actions.RUN)
	else
		self:update_action(Actions.IDLE)
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
				if self.action == Actions.ATTACK1 or self.action == Actions.ATTACK2 then
					self.attacking = false
					self.attack_cooldown = 20
				elseif self.action == Actions.HIT then
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
		local attack_range = {
--			x = self.rect.x - (2 * self.rect.w * (self.flip and 1 or -1)),
			x = self.rect.x,
			y = self.rect.y,
--			w = 2 * self.rect.w,
			w = self.rect.w,
			h = self.rect.h,
		}

		if DEBUG then
			print('attack_range', attack_range.x, attack_range.y, attack_range.w, attack_range.h)
		end

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
		w = self.size / self.scale
		h = self.size / self.scale
		w2 = w / 2
		h2 = h / 2
		love.graphics.rectangle('line', x - w2, y - h2, w, h)
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
