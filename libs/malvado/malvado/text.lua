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

--- Text primitives
-- @module malvado.text

--- Text align values
TextAlign = {
  ALIGN_TOP_LEFT	= 0,
  ALIGN_TOP = 1,
  ALIGN_TOP_RIGHT = 2,
  ALIGN_CENTER_LEFT = 3,
  ALIGN_CENTER = 4,
  ALIGN_CENTER_RIGHT = 5,
  ALIGN_BOTTOM_LEFT = 6,
  ALIGN_BOTTOM = 7,
  ALIGN_BOTTOM_RIGHT = 8,
}



TextProc = process(function(self)
  while true do
    local font = self.font
    love.graphics.setFont(font.font)
    love.graphics.setColor(font.r, font.g, font.b, font.a)
    love.graphics.print(self.text, self.x, self.y)
    frame()
  end
end)

local function _calculate_textalign_desp(font, text, text_align)
  local text_width = font.font:getWidth(text)
  local text_height = font.font:getHeight()

  if text_align == TextAlign.ALIGN_TOP_LEFT then
    return 0, 0
  elseif text_align == TextAlign.ALIGN_TOP then
    return text_width / 2, 0
  elseif text_align == TextAlign.ALIGN_TOP_RIGHT then
    return text_width, 0
  elseif text_align == TextAlign.ALIGN_CENTER_LEFT then
    return 0, text_height / 2
  elseif text_align == TextAlign.ALIGN_CENTER then
    return text_width / 2, text_height / 2
  elseif text_align == TextAlign.ALIGN_CENTER_RIGHT then
    return text_width, text_height / 2
  elseif text_align == TextAlign.ALIGN_BOTTOM_LEFT then
    return 0, text_height
  elseif text_align == TextAlign.ALIGN_BOTTOM then
    return text_width / 2, text_height
  elseif text_align == TextAlign.ALIGN_BOTTOM_RIGHT then
    return text_width, text_height
  else
    error('Invalid text align:' .. text_align)
  end
end

--- Create a text to render
-- @param _font Font object
-- @param _x x
-- @param _y y
-- @param _text text
-- @see malvado.map.font
function write(_font, _x, _y, _text, text_align)
  text_align = text_align or TextAlign.ALIGN_CENTER
  local xdesp, ydesp = _calculate_textalign_desp(_font, _text, text_align)
  return TextProc { font = _font, x = _x - xdesp, y = _y - ydesp, text = _text, _internal = true, z = 10000 }
end

--- Change some value of a created text
-- @param text_id text id
-- @param _text text
-- @param _x x
-- @param _y y
-- @param _font font
function change_text(text_id, _text, _x, _y, _font)
  local values = {}

  if (_text) then values["text"] = _text end
  if (_x)    then values["x"] = _x end
  if (_y)    then values["y"] = _y end
  if (_font) then values["font"] = _font end

  malvado.mod_process(text_id, values)
end

--- Delete a text by its identifier
-- @param id text id
function delete_text(id)
  if id ~= nil then
    --malvado.delete_text(id)
    kill(id)
  end
end
