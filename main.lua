-- main.lua
-- Brawler Game

require('global')
Fighter = require('fighter')
Input = require('input')

-- Game settings
local introCount = 3
local lastCountUpdate = 0
local score = { 0, 0 }
local roundOver = false
local roundOverTime = 0

local ROUND_OVER_COOLDOWN = 2

-- Assets
local bgImage
local bgScaleX, bgScaleY
local warriorSheet
local wizardSheet
local victoryImage
local swordSound
local magicSound
local victorySound
local readySound
local fightSound

local countFont
local scoreFont

-- Fighters
local fighter1
local fighter2

-- Fighter data
local WARRIOR_DATA = { size = 162, scale = 4, offset = { -40, -80 }, steps = { 10, 8, 1, 7, 7, 3, 7 } }
local WIZARD_DATA = { size = 250, scale = 3, offset = { -40, -60 }, steps = { 8, 8, 1, 8, 8, 3, 7 } }

local fighter1StartPos = { x = 40, y = 95 }
local fighter2StartPos = { x = 200, y = 95 }

function love.conf(t)
	t.width = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

function love.load()
	--   if arg[#arg] == "-debug" then require("mobdebug").start() end

	love.window.setTitle('Brawler')
	love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, { fullscreen = false, resizable = true, centered = true })
	love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- Load assets
	bgImage = love.graphics.newImage('assets/images/background/background-320x240.png')
	bgScaleX = SCREEN_WIDTH / bgImage:getWidth()
	bgScaleY = SCREEN_HEIGHT / bgImage:getHeight()

	warriorSheet = love.graphics.newImage('assets/images/warrior/Sprites/warrior.png')
	wizardSheet = love.graphics.newImage('assets/images/wizard/Sprites/wizard.png')
	victoryImage = love.graphics.newImage('assets/images/icons/victory.png')

	swordSound = love.audio.newSource('assets/audio/sword.wav', 'static')
	magicSound = love.audio.newSource('assets/audio/magic.wav', 'static')
	
	readySound = love.audio.newSource('assets/audio/ready.ogg', 'static')
	fightSound = love.audio.newSource('assets/audio/fight.ogg', 'static')
	victorySound = love.audio.newSource('assets/audio/victory.ogg', 'static')

	local music = love.audio.newSource('assets/audio/music.ogg', 'stream')
	music:setVolume(0.5)
	music:setLooping(true)
	music:play()

	local lettersFont = love.graphics.newImageFont('assets/fonts/letters.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789.!?')
	--local pointsFont = love.graphics.newImageFont('assets/fonts/points.png', '0123456789')
	local defaultFont = lettersFont
	countFont = defaultFont
	scoreFont = defaultFont

	startNewRound()
end

function love.update(dt)
	if introCount <= 0 then
		roundStart()

		fighter1:move(SCREEN_WIDTH, SCREEN_HEIGHT, fighter2)
		fighter2:move(SCREEN_WIDTH, SCREEN_HEIGHT, fighter1)

		fighter1:update()
		fighter2:update()
	else
		if love.timer.getTime() - lastCountUpdate >= 1 then
			introCount = introCount - 1
			lastCountUpdate = love.timer.getTime()
		end
	end

	checkRoundOver()
end

function roundStart()
	if introCount == 0 and lastCountUpdate ~= -1 then
		fightSound:play()
		lastCountUpdate = -1 -- Prevents negative count from calling fight Sound repeatedly
	end
end


function love.draw()
	love.graphics.setColor(COLORS.WHITE)
	drawBackground()

	drawHealthBar(fighter1.health, 20, 20)
	drawHealthBar(fighter2.health, SCREEN_WIDTH - (SCREEN_WIDTH / 2) + 10, 20) -- 256 + 20 margin

	fighter1:draw()
	fighter2:draw()

	local scoreXOffset = 8
	love.graphics.setFont(scoreFont)
	love.graphics.setColor(COLORS.RED)
	love.graphics.print(score[1] .. ' ' .. score[2], (SCREEN_WIDTH / 2) - scoreXOffset - 2, 40)

	if introCount > 0 then
		love.graphics.setFont(countFont)
		love.graphics.print(introCount, (SCREEN_WIDTH / 2) - 4, SCREEN_HEIGHT / 3)
	elseif roundOver then
		love.graphics.draw(victoryImage, (SCREEN_WIDTH / 2 - victoryImage:getWidth() / 2) - scoreXOffset, SCREEN_HEIGHT / 3)
		victorySound:play()
	end
end

function drawBackground()
	love.graphics.draw(bgImage, 0, 0, 0, bgScaleX, bgScaleY)
end

function drawHealthBar(health, x, y)
	local barWidth = 256 / 2
	local barHeight = 19 / 2
	local ratio = math.max(health / 100, 0)

	love.graphics.setColor(COLORS.WHITE)
	love.graphics.rectangle('fill', x - 2, y - 2, barWidth + 4, barHeight + 4)

	love.graphics.setColor(COLORS.RED)
	love.graphics.rectangle('fill', x, y, barWidth, barHeight)

	love.graphics.setColor(COLORS.YELLOW)
	love.graphics.rectangle('fill', x, y, barWidth * ratio, barHeight)

	love.graphics.setColor(COLORS.WHITE)
end

function startNewRound()
	readySound:play()
	fighter1 = Fighter.new(1, fighter1StartPos.x, fighter1StartPos.y, false, WARRIOR_DATA, warriorSheet, swordSound)
	fighter2 = Fighter.new(2, fighter2StartPos.x, fighter2StartPos.y, true, WIZARD_DATA, wizardSheet, magicSound)
end

function checkRoundOver()
	if not roundOver then
		if not fighter1.alive then
			score[2] = score[2] + 1
			roundOver = true
			roundOverTime = love.timer.getTime()
		elseif not fighter2.alive then
			score[1] = score[1] + 1
			roundOver = true
			roundOverTime = love.timer.getTime()
		end
	elseif love.timer.getTime() - roundOverTime > ROUND_OVER_COOLDOWN then
		roundOver = false
		introCount = 3
		startNewRound()
	end
end
