Object = require("lib.classic")
local inspect = require("lib.inspect")

local spritely = require("mod.spritely")
local const = require("mod.constants")
local Room = require("mod.room")
local help = require("mod.helpers")

local Level = Object:extend()

function Level:new(number, pixelW, pixelH)
  self.roomCount = love.math.random(const.MAX_ROOMS)

  self.selector, self.spritesheet = spritely.load("gfx/dung2.png", { padding = 2, margin = 2 })
  self.memo = {}
  self.tiles = {}
  self.rooms = {}
  self.map = {}

  self.width, self.height = help.pixelToTile(pixelW, pixelH)
  self.maxWidth = 1
  self.maxHeight = 1

  number = number or 1  -- the level we're on

  -- make rooms
  for _=1, self.roomCount do
    -- if this room is bigger than the max, set the max
    local roomW = love.math.random(const.MIN_SIZE, const.MAX_SIZE)
    local width2 = roomW * roomW
    if width2 > self.maxWidth then self.maxWidth = width2 end

    local roomH = love.math.random(const.MIN_SIZE, const.MAX_SIZE)
    local height2 = roomH * roomH
    if height2 > self.maxHeight then self.maxHeight = height2 end

    local roomPosX = love.math.random(self.maxWidth)
    local roomPosY = love.math.random(self.maxHeight)
    local room = Room(roomPosX, roomPosY, roomW, roomH)
    table.insert(self.rooms, room)
  end

  -- pregenerate a 2D array of w width and h height
  local map = {}
  for y = 1, self.maxHeight do
    map[y] = {}
    for _ = 1, self.maxWidth do
      table.insert(map[y], const.TILES.ground)
    end
  end

  -- fill in the room tiles
  for ty=1, self.height do
    for tx=1, self.width do
      for _, room in ipairs(self.rooms) do
        local px, py = help.tileToPixel(tx, ty)
        if room:isInside(px, py) then
          map[ty][tx] = room.map[ty][tx]
        end
      end
    end
  end

  self.map = map
end

-- this function operates on tile coordinates, NOT pixels
-- see mod.constants.TILES for examples
function Level:tile(tx, ty)
  local key = tx..","..ty
  if self.tiles[key] then
    return self.tiles[key]
  end

  local quad = self.selector(tx, ty)
  self.tiles[key] = quad
  return quad
end

function Level:tileAtPixels(px, py)
  local tx, ty = help.pixelToTile(px, py)
  local tile = self.map[ty][tx]
  return tile
end

function Level:draw()
  for ty, row in ipairs(self.map) do
    for tx, tile in ipairs(row) do
      local sx, sy = unpack(tile.coordinates)
      local quad = self.selector(sx, sy)
      local px, py = help.tileToPixel(tx, ty)
      love.graphics.draw(self.spritesheet, quad, px, py)
    end
  end
end

return Level
