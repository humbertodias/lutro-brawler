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

--- Very basic math utilities
-- @module malvado.math

--- Convert an angle to radians
-- @param angle
-- @return radians
function angleToRadians (angle)
  return (angle * math.pi) / 180
end

--- Calculate the cosinus
-- @param angle
-- @return cosinus
function cos(angle)
  return math.cos(angleToRadians(angle))
end

--- Calculate the sinus
-- @param angle
-- @return sinus
function sin(angle)
  return math.sin(angleToRadians(angle))
end

--- Calculate a random number between min and max
-- @param min
-- @param max
-- @return random number
function rand(min, max)
  return love.math.random(min, max)
end
