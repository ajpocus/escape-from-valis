require("lib/batteries"):export()
Object = require("lib/classic")
Gamestate = require("lib/hump/gamestate")
local cartographer = require("lib/cartographer")
local helium = require("lib/helium")

local const = require("mod/constants")
local spritely = require("mod/spritely")
local Player = require("mod/player")
local Keys = require("mod/keys")
local widgets = require("mod/widgets")
local help = require("mod/helpers")

Font = love.graphics.newFont("fonts/merriweather/Merriweather-Regular.ttf", 32)

local Game = {
  keys = {}
}

local overworldState = {}
local pauseState = {}
local homeState = {}

local function action()
  if Game.currentText then
    Game.currentText:undraw()
    Game.currentText = nil
  end
end

function love.conf(t)
  t.console = true
end

function love.load()
  -- love.window.setIcon(love.graphics.newImage(""))
  love.window.setTitle("Escape from Detroit!")
  love.window.setMode(const.WIDTH, const.HEIGHT)
  
  Scene = helium.scene.new(true)
  Scene:activate()

  Gamestate.registerEvents()
  Gamestate.switch(overworldState)
end

function overworldState:enter()
  Game.map = cartographer.load("data/map.lua")
  local selector = spritely.load("gfx/blowhard2.png", { padding = 2, margin = 2 })
  local spritesheet, quad = selector(1, 1)

  Game.player = Player(spritesheet, quad)
  Game.keys = Keys()

  local text, dim = widgets.makeText("Hey Dad, I like beer!")
  text:draw(dim.x, dim.y)
  Game.currentText = text
end

function overworldState:update(dt)
  local player = Game.player

  if player:isMovable(Game.map) then
    player:move(dt)
  else
    if player:isColliding(Game.map) then
      player:stepBack()
    end

    player:setMovement(Game.map, 0, 0)
  end

  Scene:update(dt)
end

function overworldState:draw()
  Game.map:draw()
  Game.player:draw()
  Scene:draw()
end

function overworldState:keypressed(key, scancode, isrepeat)
  if isrepeat then return end
  local player = Game.player

  Game.keys:on(key)

  if key == "s" then
    player:run()
  end

  if player:isMoving(Game.map) then return end

  if key == "escape" then
     love.event.quit()
  elseif Keys.isDirection(key) then
    local dx, dy = Keys.getDirection(key)
    player:setMovement(Game.map, dx, dy)
  end
end

function overworldState:keyreleased(key, scancode)
  Game.keys:off(key)
  
  if key == 'return' then
    Gamestate.switch(pauseState)
    return
  end

  local player = Game.player

  if Keys.isDirection(key) and help.tlen(Game.keys.state) == 0 then
    player.dx = 0
    player.dy = 0
  elseif Keys.isDirection(key) and help.tlen(Game.keys.state) > 0 then
    local firstKey
    for k in pairs(Game.keys.state) do
      firstKey = k
      break
    end

    local dx, dy = Keys.getDirection(firstKey)
    player:setMovement(Game.map, dx, dy)
  elseif key == "s" then
    player:walk()
  elseif key == "x" then
    action()
  end
end

function pauseState:enter()
  love.graphics.clear()
end

function pauseState:draw()
  local str = "PAUSE"
  local text = love.graphics.newText(Font, str)
  local w, h = love.graphics.getDimensions()
  local x = w / 2 - Font:getWidth(str) / 2
  local y = h / 2 - Font:getHeight() / 2
  love.graphics.setColor(help.rgba(0, 0, 0))
  love.graphics.rectangle("fill", 0, 0, w, h)
  love.graphics.setColor(help.rgba(255, 255, 255))
  love.graphics.draw(text, x, y)
end

function pauseState:keyreleased(key)
  if key == 'return' then
    Gamestate.switch(overworldState)
  end
end
