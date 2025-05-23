-- This file defines global constants and utility functions that are used
-- throughout the Brawler game.

-- SCREEN_WIDTH: Defines the native width of the game screen in pixels.
SCREEN_WIDTH = 320
-- SCREEN_HEIGHT: Defines the native height of the game screen in pixels.
SCREEN_HEIGHT = 240

-- COLORS: A table providing predefined RGB color values for easy and consistent use
-- in drawing operations. Each color is a table {red, green, blue}, with values from 0 to 255.
COLORS = {
	RED = { 255, 0, 0 }, -- Pure red.
	YELLOW = { 255, 255, 0 }, -- Pure yellow.
	WHITE = { 255, 255, 255 }, -- Pure white.
}

-- DEBUG: A boolean flag used to toggle debug information and visuals within the game.
-- If true, debug features (like hitboxes or version info) might be displayed.
DEBUG = false

-- VERSION: Stores the current version string of the game.
-- This appears to be a git commit hash, useful for tracking builds.
VERSION = '4e4feaf'

-- PAUSE: A boolean flag used to toggle the game's pause state.
-- If true, game updates should be suspended.
PAUSE = false

-- isLutro(): A utility function to check if the game is currently running
-- within the Lutro environment (a LÖVE wrapper primarily used for RetroArch).
-- It determines this by inspecting the 'codename' returned by love.getVersion().
function isLutro()
	-- Retrieve version information from LÖVE.
	local major, minor, revision, codename = love.getVersion()
	-- Return true if the codename is 'Lutro', false otherwise.
	return codename == 'Lutro'
end
