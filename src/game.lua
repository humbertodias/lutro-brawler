
require('src.global')
require('src.fighter')
require('src.hud')
Input = require('src.input')

Game = process(function(self)
    local state = {
        introCount = 3,
        lastCountUpdate = 0,
        score = {0,0},
        roundOver = false,
        roundOverTime = 0,
        fighter1 = nil,
        fighter2 = nil,
    }
    local ROUND_OVER_COOLDOWN = 2

    local bgImage, bgScaleX, bgScaleY
    local warriorSheet, wizardSheet
    local swordSound, magicSound, readySound, fightSound, victorySound, musicBG

    local WARRIOR_DATA = {
        size = 162, scale = 4, offset = {-40,-80}, steps = {10,8,1,7,7,3,7},
        hitbox_config = {
            [Actions.ATTACK1] = {{frame=3,x_offset=50,y_offset=70,w=40,h=30}, {frame=4,x_offset=52,y_offset=70,w=40,h=30}},
            [Actions.ATTACK2] = {{frame=4,x_offset=55,y_offset=60,w=65,h=35}},
            [HitBoxType.HURT] = {w=40,h=50,offset_x=20,offset_y=50,active=true}
        }
    }
    local WIZARD_DATA = {
        size = 250, scale = 3, offset = {-40,-60}, steps = {8,8,1,8,8,3,7},
        hitbox_config = {
            [Actions.ATTACK1] = {{frame=3,x_offset=60,y_offset=80,w=35,h=25}, {frame=4,x_offset=62,y_offset=80,w=35,h=25}},
            [Actions.ATTACK2] = {{frame=4,x_offset=70,y_offset=70,w=40,h=40}, {frame=5,x_offset=70,y_offset=70,w=40,h=40}},
            [HitBoxType.HURT] = {w=70,h=100,offset_x=0,offset_y=0,active=true}
        }
    }
    local fighter1StartPos = {x=40,y=95}
    local fighter2StartPos = {x=200,y=95}

    love.window.setMode(SCREEN_WIDTH, SCREEN_HEIGHT, {fullscreen=false,resizable=true,centered=true})
    love.graphics.setBackgroundColor(0,0,0)
    love.graphics.setDefaultFilter('nearest','nearest')

    bgImage = love.graphics.newImage('assets/images/background/background-320x240.png')
    bgScaleX = SCREEN_WIDTH / bgImage:getWidth()
    bgScaleY = SCREEN_HEIGHT / bgImage:getHeight()
    warriorSheet = love.graphics.newImage('assets/images/warrior/Sprites/warrior.png')
    wizardSheet = love.graphics.newImage('assets/images/wizard/Sprites/wizard.png')

    swordSound = love.audio.newSource('assets/audio/sword.wav','static')
    magicSound = love.audio.newSource('assets/audio/magic.wav','static')
    readySound = love.audio.newSource('assets/audio/ready.ogg','static')
    fightSound = love.audio.newSource('assets/audio/fight.ogg','static')
    victorySound = love.audio.newSource('assets/audio/victory.ogg','static')
    musicBG = love.audio.newSource('assets/audio/music.ogg','stream')
    musicBG:setVolume(0.5)
    musicBG:setLooping(true)
    musicBG:play()

    local function get_game_state()
        return state
    end

    Hud(get_game_state)

    local function startNewRound()
        readySound:play()
        if state.fighter1 then state.fighter1:signal(1) end
        if state.fighter2 then state.fighter2:signal(1) end

        state.fighter1 = Fighter(1,fighter1StartPos.x,fighter1StartPos.y,false,WARRIOR_DATA,warriorSheet,swordSound, state.fighter2)
        state.fighter2 = Fighter(2,fighter2StartPos.x,fighter2StartPos.y,true,WIZARD_DATA,wizardSheet,magicSound, state.fighter1)
        state.fighter1.current_target = state.fighter2
        state.fighter2.current_target = state.fighter1
    end

    startNewRound()

    local function checkRoundOver()
        if not state.roundOver then
            if not state.fighter1.alive then
                state.score[2]=state.score[2]+1
                state.roundOver=true
                state.roundOverTime=love.timer.getTime()
                victorySound:play()
            elseif not state.fighter2.alive then
                state.score[1]=state.score[1]+1
                state.roundOver=true
                state.roundOverTime=love.timer.getTime()
                victorySound:play()
            end
        elseif love.timer.getTime()-state.roundOverTime>ROUND_OVER_COOLDOWN then
            state.roundOver=false
            state.introCount=3
            startNewRound()
        end
    end

    while not key("escape") do
        Input.update(self.delta)

        if state.introCount <= 0 then
             if state.introCount==0 and state.lastCountUpdate~=-1 then
                fightSound:play()
                state.lastCountUpdate = -1
            end
            checkRoundOver()
        else
            if love.timer.getTime()-state.lastCountUpdate >= 1 then
                state.introCount = state.introCount-1
                state.lastCountUpdate = love.timer.getTime()
            end
        end

        love.graphics.draw(bgImage,0,0,0,bgScaleX,bgScaleY)

        frame()
    end
end)
