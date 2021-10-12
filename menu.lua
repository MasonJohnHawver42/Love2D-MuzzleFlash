

local menu_mt = {
  start = function(m) end,
  render = function(m)
    love.graphics.draw(m.game.assets.start_img, 0, 0, 0, 1, 1)
  end,
  update = function(m, dt)
    --love.window.setTitle( love.timer.getFPS( ) )

    if love.keyboard.isDown("s") then
      return 
    end
  end,
}
menu_mt.__index = menu_mt

function make_menu(_game)
  local menu = {game = _game, }

  return setmetatable(menu, menu_mt)

end

return setmetatable({}, { __call = function(_, ...) return make_menu(...) end })
