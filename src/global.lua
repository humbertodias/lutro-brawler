SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

COLORS = {
	RED = { 255, 0, 0 },
	YELLOW = { 255, 255, 0 },
	WHITE = { 255, 255, 255 },
}

DEBUG = false
VERSION = 'v0.4'
PAUSE = false
SHOW_HITBOX_HURTBOX_VISUALS = true

function isLutro()
	local _, _, _, codename = love.getVersion()
	return codename == 'Lutro'
end
