-- This module handles input from both keyboard and gamepads for two players.
-- It provides a unified interface for checking button presses, holds, and releases,
-- as well as analog stick input with deadzone handling.
-- It also includes retro-compatibility for older LÖVE versions.

-- Abstract button constants. These are used throughout the game to refer to specific actions,
-- regardless of whether they are triggered by a keyboard key or a gamepad button.
BTN_B = 1 -- Typically used for a primary action or confirm.
BTN_Y = 2 -- Typically used for a secondary action or alternative.
BTN_SELECT = 3 -- Typically used for 'select' or 'back'.
BTN_START = 4 -- Typically used for 'start' or 'pause'.
BTN_UP = 5 -- Directional up.
BTN_DOWN = 6 -- Directional down.
BTN_LEFT = 7 -- Directional left.
BTN_RIGHT = 8 -- Directional right.
BTN_A = 9 -- Another action button.
BTN_X = 10 -- Another action button.
BTN_L = 11 -- Left shoulder/trigger.
BTN_R = 12 -- Right shoulder/trigger.

-- Abstract button constants for analog stick directions (emulating button presses).
BTN_L_EAST = 13 -- Left stick tilted right.
BTN_L_WEST = 14 -- Left stick tilted left.
BTN_L_NORTH = 15 -- Left stick tilted up.
BTN_L_SOUTH = 16 -- Left stick tilted down.

-- Abstract axis constants for analog sticks.
AXIS_LEFT_X = 1 -- Horizontal axis of the left analog stick.
AXIS_LEFT_Y = 2 -- Vertical axis of the left analog stick.
AXIS_RIGHT_X = 3 -- Horizontal axis of the right analog stick.
AXIS_RIGHT_Y = 4 -- Vertical axis of the right analog stick.

-- Maps abstract button constants to LÖVE's internal keyboard scancodes for Player 1.
-- The order of scancodes corresponds to the BTN_* constants (BTN_B is index 1, etc.).
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
	'e', -- BTN_R
}

-- Maps abstract button constants to LÖVE's internal gamepad button names.
-- The order of names corresponds to the BTN_* constants.
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
	'rightshoulder', -- BTN_R
}

-- Maps abstract axis constants to LÖVE's internal gamepad axis names.
-- The order of names corresponds to the AXIS_* constants.
local axismap = {
	'leftx', -- AXIS_LEFT_X
	'lefty', -- AXIS_LEFT_Y
	'rightx', -- AXIS_RIGHT_X
	'righty', -- AXIS_RIGHT_Y
}

-- A flag to temporarily disable input processing. If true, all input checks return false or 0.
-- The name 'daft' is unusual; it might imply a 'silly' or 'disabled' state.
local daft = false

-- Holds the current press state for each button for each player.
-- state[player_number][button_constant] stores a counter:
-- 0: Button is not pressed.
-- 1: Button was just pressed in this frame.
-- >1: Button has been held for multiple frames.
-- The second table {} within state is for the second player.
local state = { {}, {} }

-- Applies a deadzone to joystick input to prevent slight movements from registering.
-- If the joystick's magnitude is below a threshold (0.1), it's treated as centered.
-- @param x (number) The raw x-axis input from the joystick.
-- @param y (number) The raw y-axis input from the joystick.
-- @return (number, number, number, number) Adjusted x, adjusted y, angle, and magnitude.
--          Returns (0, 0, 0, 0) if input is within the deadzone.
function DeadZone(x, y)
	local angle = math.atan2(-y, x) -- Calculate the angle of the joystick.
	local mag = math.sqrt(x * x + y * y) -- Calculate the magnitude (how far the stick is pushed).

	-- Recalculate x and y based on angle and magnitude. This seems to normalize the vector
	-- but given the context of a dead zone function, it might be ensuring that if it's *not*
	-- in the deadzone, the values are consistent. However, typical deadzone logic often
	-- scales the magnitude *after* subtracting the deadzone threshold.
	-- This specific recalculation might be redundant if `mag` is used directly for the check.
	x = math.cos(angle) * mag
	y = -math.sin(angle) * mag

	-- If the magnitude is less than 0.1 (the deadzone threshold),
	-- return zeros for x, y, angle, and magnitude.
	if mag < 0.1 then
		return 0, 0, 0, 0
	end
	-- Otherwise, return the (potentially recalculated) x, y, original angle, and magnitude.
	return x, y, angle, mag
end

-- Retro-compatibility block for LÖVE 0.9.
-- This section provides fallback implementations for input functions
-- that might not be available in older LÖVE versions.
if not love.joystick.isDown then
	-- Fallback for love.joystick.isDown.
	-- Checks keyboard for player 1 and gamepad for other players.
	love.joystick.isDown = function(pad, btn)
		-- Player 1 keyboard input.
		if pad == 1 and love.keyboard.isScancodeDown(kbdmap[btn]) then
			return true
		end
		-- Check if joystick exists for the given player.
		if love.joystick.getJoystickCount() < pad then
			return false
		end
		-- Gamepad input for the specified player.
		return love.joystick.getJoysticks()[pad]:isGamepadDown(padmap[btn])
	end
end
if not love.joystick.getAxis then
	-- Fallback for love.joystick.getAxis.
	love.joystick.getAxis = function(pad, axis)
		-- Check if joystick exists for the given player.
		if love.joystick.getJoystickCount() < pad then
			return 0 -- Return neutral if no joystick.
		end
		-- Get gamepad axis value.
		return love.joystick.getJoysticks()[pad]:getGamepadAxis(axismap[axis])
	end
end

-- The main table returned by this module, containing functions to access input states.
return {
	-- Updates the input state for all buttons and axes for both players.
	-- This function should be called once per frame.
	-- @param dt (number) Delta time, not explicitly used in this function but common for update methods.
	update = function(dt)
		-- If 'daft' mode is active, skip all input processing.
		if daft then
			return
		end

		for pad = 1, 2 do -- Iterate through player 1 and player 2.
			-- Update state for standard buttons (BTN_B to BTN_R).
			for btn = 1, 12 do
				if love.joystick.isDown(pad, btn) then
					-- If button is down, increment its state counter.
					-- state[pad][btn] = 0 means not pressed.
					-- state[pad][btn] = 1 means just pressed.
					-- state[pad][btn] > 1 means held.
					if state[pad][btn] == nil then
						state[pad][btn] = 0
					end -- Ensure initialization
					state[pad][btn] = state[pad][btn] + 1
				else
					-- If button is not down, reset its state to 0.
					state[pad][btn] = 0
				end
			end

			-- Update state for analog stick directions (emulating button presses).
			-- A threshold of 0.5 is used to determine if the stick is pushed far enough.
			if love.joystick.getAxis(pad, AXIS_LEFT_X) < -0.5 then -- Left stick, X-axis, negative (West)
				if state[pad][BTN_L_WEST] == nil then
					state[pad][BTN_L_WEST] = 0
				end
				state[pad][BTN_L_WEST] = state[pad][BTN_L_WEST] + 1
			else
				state[pad][BTN_L_WEST] = 0
			end
			if love.joystick.getAxis(pad, AXIS_LEFT_X) > 0.5 then -- Left stick, X-axis, positive (East)
				if state[pad][BTN_L_EAST] == nil then
					state[pad][BTN_L_EAST] = 0
				end
				state[pad][BTN_L_EAST] = state[pad][BTN_L_EAST] + 1
			else
				state[pad][BTN_L_EAST] = 0
			end
			if love.joystick.getAxis(pad, AXIS_LEFT_Y) < -0.5 then -- Left stick, Y-axis, negative (North)
				if state[pad][BTN_L_NORTH] == nil then
					state[pad][BTN_L_NORTH] = 0
				end
				state[pad][BTN_L_NORTH] = state[pad][BTN_L_NORTH] + 1
			else
				state[pad][BTN_L_NORTH] = 0
			end
			if love.joystick.getAxis(pad, AXIS_LEFT_Y) > 0.5 then -- Left stick, Y-axis, positive (South)
				if state[pad][BTN_L_SOUTH] == nil then
					state[pad][BTN_L_SOUTH] = 0
				end
				state[pad][BTN_L_SOUTH] = state[pad][BTN_L_SOUTH] + 1
			else
				state[pad][BTN_L_SOUTH] = 0
			end
		end
	end,

	-- Checks if a specific button is currently held down by a player.
	-- @param pad (number) The player number (1 or 2).
	-- @param btn (number) The button constant (e.g., BTN_A).
	-- @return (boolean) True if the button is held, false otherwise.
	isDown = function(pad, btn)
		if daft then
			return false
		end
		if state[pad][btn] == nil then
			return false
		end -- Ensure button state exists
		return state[pad][btn] > 0
	end,

	-- Checks if a specific button was just pressed in the current frame by a player.
	-- This triggers only once per press, not if the button is held.
	-- @param pad (number) The player number (1 or 2).
	-- @param btn (number) The button constant.
	-- @return (boolean) True if the button was just pressed, false otherwise.
	once = function(pad, btn)
		if daft then
			return false
		end
		if state[pad][btn] == nil then
			return false
		end -- Ensure button state exists
		-- state[pad][btn] == 1 means the button was pressed in the previous update cycle
		-- and is now being queried for the first time as "just pressed".
		local val = state[pad][btn] == 1
		if val then
			-- Increment state so that subsequent calls to once() in the same frame for the same button return false.
			-- This effectively consumes the "just pressed" state for this frame.
			state[pad][btn] = state[pad][btn] + 1
		end
		return val
	end,

	-- Checks if a button is pressed, with a cooldown effect.
	-- Useful for actions that shouldn't be triggered every frame if the button is held (e.g., menu navigation).
	-- It triggers when the button is first pressed (state == 1) and then again every 32 frames if held.
	-- @param pad (number) The player number (1 or 2).
	-- @param btn (number) The button constant.
	-- @return (boolean) True if the input should be triggered, false otherwise.
	withCooldown = function(pad, btn)
		if daft then
			return false
		end
		if state[pad][btn] == nil then
			return false
		end -- Ensure button state exists
		-- state[pad][btn] % 32 == 1 means:
		-- 1. If state is 1 (just pressed), 1 % 32 == 1, so it triggers.
		-- 2. If state is 33, 33 % 32 == 1, so it triggers again after 32 frames of being held.
		-- And so on for 65, 97, etc.
		return state[pad][btn] % 32 == 1
	end,

	-- Resets the input state of a specific button for a player.
	-- This effectively makes the button appear as not pressed.
	-- @param pad (number) The player number (1 or 2).
	-- @param btn (number) The button constant.
	reset = function(pad, btn)
		if state[pad][btn] == nil then
			return
		end -- Ensure button state exists before trying to reset
		state[pad][btn] = 0
	end,

	-- Sets the 'daft' mode, which can disable input processing.
	-- @param val (boolean) True to enable 'daft' mode (disable input), false to disable 'daft' mode (enable input).
	setDaft = function(val)
		daft = val
	end,
}
