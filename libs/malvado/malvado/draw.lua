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

--- Draw module implements the draw privimites utilities
-- @module malvado.draw

--- Sets the color of the next primitive to be painted. It's an alias of: love.graphics.setColor.
-- @param red Red
-- @param green Green
-- @param blue Blue
-- @param alpha Alpha (Optional: Default 255)
function set_color(red, green, blue, alpha)
  alpha = alpha or 255
  love.graphics.setColor(red, green, blue, alpha)
end

--- Draws a non-filled circle with center (x0,y0) and radius radius.
-- @param x0 X position
-- @param y0 Y position
-- @param radius Circle Radius
function draw_circle(x0, y0, radius)
   love.graphics.circle("line", x0, y0, radius)
end

--- Draws a filled circle with center (x0,y0) and radius radius.
-- @param x0 X position
-- @param y0 Y position
-- @param radius Circle Radius
function draw_fcircle(x0, y0, radius)
   love.graphics.circle("fill", x0, y0, radius)
end

--- Draws a filled rectangle with corners (x0,y0), (x0,y1), (x1,y0) and (x1,y1).
-- @param x0 The x coordinate of one corner of the filled rectangle.
-- @param y0 The y coordinate of one corner of the filled rectangle.
-- @param x1 The x coordinate of the diagonally opposite corner of the filled rectangle.
-- @param y1 The y coordinate of the diagonally opposite corner of the filled rectangle.
function draw_box(x0, y0, x1, y1)
  love.graphics.rectangle("fill", x0, y0, x1-x0, y1-y0)
end

--- Draws a non filled rectangle with corners (x0,y0), (x0,y1), (x1,y0) and (x1,y1).
-- @param x0 The x coordinate of one corner of the filled rectangle.
-- @param y0 The y coordinate of one corner of the filled rectangle.
-- @param x1 The x coordinate of the diagonally opposite corner of the filled rectangle.
-- @param y1 The y coordinate of the diagonally opposite corner of the filled rectangle.
function draw_rect(x0, y0, x1, y1)
  love.graphics.rectangle("line", x0, y0, x1-x0, y1-y0)
end
