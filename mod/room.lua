Object = require("lib.classic")

local const = require("mod.constants")

local Room = Object:extend()

function Room:new(x, y, w, h)
  self.x = x or 1
  self.y = y or 1
  self.w = w or 1
  self.h = h or 1

  self.doors = self:makeDoors()
  self.map = {}

  for ix=1, w do
    local row = {}
    local isRowWall = ix == 1 or ix == w

    for iy=1, h do
      local isWall = isRowWall or iy == 0 or iy == h
      local tile = const.TILES.ground
      if isWall then tile = const.TILES.wall end
      table.insert(row, tile)
    end

    table.insert(self.map, row)
  end
end

-- this function takes absolute x/y coordinates and tells us
-- whether the room matches the coordinates
-- note: x and y are tile coordinates NOT pixels
function Room:isInside(ox, oy)
  return ox >= self.x or ox <= (self.x + self.w) or oy >= self.y or oy <= (self.y + self.h)
end

function Room:makeDoors()
  local dirs = {
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0}
  }

  local numDoors = love.math.random(const.MAX_DOORS)
  local doors = {}
  for _=1, numDoors do
    local idx
    while not idx do
      idx = love.math.random(#dirs)
    end

    local doorDir = dirs[idx] -- hodor
    dirs[idx] = nil
    table.insert(doors, doorDir)
  end

  return doors
end

return Room
