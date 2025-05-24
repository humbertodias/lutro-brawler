-- main.lua
-- This file is the main entry point and orchestrator for the Brawler game.
-- It handles the LÖVE game loop callbacks (load, update, draw), manages global game state
-- (like scores, rounds, and pause status), loads and manages all necessary assets
-- (images, sounds, fonts), and initializes game entities, primarily the fighters.

-- Require necessary game modules.
require('global') -- Contains global variables and constants like SCREEN_WIDTH, SCREEN_HEIGHT, COLORS, etc.
local fighterModule = require('fighter') -- Load the fighter module that now returns a table.
Fighter = fighterModule.Fighter -- Extract the Fighter class from the module.
Actions = fighterModule.Actions -- Extract the Actions table from the module.
Input = require('input') -- The input handling module.

-- Game settings and state variables.
local introCount = 3 -- Counter for the pre-round "3, 2, 1" countdown.
local lastCountUpdate = 0 -- Timestamp of the last update to introCount, used for timing the countdown.
local score = { 0, 0 } -- Stores the scores for player 1 (index 1) and player 2 (index 2).
local roundOver = false -- Boolean flag indicating if the current round has ended.
local roundOverTime = 0 -- Timestamp of when the round ended, used for the cooldown before the next round.

local ROUND_OVER_COOLDOWN = 2 -- Duration in seconds to pause at the end of a round before starting a new one.

-- Asset variables: these will hold the loaded game assets.
-- Images
local bgImage -- Background image for the game stage.
local bgScaleX, bgScaleY -- Scale factors for the background image to fit the screen.
local warriorSheet -- Spritesheet for the Warrior character.
local wizardSheet -- Spritesheet for the Wizard character.
local victoryImage -- Image displayed when a round is over (e.g., "Victory!" icon).

-- Sounds
local swordSound -- Sound effect for the Warrior's attack.
local magicSound -- Sound effect for the Wizard's attack.
local victorySound -- Sound effect played when a round is won.
local readySound -- Sound effect played at the start of a new round (e.g., "Ready?").
local fightSound -- Sound effect played when the countdown finishes (e.g., "Fight!").
local musicBG -- Background music stream.

-- Fonts
local countFont -- Font used for the intro countdown numbers.
local scoreFont -- Font used for displaying scores and other UI text.

-- Fighter instance variables: these will hold the Fighter objects.
local fighter1 -- Fighter object for player 1.
local fighter2 -- Fighter object for player 2.

-- Fighter data: configuration tables for initializing Fighter objects.
-- WARRIOR_DATA: Contains specific parameters for the Warrior character.
--   size: The width/height of a single frame in the spritesheet (pixels).
--   scale: The scaling factor to apply when drawing the sprite.
--   offset: {x, y} pixel offset for drawing the sprite relative to its collision box position, helps align visuals.
--   steps: An array where each element is the number of frames for a specific animation (e.g., idle, run, attack).
--   hitbox_config: Defines hitboxes for specific actions and frames.
--     Each key is an Action (e.g., Actions.ATTACK1).
--     The value is an array of tables, each defining a hitbox for a specific frame:
--       frame: The frame number (1-based) when this hitbox is active.
--       x_offset, y_offset: Relative to fighter's self.rect.x/y.
--       w, h: Width and height of the hitbox.
local WARRIOR_DATA = {
	size = 162,
	scale = 4,
	offset = { -40, -80 },
	steps = { 10, 8, 1, 7, 7, 3, 7 },
	hitbox_config = {
		[Actions.ATTACK1] = {
			{ frame = 3, x_offset = 50, y_offset = 70, w = 40, h = 30 },
			{ frame = 4, x_offset = 52, y_offset = 70, w = 40, h = 30 },
		},
		[Actions.ATTACK2] = {
			{ frame = 4, x_offset = 55, y_offset = 60, w = 65, h = 35 },
		},
	},
}

-- WIZARD_DATA: Contains specific parameters for the Wizard character (same structure as WARRIOR_DATA).
local WIZARD_DATA = {
	size = 250,
	scale = 3,
	offset = { -40, -60 },
	steps = { 8, 8, 1, 8, 8, 3, 7 },
	hitbox_config = {
		[Actions.ATTACK1] = {
			{ frame = 3, x_offset = 60, y_offset = 80, w = 35, h = 25 },
			{ frame = 4, x_offset = 62, y_offset = 80, w = 35, h = 25 },
		},
		[Actions.ATTACK2] = {
			{ frame = 4, x_offset = 70, y_offset = 70, w = 40, h = 40 },
			{ frame = 5, x_offset = 70, y_offset = 70, w = 40, h = 40 },
		},
	},
}

-- Starting positions for the fighters.
local fighter1StartPos = { x = 40, y = 95 } -- Initial {x, y} coordinates for fighter 1.
local fighter2StartPos = { x = 200, y = 95 } -- Initial {x, y} coordinates for fighter 2.

-- LÖVE callback function for game configuration.
function love.conf(t)
	-- Set the game window dimensions using global constants.
	t.width = SCREEN_WIDTH
	t.height = SCREEN_HEIGHT
end

-- LÖVE callback function, called once when the game starts.
-- Used for loading assets and initializing game states.
function love.load()
	-- Optional debug line for MobDebug.
	--   if arg[#arg] == "-debug" then require("mobdebug").start() end

	-- Set the title of the game window.
	love.window.setTitle('Brawler')
	-- Set the window mode: width, height, and options (fullscreen, resizable, centered).
	love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, { fullscreen = false, resizable = true, centered = true })
	-- Set the default background color (black in this case, though a background image is drawn over it).
	love.graphics.setBackgroundColor(0, 0, 0)
	-- Set the default texture filter to 'nearest' for pixel art aesthetics (no blurring).
	love.graphics.setDefaultFilter('nearest', 'nearest')

	-- Load image assets.
	bgImage = love.graphics.newImage('assets/images/background/background-320x240.png') -- Load the background image.
	-- Calculate scale factors to make the background image fit the screen dimensions.
	bgScaleX = SCREEN_WIDTH / bgImage:getWidth()
	bgScaleY = SCREEN_HEIGHT / bgImage:getHeight()

	warriorSheet = love.graphics.newImage('assets/images/warrior/Sprites/warrior.png') -- Load Warrior spritesheet.
	wizardSheet = love.graphics.newImage('assets/images/wizard/Sprites/wizard.png') -- Load Wizard spritesheet.
	victoryImage = love.graphics.newImage('assets/images/icons/victory.png') -- Load the victory icon.

	-- Load sound effect assets (static means they are loaded fully into memory).
	swordSound = love.audio.newSource('assets/audio/sword.wav', 'static') -- Warrior attack sound.
	magicSound = love.audio.newSource('assets/audio/magic.wav', 'static') -- Wizard attack sound.

	readySound = love.audio.newSource('assets/audio/ready.ogg', 'static') -- "Ready?" sound.
	fightSound = love.audio.newSource('assets/audio/fight.ogg', 'static') -- "Fight!" sound.
	victorySound = love.audio.newSource('assets/audio/victory.ogg', 'static') -- Round victory sound.

	-- Load background music asset (stream means it's played directly from storage, good for large files).
	musicBG = love.audio.newSource('assets/audio/music.ogg', 'stream')
	musicBG:setVolume(0.5) -- Set music volume to 50%.
	musicBG:setLooping(true) -- Make the music loop continuously.
	musicBG:play() -- Start playing the background music.

	-- Load font assets.
	-- Creates a new image font using a texture atlas (letters.png) and a character map string.
	local lettersFont = love.graphics.newImageFont('assets/fonts/letters.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789.!?')
	-- local pointsFont = love.graphics.newImageFont('assets/fonts/points.png', '0123456789') -- Another font, currently commented out.
	local defaultFont = lettersFont -- Set the loaded font as the default.
	countFont = defaultFont -- Font for the intro countdown.
	scoreFont = defaultFont -- Font for scores and other UI text.

	-- Initialize the first round of the game.
	startNewRound()
end

-- LÖVE callback function, called repeatedly every frame.
-- Handles game logic updates based on time passed (dt).
-- @param dt (number) Delta time: the time elapsed since the last frame.
function love.update(dt)
	-- Update the input system to process current button/key states.
	Input.update(dt)

	-- Check if the pause button has been pressed.
	checkPause()
	-- If the game is paused, skip the rest of the update logic for this frame.
	if PAUSE then
		return
	end

	-- Main game state logic:
	if introCount <= 0 then
		-- If the intro countdown is finished:
		roundStart() -- Perform actions that happen once at the very start of the fighting part of the round.

		-- Allow fighters to process movement based on input and game physics.
		-- SCREEN_WIDTH and SCREEN_HEIGHT are passed for boundary checks.
		-- The other fighter is passed as 'target' for AI or orientation.
		fighter1:move(SCREEN_WIDTH, SCREEN_HEIGHT, fighter2, roundOver)
		fighter2:move(SCREEN_WIDTH, SCREEN_HEIGHT, fighter1, roundOver)

		-- Update fighter states (animations, internal logic).
		fighter1:update()
		fighter2:update()
	else
		-- If the intro countdown is still active:
		-- Check if one second has passed since the last countdown update.
		if love.timer.getTime() - lastCountUpdate >= 1 then
			introCount = introCount - 1 -- Decrement the countdown.
			lastCountUpdate = love.timer.getTime() -- Record the time of this update.
		end
	end

	-- Check if the round has ended (e.g., a fighter's health is zero).
	checkRoundOver()
end

-- Checks for pause input and toggles the PAUSE state.
-- Also pauses or resumes background music accordingly.
function checkPause()
	-- Check if the start button was pressed once by either player.
	if Input.once(1, BTN_START) or Input.once(2, BTN_START) then
		PAUSE = not PAUSE -- Toggle the global PAUSE flag.
		if PAUSE then
			musicBG:stop() -- Stop music if paused.
		else
			musicBG:play() -- Resume music if unpaused.
		end
	end
end

-- Handles logic at the very start of the fighting part of a round.
-- Specifically, plays the "Fight!" sound once when the intro countdown hits zero.
function roundStart()
	-- Check if the intro count is zero and if the fight sound hasn't been played yet for this round.
	-- lastCountUpdate is set to -1 after playing to prevent it from playing repeatedly.
	if introCount == 0 and lastCountUpdate ~= -1 then
		fightSound:play() -- Play the "Fight!" sound.
		lastCountUpdate = -1 -- Mark that the sound has been played for this round.
	end
end

-- LÖVE callback function, called repeatedly every frame after love.update().
-- Responsible for drawing all game elements to the screen.
function love.draw()
	-- Set default drawing color to white (important if other parts of code change it).
	love.graphics.setColor(COLORS.WHITE)
	-- Draw the background image first, so other elements appear on top of it.
	drawBackground()

	-- Draw health bars for both fighters.
	-- Parameters: current health, x-coordinate, y-coordinate.
	drawHealthBar(fighter1.health, 20, 20) -- Player 1 health bar.
	drawHealthBar(fighter2.health, SCREEN_WIDTH - (SCREEN_WIDTH / 2) + 10, 20) -- Player 2 health bar. (Original comment: 256 + 20 margin)

	-- Draw the fighter sprites.
	fighter1:draw()
	fighter2:draw()

	-- Draw the current scores.
	local scoreXOffset = 8 -- Small offset for centering the score text.
	love.graphics.setFont(scoreFont) -- Set the font for score display.
	love.graphics.setColor(COLORS.RED) -- Set the color for the score text.
	-- Print scores for player 1 and player 2, centered horizontally.
	love.graphics.print(score[1] .. ' ' .. score[2], (SCREEN_WIDTH / 2) - scoreXOffset - 2, 40)

	-- Conditional drawing based on game state:
	if introCount > 0 then
		-- If the intro countdown is active, draw the countdown number.
		love.graphics.setFont(countFont) -- Set font for countdown.
		love.graphics.print(introCount, (SCREEN_WIDTH / 2) - 4, SCREEN_HEIGHT / 3) -- Draw number, centered.
	elseif roundOver then
		-- If the round is over, draw the victory image.
		love.graphics.draw(victoryImage, (SCREEN_WIDTH / 2 - victoryImage:getWidth() / 2) - scoreXOffset, SCREEN_HEIGHT / 3)
		-- Play the victory sound (Note: playing sound in love.draw is generally not ideal as it can trigger every frame;
		-- this might be better placed in checkRoundOver when roundOver becomes true).
		victorySound:play()
	end
	love.graphics.setColor(COLORS.WHITE) -- Reset color to white after potential changes.

	-- If DEBUG mode is enabled, draw debug information.
	if DEBUG then
		drawDebug()
	end
	-- If the game is PAUSED, draw the pause message.
	if PAUSE then
		drawPause()
	end
end

-- Draws the background image, scaled to fit the screen.
function drawBackground()
	love.graphics.draw(bgImage, 0, 0, 0, bgScaleX, bgScaleY)
end

-- Displays the "PAUSED" message on the screen when the game is paused.
function drawPause()
	love.graphics.print('PAUSED', (SCREEN_WIDTH / 2) - 20, SCREEN_HEIGHT / 2)
end

-- Draws a health bar for a fighter.
-- @param health (number) The current health value of the fighter (typically 0-100).
-- @param x (number) The x-coordinate for the top-left of the health bar.
-- @param y (number) The y-coordinate for the top-left of the health bar.
function drawHealthBar(health, x, y)
	local barWidth = 256 / 2 -- The maximum width of the health bar.
	local barHeight = 19 / 2 -- The height of the health bar.
	-- Calculate the ratio of current health to max health (100), ensuring it's not negative.
	local ratio = math.max(health / 100, 0)

	-- Draw the white border/background of the health bar.
	love.graphics.setColor(COLORS.WHITE)
	love.graphics.rectangle('fill', x - 2, y - 2, barWidth + 4, barHeight + 4)

	-- Draw the red underlying bar (representing lost health or total bar capacity).
	love.graphics.setColor(COLORS.RED)
	love.graphics.rectangle('fill', x, y, barWidth, barHeight)

	-- Draw the yellow foreground bar representing the current health.
	-- Its width is scaled by the health ratio.
	love.graphics.setColor(COLORS.YELLOW)
	love.graphics.rectangle('fill', x, y, barWidth * ratio, barHeight)

	-- Reset color to white.
	love.graphics.setColor(COLORS.WHITE)
end

-- Draws debug information on the screen, typically the game version.
function drawDebug()
	love.graphics.setColor(COLORS.WHITE)
	love.graphics.setFont(scoreFont) -- Use the standard score font.
	love.graphics.print(string.format('VERSION: %s', VERSION:upper()), 10, SCREEN_HEIGHT - 10) -- Display version at bottom-left.
end

-- Initializes or resets fighters for the start of a new round.
-- Plays a "ready" sound and creates new Fighter objects with their respective data and start positions.
function startNewRound()
	readySound:play() -- Play the "Ready?" sound.
	-- Create fighter 1 (Warrior) instance.
	fighter1 = Fighter.new(1, fighter1StartPos.x, fighter1StartPos.y, false, WARRIOR_DATA, warriorSheet, swordSound)
	-- Create fighter 2 (Wizard) instance, flipped horizontally.
	fighter2 = Fighter.new(2, fighter2StartPos.x, fighter2StartPos.y, true, WIZARD_DATA, wizardSheet, magicSound)
end

-- Checks if the round has concluded, updates scores, and manages the transition to a new round.
function checkRoundOver()
	if not roundOver then
		-- If the round is not currently marked as over:
		if not fighter1.alive then
			-- If fighter 1 is not alive, player 2 scores.
			score[2] = score[2] + 1
			roundOver = true -- Mark the round as over.
			roundOverTime = love.timer.getTime() -- Record when the round ended.
		elseif not fighter2.alive then
			-- If fighter 2 is not alive, player 1 scores.
			score[1] = score[1] + 1
			roundOver = true -- Mark the round as over.
			roundOverTime = love.timer.getTime() -- Record when the round ended.
		end
	elseif love.timer.getTime() - roundOverTime > ROUND_OVER_COOLDOWN then
		-- If the round is marked as over AND the cooldown period has passed:
		roundOver = false -- Reset the roundOver flag.
		introCount = 3 -- Reset the intro countdown for the new round.
		startNewRound() -- Initialize entities for the new round.
	end
end
