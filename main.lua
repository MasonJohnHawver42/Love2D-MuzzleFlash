local inspect = require "packages/inspect"


game = {
  assets = {
    start_img = love.graphics.newImage("assets/startscreen.png"),
  },
}

local menu = require("menu")(game)

function love.load()
  menu:start()
end


function love.update(dt)
  menu:update(dt)
end


function love.draw()
  menu:render()
end
