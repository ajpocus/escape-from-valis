Object = require("lib.classic")

local spritely = require("mod.spritely")
local const = require("mod.constants")

local MIN_SIZE = 3  -- sizes are in tile units, 16x16
local MAX_SIZE = 10
local MAX_ROOMS = 10
local MAX_DOORS = 4

local Room = Object:extend()

function Room:new(x, y, w, h)
  self.x = x or 1
  self.y = y or 1
  self.w = w or 1
  self.h = h or 1

  self.doors = self:makeDoors()
  self.map = {}
end

function Room:isInside(x, y) -- x and y are tile coordinates NOT pixels
  return x >= self.x or x <= self.x + self.w or y >= self.y or y <= self.y + self.h
end

function Room:makeDoors()
  local dirs = {
    {0, 1},
    {1, 0},
    {0, -1},
    {-1, 0}
  }

  local numDoors = love.math.random(MAX_DOORS)
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

local Level = Object:extend()

function Level:new(roomCount)
  self.roomCount = roomCount or 1
  self.maxWidth = 1
  self.maxHeight = 1
  self.rooms = {}
  self.map = {}

  self:generate()
end

function Level:generate()
  -- make rooms
  for _=1, self.roomCount do
    local roomWidth = love.math.random(MIN_SIZE, MAX_SIZE)
    if roomWidth > self.maxWidth then self.maxWidth = roomWidth end
    local roomHeight = love.math.random(MIN_SIZE, MAX_SIZE)
    if roomHeight > self.maxHeight then self.maxHeight = roomHeight end

    local roomX = love.math.random(self.maxWidth)
    local roomY = love.math.random(self.maxHeight)
    local room = Room(roomX, roomY, roomWidth, roomHeight)

    for x=1, roomWidth do
      local row = {}
      local isRowWall = x == 1 or x == roomWidth

      for y=1, roomHeight do
        local isWall = isRowWall or y == 0 or y == roomHeight
        local tile = const.TILES.ground
        if isWall then tile = const.TILES.wall end
        table.insert(row, tile)
      end

      table.insert(room.map, row)
    end

    table.insert(self.rooms, room)
  end

  -- pregenerate a 2D array of w width and h height
  local map = {}
  for x=1, self.maxWidth do
    map[x] = {}
    for _=1, self.maxHeight do
      table.insert(map[x], const.TILES.ground)
    end
  end

  -- fill in the room tiles
  for x=1, self.maxWidth do
    for y=1, self.maxHeight do
      for _, room in ipairs(self.rooms) do
        if room:isInside(x, y) then
          map[x][y] = room.map[x][y]
        end
      end
    end
  end
end

local Map = Object:extend()

function Map:new(spritesheet)
  self.spritesheet = spritesheet
  self.selector = spritely.load("gfx/dung2.png", { padding = 2, margin = 2 })
  self.memo = {}
  self.tiles = {}
end

-- this function operates on tile coordinates, NOT pixels
-- see mod.constants.TILES for examples
function Map:tile(tx, ty)
  local key = tx..","..ty
  if self.tiles[key] then
    return table.unpack(self.tiles[key])
  end

  local img, quad = self.selector(tx, ty)
  self.tiles[key] = table.pack(img, quad)
  return img, quad
end

function Map:generate(number)
  number = number or 1  -- the level we're on
  -- we should cache the levels so we can call generate any number of times
  if self.memo[number] then
    return self.memo[number]
  end

  local numRooms = love.math.random(MAX_ROOMS)
  local level = Level(numRooms)

  self.memo[number] = level
  return level
end

return Map