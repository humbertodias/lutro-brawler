BTN_B = 1
BTN_Y = 2
BTN_SELECT = 3
BTN_START = 4
BTN_UP = 5
BTN_DOWN = 6
BTN_LEFT = 7
BTN_RIGHT = 8
BTN_A = 9
BTN_X = 10
BTN_L = 11
BTN_R = 12

BTN_L_EAST = 13
BTN_L_WEST = 14
BTN_L_NORTH = 15
BTN_L_SOUTH = 16

AXIS_LEFT_X = 1
AXIS_LEFT_Y = 2
AXIS_RIGHT_X = 3
AXIS_RIGHT_Y = 4

local kbdmap = {
	's',
	'a',
	'rshift',
	'return',
	'up',
	'down',
	'left',
	'right',
	'd',
	'w',
	'q',
	'e',
}

local padmap = {
	'a',
	'x',
	'back',
	'start',
	'dpup',
	'dpdown',
	'dpleft',
	'dpright',
	'b',
	'y',
	'leftshoulder',
	'rightshoulder',
}

local axismap = {
	'leftx',
	'lefty',
	'rightx',
	'righty',
}

local daft = false
local state = { {}, {} }

function DeadZone(x, y)
	local angle = math.atan2(-y, x)
	local mag = math.sqrt(x * x + y * y)

	x = math.cos(angle) * mag
	y = -math.sin(angle) * mag

	if mag < 0.1 then
		return 0, 0, 0, 0
	end
	return x, y, angle, mag
end

-- retro compatibility with love 0.9
if not love.joystick.isDown then
	love.joystick.isDown = function(pad, btn)
		if pad == 1 and love.keyboard.isScancodeDown(kbdmap[btn]) then
			return true
		end
		if love.joystick.getJoystickCount() < pad then
			return false
		end
		return love.joystick.getJoysticks()[pad]:isGamepadDown(padmap[btn])
	end
end
if not love.joystick.getAxis then
	love.joystick.getAxis = function(pad, axis)
		if love.joystick.getJoystickCount() < pad then
			return 0
		end
		return love.joystick.getJoysticks()[pad]:getGamepadAxis(axismap[axis])
	end
end

return {
	update = function(dt)
		if daft then
			return
		end

		for pad = 1, 2 do
			for btn = 1, 12 do
				if love.joystick.isDown(pad, btn) then
					state[pad][btn] = state[pad][btn] + 1
				else
					state[pad][btn] = 0
				end
			end

			if love.joystick.getAxis(pad, AXIS_LEFT_X) < -0.5 then
				state[pad][BTN_L_WEST] = state[pad][BTN_L_WEST] + 1
			else
				state[pad][BTN_L_WEST] = 0
			end
			if love.joystick.getAxis(pad, AXIS_LEFT_X) > 0.5 then
				state[pad][BTN_L_EAST] = state[pad][BTN_L_EAST] + 1
			else
				state[pad][BTN_L_EAST] = 0
			end
			if love.joystick.getAxis(pad, AXIS_LEFT_Y) < -0.5 then
				state[pad][BTN_L_NORTH] = state[pad][BTN_L_NORTH] + 1
			else
				state[pad][BTN_L_NORTH] = 0
			end
			if love.joystick.getAxis(pad, AXIS_LEFT_Y) > 0.5 then
				state[pad][BTN_L_SOUTH] = state[pad][BTN_L_SOUTH] + 1
			else
				state[pad][BTN_L_SOUTH] = 0
			end
		end
	end,
	isDown = function(pad, btn)
		if daft then
			return false
		end
		return state[pad][btn] > 0
	end,
	once = function(pad, btn)
		if daft then
			return false
		end
		local val = state[pad][btn] == 1
		if val then
			state[pad][btn] = state[pad][btn] + 1
		end
		return val
	end,
	withCooldown = function(pad, btn)
		if daft then
			return false
		end
		return state[pad][btn] % 32 == 1
	end,
	reset = function(pad, btn)
		state[pad][btn] = 0
	end,
	setDaft = function(val)
		daft = val
	end,

	getMovement = function(pad)
		-- -1,1,0
        if love.joystick.isDown(pad, BTN_LEFT) then return -1
        elseif love.joystick.isDown(pad, BTN_RIGHT) then return 1 end
        return 0
	end,
	getAttackType = function(pad)
		-- 1,2,0
        if love.joystick.isDown(pad, BTN_B) then return 1
        elseif love.joystick.isDown(pad, BTN_Y) then return 2 end
        return 0
	end,

	isJumpPressed = function(pad)
		-- true/false
		return love.joystick.isDown(pad, BTN_UP)
	end,
}
