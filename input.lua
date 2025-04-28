RETRO_DEVICE_ID_JOYPAD_B = 1
RETRO_DEVICE_ID_JOYPAD_Y = 2
RETRO_DEVICE_ID_JOYPAD_SELECT = 3
RETRO_DEVICE_ID_JOYPAD_START = 4
RETRO_DEVICE_ID_JOYPAD_UP = 5
RETRO_DEVICE_ID_JOYPAD_DOWN = 6
RETRO_DEVICE_ID_JOYPAD_LEFT = 7
RETRO_DEVICE_ID_JOYPAD_RIGHT = 8
RETRO_DEVICE_ID_JOYPAD_A = 9
RETRO_DEVICE_ID_JOYPAD_X = 10
RETRO_DEVICE_ID_JOYPAD_L = 11
RETRO_DEVICE_ID_JOYPAD_R = 12
RETRO_DEVICE_ID_JOYPAD_L2 = 13
RETRO_DEVICE_ID_JOYPAD_R2 = 14
RETRO_DEVICE_ID_JOYPAD_L3 = 15
RETRO_DEVICE_ID_JOYPAD_R3 = 16

local input = {}

function input.getMovement(player)
	if player == 1 then
		if love.keyboard.isDown('a') then
			return -1
		elseif love.keyboard.isDown('d') then
			return 1
		end
	elseif player == 2 then
		if love.keyboard.isDown('left') then
			return -1
		elseif love.keyboard.isDown('right') then
			return 1
		end
	end
	return 0
end

function input.isJumpPressed(player)
	if player == 1 then
		return love.keyboard.isDown('w')
	elseif player == 2 then
		return love.keyboard.isDown('up')
	end
	return false
end

function input.getAttackType(player)
	if player == 1 then
		if love.keyboard.isDown('r') then
			return 1 -- Attack1
		elseif love.keyboard.isDown('t') then
			return 2 -- Attack2
		end
	elseif player == 2 then
		if love.keyboard.isDown('kp1') then
			return 1 -- Attack1
		elseif love.keyboard.isDown('kp2') then
			return 2 -- Attack2
		end
	end
	return 0
end

return input
