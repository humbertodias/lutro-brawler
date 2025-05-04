local input = {}

-- RetroPad → IDs
local JOY = {
	B = 1,
	Y = 2,
	SELECT = 3,
	START = 4,
	UP = 5,
	DOWN = 6,
	LEFT = 7,
	RIGHT = 8,
	A = 9,
	X = 10,
	L = 11,
	R = 12,
	L2 = 13,
	R2 = 14,
	L3 = 15,
	R3 = 16,
}

-- RetroPad ID → Gamepad name
local GAMEPAD_MAP = {
	[JOY.B] = 'b',
	[JOY.Y] = 'y',
	[JOY.SELECT] = 'back',
	[JOY.START] = 'start',
	[JOY.UP] = 'dpup',
	[JOY.DOWN] = 'dpdown',
	[JOY.LEFT] = 'dpleft',
	[JOY.RIGHT] = 'dpright',
	[JOY.A] = 'a',
	[JOY.X] = 'x',
	[JOY.L] = 'leftshoulder',
	[JOY.R] = 'rightshoulder',
	[JOY.L2] = 'lefttrigger',
	[JOY.R2] = 'righttrigger',
	[JOY.L3] = 'leftstick',
	[JOY.R3] = 'rightstick',
}

local joysticks = {}
if love.joystick and love.joystick.getJoysticks then
	joysticks = love.joystick.getJoysticks()
end

local function joyIsDown(player, buttonId)
	local j = joysticks[player]
	if not j then
		return false
	end

	if j:isGamepad() then
		local mapped = GAMEPAD_MAP[buttonId]
		return mapped and j:isGamepadDown(mapped)
	end

	if isLutro() then
		return love.joystick.isDown(player, buttonId)
	end

	return false
end

input.KEYBOARD_BINDINGS = {
	[1] = { left = 'a', right = 'd', jump = 'w', attack1 = 'r', attack2 = 't' },
	[2] = { left = 'left', right = 'right', jump = 'up', attack1 = 'kp1', attack2 = 'kp2' },
}

function input.getMovement(player)
	local kb = input.KEYBOARD_BINDINGS[player]
	if love.keyboard.isDown(kb.left) or joyIsDown(player, JOY.LEFT) then
		return -1
	elseif love.keyboard.isDown(kb.right) or joyIsDown(player, JOY.RIGHT) then
		return 1
	end
	return 0
end

function input.isJumpPressed(player)
	local kb = input.KEYBOARD_BINDINGS[player]
	return love.keyboard.isDown(kb.jump) or joyIsDown(player, JOY.A)
end

function input.getAttackType(player)
	local kb = input.KEYBOARD_BINDINGS[player]
	if love.keyboard.isDown(kb.attack1) or joyIsDown(player, JOY.X) then
		return 1
	elseif love.keyboard.isDown(kb.attack2) or joyIsDown(player, JOY.Y) then
		return 2
	end
	return 0
end

local lastEscPressTime = 0
local escPressInterval = 0.5
function toggleDebug()
	DEBUG = not DEBUG
end

function love.keypressed(key)
	if key == 'f1' then
		toggleDebug()
	end
	if isLove() and key == 'escape' then
		local now = love.timer.getTime()
		if now - lastEscPressTime < escPressInterval then
			love.event.quit()
		end
		lastEscPressTime = now
	end
end

return input
