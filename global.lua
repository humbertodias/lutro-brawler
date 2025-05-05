SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

COLORS = {
	RED = { 255, 0, 0 },
	YELLOW = { 255, 255, 0 },
	WHITE = { 255, 255, 255 },
}

DEBUG = false
VERSION = 'ba8062e'

function isLutro()
	local major, minor, revision, codename = love.getVersion()
	return codename == 'Lutro'
end
