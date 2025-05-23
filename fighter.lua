-- Defines the Fighter class, responsible for player and enemy character logic,
-- including movement, actions, animations, and combat.
local Fighter = {}
Fighter.__index = Fighter

-- Enumeration for different fighter actions.
local Actions = {
	IDLE = 1,
	RUN = 2,
	JUMP = 3,
	ATTACK1 = 4,
	ATTACK2 = 5,
	HIT = 6,
	DEATH = 7,
}

-- Enumeration for different attack types.
local AttackType = {
	NONE = 0, -- No attack
	ATTACK1 = 1, -- Primary attack
	ATTACK2 = 2, -- Secondary attack
}

-- Global constants for fighter physics.
PLAYER_SPEED = 300 -- Movement speed in pixels per second.
PLAYER_GRAVITY = 3000 -- Acceleration due to gravity in pixels per second squared.

-- Creates a new Fighter object.
-- @param player (number) The player number (1 or 2).
-- @param x (number) The initial x-coordinate.
-- @param y (number) The initial y-coordinate.
-- @param flip (boolean) Whether the sprite should be initially flipped.
-- @param data (table) A table containing fighter-specific data like size, scale, offset, and animation steps.
-- @param sprite_sheet (Image) The LÖVE Image object for the fighter's sprites.
-- @param attack_sound (Source) The LÖVE Source object for the fighter's attack sound.
-- @return (Fighter) The newly created fighter object.
function Fighter.new(player, x, y, flip, data, sprite_sheet, attack_sound)
	local self = setmetatable({}, Fighter) -- Initialize the fighter object.

	-- Assign properties from parameters.
	self.player = player -- Player identifier (1 or 2).
	self.size = data.size -- Size of a single sprite frame.
	self.scale = data.scale -- Scale factor for the sprite.
	self.offset = data.offset -- Offset for drawing the sprite relative to its position.
	self.steps = data.steps -- Table defining the number of frames for each animation.
	self.sprite_sheet = sprite_sheet -- The sprite sheet image.
	self.attack_sound = attack_sound -- Sound played on attack.
	self.flip = flip -- Initial sprite flip state.

	-- Initialize animation-related properties.
	self.animations = Fighter.load_animations(self) -- Load all animation frames from the sprite sheet.
	self.action = Actions.IDLE -- Current action state of the fighter.
	self.frame_index = 1 -- Current frame index in the current animation.
	self.frame_timer = 0 -- Timer to control animation speed.
	self.image = self.animations[self.action][self.frame_index] -- The current visual representation (quad) of the fighter.

	-- Initialize physics and state properties.
	self.rect = { x = x, y = y, w = 80, h = 180 } -- Collision rectangle {x, y, width, height}.
	self.vel_y = 0 -- Vertical velocity.
	self.running = false -- True if the fighter is currently running.
	self.jump = false -- True if the fighter is currently jumping.
	self.attacking = false -- True if the fighter is currently attacking.
	self.attack_type = AttackType.NONE -- The type of the current or last attack.
	self.attack_cooldown = 0 -- Cooldown timer for attacks, preventing rapid attacks.
	self.hit = false -- True if the fighter is currently stunned from being hit.
	self.health = 100 -- Current health points.
	self.alive = true -- True if the fighter is alive.
	self.attack_box = nil -- Collision box for attacks, created when an attack occurs.

	return self
end

-- Loads animations from the sprite sheet based on the fighter's data.
-- It creates LÖVE Quads for each frame of each animation.
-- @return (table) A 2D table where animations[action][frame_index] is a Quad.
function Fighter.load_animations(self)
	local animations = {}
	local sw = self.sprite_sheet:getWidth() -- Sprite sheet width.
	local sh = self.sprite_sheet:getHeight() -- Sprite sheet height.

	-- Iterate over each animation type (row in self.steps).
	for row, frames in ipairs(self.steps) do
		animations[row] = {}
		-- Iterate over each frame in the current animation.
		for i = 0, frames - 1 do
			-- Create a Quad for the specific frame from the sprite sheet.
			-- self.size is the width/height of a single frame.
			-- (row - 1) * self.size is the y-offset for the animation row in the sprite sheet.
			local quad = love.graphics.newQuad(i * self.size, (row - 1) * self.size, self.size, self.size, sw, sh)
			table.insert(animations[row], quad)
		end
	end
	return animations
end

-- Handles fighter movement, input processing, and physics updates.
-- @param screen_width (number) The width of the game screen.
-- @param screen_height (number) The height of the game screen.
-- @param target (Fighter) The opposing fighter, used for direction flipping and attack targeting.
-- @param round_over (boolean) True if the current round has ended.
function Fighter:move(screen_width, screen_height, target, round_over)
	local dt = love.timer.getDelta() -- Time since the last frame.
	local dx, dy = 0, 0 -- Change in x and y position for this frame.

	-- Reset movement/action states for the current frame.
	self.running = false
	self.attack_type = AttackType.NONE

	-- Get player inputs.
	local JOY_LEFT = Input.isDown(self.player, BTN_LEFT)
	local JOY_RIGHT = Input.isDown(self.player, BTN_RIGHT)
	local JOY_UP = Input.isDown(self.player, BTN_UP)
	local DO_ATTACK1 = Input.once(self.player, BTN_B)
	local DO_ATTACK2 = Input.once(self.player, BTN_Y)
	local DO_SELECT = Input.once(self.player, BTN_SELECT) -- Toggle debug mode.

	if DO_SELECT then
		DEBUG = not DEBUG
	end

	-- Process movement and actions if the fighter is alive, not currently attacking, and the round is not over.
	if self.alive and not self.attacking and not round_over then
		-- Horizontal movement based on left/right input.
		local move_dir = JOY_LEFT and -1 or JOY_RIGHT and 1 or 0 -- -1 for left, 1 for right, 0 for no horizontal input.
		if move_dir ~= 0 then
			dx = PLAYER_SPEED * move_dir -- Calculate horizontal displacement.
			self.running = true
		end

		-- Jumping based on up input.
		if JOY_UP and not self.jump then
			self.vel_y = -900 -- Apply an upward velocity for the jump.
			self.jump = true
		end

		-- Attack input processing.
		local attack = DO_ATTACK1 and AttackType.ATTACK1 or DO_ATTACK2 and AttackType.ATTACK2 or AttackType.NONE
		if attack ~= AttackType.NONE then
			self:attack(target) -- Perform the attack.
			self.attack_type = attack -- Store the type of attack performed.
		end
	end

	-- Apply gravity to the vertical velocity.
	self.vel_y = self.vel_y + PLAYER_GRAVITY * dt
	dy = self.vel_y * dt -- Calculate vertical displacement.

	-- Horizontal screen bounds check to prevent moving off-screen.
	local future_x = self.rect.x + dx * dt -- Predicted x position after movement.
	if future_x < 0 then -- Check left boundary.
		dx = -self.rect.x / dt -- Adjust dx to stop at the boundary.
	elseif future_x + self.rect.w > screen_width then -- Check right boundary.
		dx = (screen_width - self.rect.x - self.rect.w) / dt -- Adjust dx to stop at the boundary.
	end

	-- Vertical ground collision detection.
	local ground_y = -35 -- Defines the y-coordinate of the ground relative to screen bottom.
	local future_y = self.rect.y + self.rect.h + dy -- Predicted y position of fighter's feet.
	if future_y > screen_height - ground_y then
		self.vel_y = 0 -- Stop vertical movement.
		self.jump = false -- No longer jumping.
		dy = screen_height - ground_y - self.rect.y - self.rect.h -- Adjust dy to place fighter exactly on the ground.
	end

	-- Flip sprite based on the target's position to always face the opponent.
	self.flip = target.rect.x <= self.rect.x

	-- Decrease attack cooldown timer if it's active.
	if self.attack_cooldown > 0 then
		self.attack_cooldown = self.attack_cooldown - 1
	end

	-- Apply calculated movement to the fighter's position.
	self.rect.x = self.rect.x + dx * dt
	self.rect.y = self.rect.y + dy
end

-- Maps attack types to their corresponding animation actions.
local action_map = {
	[AttackType.ATTACK1] = Actions.ATTACK1,
	[AttackType.ATTACK2] = Actions.ATTACK2,
}

-- Updates the fighter's state, current action, and animation frame.
function Fighter:update()
	-- Update the fighter's action based on their current state.
	if self.health <= 0 then
		-- Fighter is defeated.
		self.alive = false
		self:update_action(Actions.DEATH)
	elseif self.hit then
		-- Fighter is stunned from a hit.
		self:update_action(Actions.HIT)
	elseif self.attacking then
		-- Fighter is performing an attack.
		local action = action_map[self.attack_type]
		if action then
			self:update_action(action)
		end
	elseif self.jump then
		-- Fighter is jumping.
		self:update_action(Actions.JUMP)
	elseif self.running then
		-- Fighter is running.
		self:update_action(Actions.RUN)
	else
		-- Fighter is idle.
		self:update_action(Actions.IDLE)
	end

	-- Advance the animation frame.
	self.frame_timer = self.frame_timer + love.timer.getDelta() -- Accumulate time for frame timing.
	-- If not enough time has passed for a frame update, do nothing.
	if self.frame_timer <= 0.05 then -- Animation frame rate (e.g., 0.05s per frame = 20 FPS for animations).
		return
	end
	self.frame_timer = 0 -- Reset frame timer.
	self.frame_index = self.frame_index + 1 -- Move to the next frame.

	local current_animation = self.animations[self.action]
	-- Check if the animation has reached its end.
	if self.frame_index > #current_animation then
		if not self.alive then
			-- If fighter is dead, freeze on the last frame of the death animation.
			self.frame_index = #current_animation
			return
		end

		self.frame_index = 1 -- Loop back to the first frame.

		-- Reset states after certain animations complete.
		if self.action == Actions.ATTACK1 or self.action == Actions.ATTACK2 then
			-- Attack animation finished.
			self.attacking = false
			self.attack_cooldown = 20 -- Set cooldown before next attack.
			self.attack_box = nil -- Clear the attack hitbox.
		elseif self.action == Actions.HIT then
			-- Hit stun animation finished.
			self.hit = false
			self.attacking = false -- Ensure attacking is false if hit interrupts an attack.
			self.attack_cooldown = 20 -- Cooldown can also apply after being hit.
			self.attack_box = nil
		end
	end
end

-- Initiates an attack by the fighter.
-- @param target (Fighter) The target of the attack.
function Fighter:attack(target)
	-- Check if the attack cooldown period has passed.
	if self.attack_cooldown <= 0 then
		self.attacking = true -- Set fighter state to attacking.
		self.attack_sound:play() -- Play attack sound.

		-- Define the attack's hitbox (attack_range).
		-- The commented-out lines suggest alternative hitbox calculations.
		-- Current implementation: hitbox is same width as fighter, positioned at fighter's x.
		local attack_range = {
			-- x = self.rect.x - (2 * self.rect.w * (self.flip and 1 or -1)), -- Alternative x, extends based on flip.
			x = self.rect.x, -- Current x position of the hitbox.
			y = self.rect.y, -- Current y position of the hitbox.
			-- w = 2 * self.rect.w, -- Alternative width, wider than the fighter.
			w = self.rect.w, -- Current width of the hitbox.
			h = self.rect.h, -- Current height of the hitbox.
		}
		self.attack_box = attack_range -- Store the active hitbox.

		-- Check for collision between the attack_range and the target's rectangle.
		if self:check_collision(attack_range, target.rect) then
			target.health = target.health - 10 -- Apply damage to the target.
			target.hit = true -- Set the target's state to hit (stunned).
		end
	end
end

-- Updates the fighter's current action and resets the animation frame index.
-- This is called when the fighter's state changes (e.g., from IDLE to RUN).
-- @param new_action (Actions) The new action to set for the fighter.
function Fighter:update_action(new_action)
	-- Only update if the new action is different from the current one.
	if new_action ~= self.action then
		self.action = new_action -- Set the new action.
		self.frame_index = 1 -- Reset animation to the first frame of the new action.
	end
end

-- Draws the fighter on the screen.
function Fighter:draw()
	-- Select the correct animation frame (Quad) based on the current action and frame index.
	local quad = self.animations[self.action][self.frame_index]

	-- The following commented-out block is an alternative way to calculate drawing parameters,
	-- possibly from an earlier version or for a different scaling/offset system.
	-- It appears to use self.scale and self.size directly in a way the current code does not.
	-- local x = (self.rect.x - self.offset[1] * self.scale)
	-- local y = (self.rect.y - self.offset[2] * self.scale)
	-- local sx = self.scale * (self.flip and -1 or 1)
	-- local sy = self.scale
	-- local ox = self.flip and self.size or 0
	-- local oy = 0
	-- print('quad', quad, 'x', x, 'y', y, 'sx', sx, 'sy', sy, 'ox', ox, 'oy', oy)
	-- love.graphics.draw(self.sprite_sheet, quad, x, y, r, sx, sy, ox, oy)

	-- Get viewport details of the quad (source rectangle on the sprite sheet).
	-- qx, qy are the top-left coordinates of the quad on the sprite sheet.
	-- qw, qh are the width and height of the quad on the sprite sheet.
	local qx, qy, qw, qh = quad:getViewport()

	-- Calculate drawing parameters.
	local x = (self.rect.x - self.offset[1]) -- Target x-coordinate on screen, adjusted by sprite offset.
	local y = (self.rect.y - self.offset[2]) -- Target y-coordinate on screen, adjusted by sprite offset.
	local r = 0 -- Rotation angle (0 for no rotation).
	local sx = (self.flip and -1 or 1) -- Scale factor for x-axis; -1 to flip horizontally, 1 for normal.
	local sy = 1 -- Scale factor for y-axis (1 for normal scale).
	local ox = qw / 2 -- Origin x for rotation and scaling (center of the quad).
	local oy = qh / 2 -- Origin y for rotation and scaling (center of the quad).

	-- DEBUG block: Draws rectangles for visualization if DEBUG mode is enabled.
	if DEBUG then
		-- Draw a rectangle around the fighter's sprite (approximating its visual bounds).
		local w = (self.size / self.scale) + 4 -- Width of the debug rectangle.
		local h = (self.size / self.scale) + 4 -- Height of the debug rectangle.
		local w2 = (w / 2) -- Half width for centering.
		local h2 = (h / 2) -- Half height for centering.
		love.graphics.rectangle('line', x - w2, y - h2, w, h)

		-- Draw the fighter's active attack hitbox if it exists.
		if self.attack_box then
			love.graphics.rectangle('line', self.attack_box.x, self.attack_box.y, self.attack_box.w, self.attack_box.h)
		end
	end

	-- isLutro() block: Specific adjustments for the Lutro (RetroArch LÖVE core) environment.
	-- TODO: This should behave the same as in LÖVE2D
	if isLutro() then
		-- These adjustments might be necessary due to differences in how Lutro handles
		-- coordinate systems, scaling, or sprite origins compared to standard LÖVE.
		ox, oy = 1, 1 -- Change origin points. The reason for 1,1 is unclear without more context on Lutro's specifics.
		-- `adjust_x_lutro` and `adjust_y_lutro` would be clearer names for xx, yy.
		-- These seem to be player-specific offsets for Lutro.
		local xx_lutro_adjust = self.player == 2 and 120 or 80 -- Horizontal adjustment value.
		local yy_lutro_adjust = self.player == 2 and 126 or 80 -- Vertical adjustment value.
		x = x - xx_lutro_adjust -- Apply horizontal adjustment.
		y = y - yy_lutro_adjust -- Apply vertical adjustment.
	end

	-- Draw the fighter's sprite.
	love.graphics.draw(self.sprite_sheet, quad, x, y, r, sx, sy, ox, oy)
end

-- Checks for AABB (Axis-Aligned Bounding Box) collision between two rectangles.
-- @param a (table) The first rectangle {x, y, w, h}.
-- @param b (table) The second rectangle {x, y, w, h}.
-- @return (boolean) True if the rectangles overlap, false otherwise.
function Fighter:check_collision(a, b)
	return a.x < b.x + b.w -- a's left edge is to the left of b's right edge
		and a.x + a.w > b.x -- a's right edge is to the right of b's left edge
		and a.y < b.y + b.h -- a's top edge is above b's bottom edge
		and a.y + a.h > b.y -- a's bottom edge is below b's top edge
end

return Fighter
