local tiny = require "packages/tiny"


-- local _startBump = tiny.processingSystem()
-- _startBump.filter = tiny.requireAll("colbox")
-- _startBump.pipeline = "start"
-- _startBump.bworld = nil
-- function _startBump:process(e, dt)
--
-- end

local function updateLocalNodes(node)
  if not( node.attached and node.pos ) then return end
  for k, v in pairs(node.attached) do
    v.body.pos = node.pos + v.lpos
    updateLocalNodes(v)
  end
end

local function __updateLocalNodes()
local _updateLocalNodes = tiny.processingSystem()
_updateLocalNodes.filter = tiny.requireAll("pos", "attached")
_updateLocalNodes.pipeline = "update"
function _updateLocalNodes:process(e, dt)
  if e then
    updateLocalNodes(e)
  end
end
return _updateLocalNodes end

local function __updatePos()
local _updatePos = tiny.processingSystem()
_updatePos.filter = tiny.requireAll("pos", "vel")
_updatePos.pipeline = "update"
function _updatePos:process(e, dt)
  if e then
    e.pos = e.pos + e.vel * dt
  end
end
return _updatePos end

local function __updateScript()
local _updateScript = tiny.processingSystem()
_updateScript.filter = tiny.requireAll("script")
_updateScript.pipeline = "update"
function _updateScript:process(e, dt)
  if e then
    e.script(e, dt)
  end
end
return _updateScript end

local function __updateBump()
local _updateBump = tiny.processingSystem()
_updateBump.filter = tiny.requireAll("colbox")
_updateBump.pipeline = "update"
function _updateBump:process(e, dt)
  if e then
    local actualX, actualY, cols, len = self.bworld:move(e, e.colbox.x, e.colbox.y, e.colbox.filter or function(...) return "slide" end )
    e.colbox.response(e, dt, actualX, actualY, cols, len)
  end
end
return _updateBump end

local function __setupLights()
local _setupLights = tiny.processingSystem()
_setupLights.filter = tiny.requireAll("light")
_setupLights.pipeline = "shader"
_setupLights.i = 0
function _setupLights:preProcess(dt)
  self.i = 0
  --self.shader:send("screen", {love.graphics.getDimensions()})
end

function _setupLights:process(e, dt)
  if self.i < 64 and e then
    self.shader:send("lights[" .. self.i .. "].position", {self.cam:cameraCoords(e.light.pos.x, e.light.pos.y)})
    self.shader:send("lights[" .. self.i .. "].diffuse", e.light.color)
    self.shader:send("lights[" .. self.i .. "].power", e.light.power)
    self.i = self.i + 1
  end
end

function _setupLights:postProcess(dt)
  self.shader:send("num_lights", self.i)
end

return _setupLights end

local function __renderRect()
local _renderRect = tiny.processingSystem()
_renderRect.filter = tiny.requireAny("rect")
_renderRect.pipeline = "render"
function _renderRect:process(e, dt)
  if e then
    love.graphics.setColor( e.rect.color or {1,1,1,1} )
    love.graphics.rectangle("fill", e.rect.pos.x, e.rect.pos.y, e.rect.w, e.rect.h, e.rect.r or 0, e.rect.r or 0)
    love.graphics.setColor( {1,1,1,1} )
  end
end
return _renderRect end

local function __renderSprite()
local _renderSprite = tiny.processingSystem()
_renderSprite.filter = tiny.requireAny("sprite")
_renderSprite.pipeline = "render"
_renderSprite.z = 0
function _renderSprite:process(e, dt)
  if e then
  local z = e.sprite.z or 0
  if (z == self.z) then
    local scale = e.sprite.scale or {x = 1, y = 1}
    local origon = e.sprite.origon or {x = 0, y = 0}
    love.graphics.draw(e.sprite.img, e.sprite.quad, e.sprite.pos.x, e.sprite.pos.y, e.sprite.r or 0, scale.x, scale.y, origon.x, origon.y)
  end end
end
return _renderSprite end

-- local _renderTiles = tiny.processingSystem()
-- _renderTiles.filter = tiny.requireAll("tmap")
-- _renderTiles.pipeline = "render"
-- function _renderTiles:process(e, dt)
--   local map = e.tmap
--   for j, layer in pairs(map.layers) do
--     for i, chunk in pairs(layer.chunks) do
--       love.graphics.draw(chunk.batch, chunk.x * map.sheet.tilewidth, chunk.y * map.sheet.tileheight)
--     end
--   end
-- end
local function __renderBatches()
local _renderBatches = tiny.processingSystem()
_renderBatches.filter = tiny.requireAll("batches")
_renderBatches.pipeline = "render"
_renderBatches.z = 0
function _renderBatches:process(e, dt)
  if e then
    for i, batch in pairs(e.batches) do
      if (batch.z == self.z) then
        love.graphics.draw(batch.sb, batch.x, batch.y)
      end
    end
  end
end
return _renderBatches end



local systems =  {
  --renderTiles = _renderTiles,
  renderRect = __renderRect,
  updatePos = __updatePos,
  updateScript = __updateScript,
  updateBump = __updateBump,
  updateLocalNodes = __updateLocalNodes,
  setupLights = __setupLights,
  renderSprite = __renderSprite,
  renderBatches = __renderBatches
}

--systems.__index = systems

return systems
