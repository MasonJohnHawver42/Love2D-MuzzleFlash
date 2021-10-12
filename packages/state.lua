local methods = {
  start = function() end,
  update = function(dt) return self end,
  terminate = function() end,
}

local state_meta = {
  __index = methods,
}

local function new(o, parent)
  local zoo = o or {}
  zoo.parent = parent
  return setmetatable(zoo, state_meta)
end

local state = { __call = function(_, ...) return new(...) end, }

local function _start(state)
  if state.parent then _start(state.parent) end
  state:start()
end

local function _terminate(state)
  if state.parent then _terminate(state.parent) end
  state:terminate()
end

local function sister(state, dt)
  local next = nil
  if state.parent then next = sister(state.parent) end
  if next == state.parent or next == nil then return state:update(dt) end
  return next
end

local function _update(state, dt)

  local next = sister(state, dt)

  if next ~= state then
    _terminate(state)
    _start(next)
  end

  return next
end

local function _set(state, next)
  _terminate(state)
  _start(next)
end

state.__index = { set = _set, update = _update, start = _start, terminate = _terminate }
state = setmetatable({}, state)

return state
