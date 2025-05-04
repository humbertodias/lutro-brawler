SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240

COLORS = {
	RED = { 255, 0, 0 },
	YELLOW = { 255, 255, 0 },
	WHITE = { 255, 255, 255 },
}

DEBUG = true

function isLutro()
	local major, minor, revision, codename = love.getVersion()
	return codename == 'Lutro'
end

function isLove()
	local major, minor, revision, codename = love.getVersion()
	return codename ~= 'Lutro' and major > 0
end
