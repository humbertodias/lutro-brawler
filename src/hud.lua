
require 'src.global'

Hud = process(function(self, get_game_state)
    local lettersFont = love.graphics.newImageFont('assets/fonts/letters.png', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789.!?')
    local scoreFont = lettersFont
    local victoryImage = love.graphics.newImage('assets/images/icons/victory.png')

    local function drawHealthBar(health, x, y)
        local barWidth = 128
        local barHeight = 9.5
        local ratio = math.max(health / 100, 0)

        love.graphics.setColor(COLORS.WHITE)
        love.graphics.rectangle('fill', x - 2, y - 2, barWidth + 4, barHeight + 4)

        love.graphics.setColor(COLORS.RED)
        love.graphics.rectangle('fill', x, y, barWidth, barHeight)

        love.graphics.setColor(COLORS.YELLOW)
        love.graphics.rectangle('fill', x, y, barWidth * ratio, barHeight)

        love.graphics.setColor(COLORS.WHITE)
    end

    while true do
        local state = get_game_state()

        -- Draw health bars
        if state.fighter1 and state.fighter2 then
            drawHealthBar(state.fighter1.health, 20, 20)
            drawHealthBar(state.fighter2.health, (SCREEN_WIDTH / 2) + 10, 20)
        end

        -- Draw score
        local scoreXOffset = 8
        love.graphics.setFont(scoreFont)
        love.graphics.setColor(COLORS.RED)
        love.graphics.print(table.concat(state.score, " "), (SCREEN_WIDTH / 2) - scoreXOffset - 2, 40)

        -- Draw intro count or victory message
        if state.introCount > 0 then
            love.graphics.setFont(scoreFont)
            love.graphics.print(state.introCount, (SCREEN_WIDTH / 2) - 4, SCREEN_HEIGHT / 3)
        elseif state.roundOver then
            love.graphics.draw(victoryImage, (SCREEN_WIDTH / 2 - victoryImage:getWidth() / 2) - scoreXOffset, SCREEN_HEIGHT / 3)
        end

        frame()
    end
end)
