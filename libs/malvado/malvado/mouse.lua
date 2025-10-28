--[[
  ______        _                _
 |  ___ \      | |              | |
 | | _ | | ____| |_   _ ____  _ | | ___
 | || || |/ _  | | | | / _  |/ || |/ _ \
 | || || ( ( | | |\ V ( ( | ( (_| | |_| |
 |_||_||_|\_||_|_| \_/ \_||_|\____|\___/

 malvado - A game programming library with  "DIV Game Studio"-style
            processes for Lua/Love2D.

 Copyright (C) 2017-present Jeremies Pérez Morata

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
--]]

--- Mouse module implements all mouse interactions.
-- @module malvado.mouse

mouse = {
  -- class
  class = 'mouse',
  -- X pos
  x = 0,
  -- Y position
  y = 0,
  -- Graphic collection
  fpg = nil,
  -- Graphic of grapic collection
  fpgIndex = -1,
  -- Cursor graphic
  graph = nil,
  -- Size
  size = 1,
  -- Width
  width = 0,
  -- Height
  height = 0,
  -- Angle
  angle = 0,
  -- If left button is clicked
  left = false,
  -- If right button is clicked
  right = false
}

function render_mouse()
  mouse.width, mouse.height = render(
    mouse.graph, mouse.fpg, mouse.fpgIndex, mouse.x, mouse.y, mouse.angle, mouse.size)
end

function update_mouse_events ()
  mouse.x = love.mouse.getX()
  mouse.y = love.mouse.getY()
  mouse.left = love.mouse.isDown(1)
  mouse.right = love.mouse.isDown(2)

  if mouse.left then debug("(Mouse) left button  - CLICKED") end
  if mouse.right then debug("(Mouse) right button  - CLICKED") end
end
