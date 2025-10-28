function love.conf(t)
    t.window.title = "Malvado Brawler"
end

require 'libs/malvado/malvado'
require 'src/game'

malvado.start(function()
    Game()
end)