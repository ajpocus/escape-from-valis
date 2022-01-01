local suit = require("lib.suit")

local Keys = require("mod.keys")
local help = require("mod.helpers")
local pauseState = require("mod.states.pause")
local widgets = require("mod.widgets")

local introText = "Welcome to Valis!"

local gui = suit.new()

local overworldState = {}

function overworldState:update(dt)
  if Game.showIntro then
    widgets.TextBox(gui, introText)
  end

  Game.player:update(dt)
end

function overworldState:draw()
  Game.level:draw()
  Game.player:draw()
  gui:draw()
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
  elseif key == "s" then
    player:walk()
  elseif key == "x" then
    player:act()
  end
end

return overworldState
