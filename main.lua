-- main.lua
-- Brawler Game
local Fighter = require('fighter')

-- Game settings
local SCREEN_WIDTH = 640
local SCREEN_HEIGHT = 480
local intro_count = 3
local last_count_update = 0
local score = { 0, 0 }
local round_over = false
local ROUND_OVER_COOLDOWN = 2
local round_over_time = 0

-- Colors
local RED = { 255, 0, 0 }
local YELLOW = { 255, 255, 0 }
local WHITE = { 255, 255, 255 }

-- Assets
local bg_image
local bg_width
local bg_height
local warrior_sheet
local wizard_sheet
local victory_img
local sword_fx
local magic_fx
local count_font
local score_font

-- Fighters
local fighter_1
local fighter_2

-- Fighter data
local WARRIOR_DATA = { size = 162, scale = 4, offset = { 72, 56 }, steps = { 10, 8, 1, 7, 7, 3, 7 } }
local WIZARD_DATA = { size = 250, scale = 3, offset = { 112, 107 }, steps = { 8, 8, 1, 8, 8, 3, 7 } }

local fighter_1_x
local fighter_1_y
local fighter_2_x
local fighter_2_y

local scale_x
local scale_y

function love.load()
	
    -- uncomment the following lines to enable the debug on zerobrane studio
	-- if arg[#arg] == '-debug' then
	-- 	require('mobdebug').start()
	-- end

	love.window.setTitle('Brawler')
	love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {fullscreen = true, resizable = true, centered = true})

	SCREEN_WIDTH = love.graphics.getWidth()
    SCREEN_HEIGHT = love.graphics.getHeight()

	-- Fighter scale based on screen size
	fighter_1_x = SCREEN_WIDTH * 0.2
	fighter_1_y = SCREEN_HEIGHT * 0.73
	fighter_2_x = SCREEN_WIDTH - (SCREEN_WIDTH * 0.3)
	fighter_2_y = SCREEN_HEIGHT * 0.73

	-- Load assets
	bg_image = love.graphics.newImage('assets/images/background/background-640x480.png')
	warrior_sheet = love.graphics.newImage('assets/images/warrior/Sprites/warrior.png')
	wizard_sheet = love.graphics.newImage('assets/images/wizard/Sprites/wizard.png')
	victory_img = love.graphics.newImage('assets/images/icons/victory.png')

	bg_width = bg_image:getWidth()
	bg_height = bg_image:getHeight()

	-- aspect ratio
	scale_x = SCREEN_WIDTH / bg_width
    scale_y = SCREEN_HEIGHT / bg_height

	-- Set texture filter to "nearest" to avoid smoothing
	warrior_sheet:setFilter('nearest', 'nearest')
	wizard_sheet:setFilter('nearest', 'nearest')

	sword_fx = love.audio.newSource('assets/audio/sword.wav', 'static')
	magic_fx = love.audio.newSource('assets/audio/magic.wav', 'static')
	local music = love.audio.newSource('assets/audio/music.ogg', 'stream')
	music:setVolume(0.5)
	music:setLooping(true)
	music:play()

	-- lutro does support ttf fonts
	-- count_font = love.graphics.newFont('assets/fonts/turok.ttf', 80)
	-- score_font = love.graphics.newFont('assets/fonts/turok.ttf', 30)

	count_font = love.graphics.newImageFont("assets/fonts/turok.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789*:|=-<>./'\"+$")
	score_font = love.graphics.newImageFont("assets/fonts/turok.png", " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789*:|=-<>./'\"+$")
	
	fighter_1 = Fighter.new(1, fighter_1_x, fighter_1_y, false, WARRIOR_DATA, warrior_sheet, sword_fx)
	fighter_2 = Fighter.new(2, fighter_2_x, fighter_2_y, true, WIZARD_DATA, wizard_sheet, magic_fx)
end

function love.conf(t)
	t.width = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

function love.update(dt)
	if intro_count <= 0 then
		-- Move fighters during the round
		fighter_1:move(SCREEN_WIDTH, SCREEN_HEIGHT, fighter_2)
		fighter_2:move(SCREEN_WIDTH, SCREEN_HEIGHT, fighter_1)

		fighter_1:update()
		fighter_2:update()
	else
		-- Countdown timer for intro
		if love.timer.getTime() - last_count_update >= 1 then
			intro_count = intro_count - 1
			last_count_update = love.timer.getTime()
		end
	end

	-- Check for player defeat and handle round over
	if not round_over then
		if not fighter_1.alive then
			score[2] = score[2] + 1
			round_over = true
			round_over_time = love.timer.getTime()
		elseif not fighter_2.alive then
			score[1] = score[1] + 1
			round_over = true
			round_over_time = love.timer.getTime()
		end
	else
		-- If round is over, show victory image
		if love.timer.getTime() - round_over_time > ROUND_OVER_COOLDOWN then
			round_over = false
			intro_count = 3
			fighter_1 = Fighter.new(1, fighter_1_x, fighter_1_y, false, WARRIOR_DATA, warrior_sheet, sword_fx)
			fighter_2 = Fighter.new(2, fighter_2_x, fighter_2_y, true, WIZARD_DATA, wizard_sheet, magic_fx)
		end
	end
end

function love.draw()
	-- white
	love.graphics.setColor(1, 1, 1)

	draw_bg()

	-- Draw health bars and score
	draw_health_bar(fighter_1.health, 20, 20)
	draw_health_bar(fighter_2.health, SCREEN_WIDTH - (SCREEN_WIDTH * 0.4) - 20, 20)

	fighter_1:draw()
	fighter_2:draw()

	-- red
	love.graphics.setColor(1, 0, 0)
	love.graphics.setFont(score_font)
	love.graphics.print(score[1] .. ' - ' .. score[2], (SCREEN_WIDTH / 2) - 15, 30)

	-- Draw the countdown if intro is active
	if intro_count > 0 then
		love.graphics.setFont(count_font)
		love.graphics.print(intro_count, (SCREEN_WIDTH / 2), (SCREEN_HEIGHT / 3))
	elseif round_over then
		-- Display victory image during round over
		love.graphics.draw(victory_img, SCREEN_WIDTH / 2 - victory_img:getWidth() / 2, SCREEN_HEIGHT / 3)
	end
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end
end

function draw_bg()
    -- Scale the background image proportionally to screen size
	love.graphics.draw(bg_image, 0, 0, 0, scale_x, scale_y)
end

function draw_health_bar(health, x, y)
    local bar_width = SCREEN_WIDTH * 0.4
    local bar_height = SCREEN_HEIGHT * 0.04
    
    local ratio = health / 100

    love.graphics.setColor(WHITE)
    love.graphics.rectangle('fill', x - 2, y - 2, bar_width + 4, bar_height + 4)
    
    love.graphics.setColor(RED)
    love.graphics.rectangle('fill', x, y, bar_width, bar_height)
    
    love.graphics.setColor(YELLOW)
    love.graphics.rectangle('fill', x, y, bar_width * ratio, bar_height)
    
    love.graphics.setColor(1, 1, 1, 1)
end
