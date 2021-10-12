local state = require "packages/state"
local tiny = require "packages/tiny"
local inspect = require "packages/inspect"
local vector = require("packages/hump/vector")
local humpcam = require("packages/hump/camera")
local tiled = require("packages/tiles")
local bump = require("packages/bump")

local game = state(
  {
    world = tiny.world(),
    cam = humpcam(0, 0),
    assets = {
      img = {
        sheet = love.graphics.newImage("assets/sheet.png"),
      },

      levels = {"level1", "level2", "level3", "level5", "level6", "level8", "level4", "level7", "last"},

      sounds = {
        reload = love.audio.newSource("assets/reload.wav", "static"),
        shot = love.audio.newSource("assets/shot.wav", "static"),
        punch = love.audio.newSource("assets/Punch.wav", "static"),
      },

      shaders = {},
    },
  },
  nil
)

local function create_scene(game)

  local scene = state(setmetatable({}, { __index = self, render = function() end } ), game)

  function scene:start()

    local world = self.parent.world

    self.starts = love.timer.getTime()

    --self.startFilter = function(w, s) return s.pipeline == "start" end
    self.updateFilter = function(w, s) return s.pipeline == "update" end
    self.shaderFilter = function(w, s) return s.pipeline == "shader" end
    self.renderFilter = function(w, s) return s.pipeline == "render" end

    self.bump_world = bump.newWorld(50)

    --add systems
    local systems = require("systems")
    local updateBump = systems.updateBump()
    local setupLights = systems.setupLights()

    updateBump.bworld = self.bump_world
    tiny.add(world, systems.renderBatches(), systems.renderSprite(), systems.renderRect(), systems.updatePos(), systems.updateScript(), updateBump, systems.updateLocalNodes(), setupLights)

    local shader = love.graphics.newShader( require("assets/shaders/phong") )
    self.parent.assets.shaders.crt = shader

    setupLights.shader = shader
    setupLights.cam = self.parent.cam

    --add entts


    local sheet = self.parent.assets.img["sheet"]

    local animations = { zidle = love.graphics.newQuad(32, 16, 16, 16, sheet:getDimensions()) }
    animations.zrun = {animations.zidle, love.graphics.newQuad(48, 32, 16, 16, sheet:getDimensions()), love.graphics.newQuad(64, 32, 16, 16, sheet:getDimensions())}
    animations.zhurt = {animations.zidle, love.graphics.newQuad(48, 16, 16, 16, sheet:getDimensions()), love.graphics.newQuad(64, 16, 16, 16, sheet:getDimensions()), love.graphics.newQuad(80, 16, 16, 16, sheet:getDimensions()), love.graphics.newQuad(96, 16, 16, 16, sheet:getDimensions()), love.graphics.newQuad(112, 16, 16, 16, sheet:getDimensions())}

    local function makeBullet(scene, pos, vel)
      local bullet = {
        tag = "bullet",
        pos = pos,
        vel = vel,
        light = {pos = vector(0, 0), power = 1050, color = {1, 1, 1}},
        colbox = { x = pos.x, y = pos.y, w = 3, h = 1,
          filter = function(item, other)
            --if other.tag == "tile" then return "slide" end
            return "cross"
          end,
          response = function(bul, dt, ax, ay, cols, len)
              for i, col in pairs(cols) do
                if col.other.tag == "tile" or col.other.tag == "zombie" then

                  if col.other.tag == "zombie" then
                    local zom = col.other
                    zom.damage = zom.damage + 1
                    zom.state.id = "stun"
                    zom.state.start = love.timer.getTime()
                    --local diff = vector(ax, ay) - bul.pos
                    zom.vel = bul.vel:normalized() * 20
                  end

                  bul.scene.bump_world:update(bul,-1000, -1000)
                  bul.colbox = nil

                  local world = bul.scene.parent.world
                  tiny.removeEntity(world, bul)
                  world:refresh()
                end
                -- if col.other.tag and col.other.tag == "player" then return end
                -- local world = bul.scene.parent.world
                -- tiny.removeEntity(world, bul)
                -- world:refresh()
                -- bul.scene.bump_world:remove(bul)
              end
              bul.pos.x = ax; bul.pos.y = ay;
          end,
        },
        sprite = {
          img = sheet,
          quad = love.graphics.newQuad(10, 33, 3, 1, sheet:getDimensions()),
          pos = vector(0, 0),
          r = vel:angleTo(vector(1, 0)),
          origon = vector(1, 0),
          scale = vector(1, 1),
          z = 3,
        },
        start = love.timer.getTime(),
        script = function(bul, dt)
          bul.colbox.x = bul.pos.x; bul.colbox.y = bul.pos.y;
          if love.timer.getTime() - bul.start > 10 then
            local world = bul.scene.parent.world
            tiny.removeEntity(world, bul)
            world:refresh()
            --bul.scene.bump_world:remove(bul)
            --print("dead")
          end
        end,
        attached = {},
        scene = scene
      }

      scene.bump_world:add(bullet, bullet.colbox.x, bullet.colbox.y, bullet.colbox.w, bullet.colbox.h)

      bullet.attached["light"] = {body = bullet.light, lpos = vector(1, 0)}
      bullet.attached["sprite"] = {body = bullet.sprite, lpos = vector(0, 0)}

      return bullet
    end

    local function makeTorch(pos, dir)
      local dirs = {}
      dirs["light_f"] = {quad = {54, 69, 4, 10}, lpos = vector(6, 6)}
      dirs["light_l"] = {quad = {48, 85, 4, 9}, lpos = vector(0, 5)}
      dirs["light_r"] = {quad = {60, 101, 4, 9}, lpos = vector(12, 5)}
      local torch = {
        light = {
          pos = pos + dirs[dir].lpos,
          power = 100,
          color = {1, 1, 1}
        },
        bat = 300,
        script = function(tor, dt)
          tor.light.power = tor.bat + math.sin(love.timer.getTime() + math.cos(love.timer.getTime() + 2)) * 100
        end,
        sprite = {
          img = sheet,
          quad = love.graphics.newQuad(dirs[dir].quad[1], dirs[dir].quad[2], dirs[dir].quad[3], dirs[dir].quad[4], sheet:getDimensions()),
          pos = pos + dirs[dir].lpos,
          z = 1,
        }
      }

      return torch
    end

    local function makeZombie(pos, scene)
      local zombie = {
        tag = "zombie",
        pos = pos,
        vel = vector(0, 0),
        colbox = {x = pos.x, y = pos.y, w = 10, h = 15,
          response = function(zom, dt, ax, ay, cols, len)
            zom.pos.x = ax - 3
            zom.pos.y = ay - 1

            for i, col in pairs(cols) do
              if col.other.tag and col.other.tag == "player" then
                if col.other.state.id ~= "stun" and col.other.state.id ~= "dead" and zom.state.id ~= "dead" then
                  col.other.state.id = "stun"
                  local uf = (col.other.item.state.id == "fire" or col.other.item.state.id == "reload" or (col.other.item.state.id == "idle" and love.timer.getTime() - col.other.item.state.start < .1))
                  if uf then
                  col.other.health = col.other.health - 1 else col.other.health = col.other.health - .5 end
                  col.other.state.start = love.timer.getTime()
                  col.other.vel = (col.other.pos - zom.pos):normalized() * 300
                  zom.scene.cameraman.shake.mag = 10
                  zom.scene.parent.assets.sounds.punch:clone():play()
                end
              end
              if col.other.tag and col.other.tag == "tile" then
                if zom.state.id == "go" or zom.state.id == "circle" then
                  zom.state.id = "go"
                  zom.state.target = zom.pos + vector(math.random(-16, 16), math.random(-16, 16))
                  zom.state.i = 1
                  zom.state.last = love.timer.getTime()
                end
              end
            end
          end,
          filter = function(item, other)
            if other.tag == "tile" then return "slide" end
            if (item.state.id == "dead" or item.state.id == "stun") then return "cross" end
            if other.tag == "zombie" then
              if (other.state.id == "dead" or other.state.id == "stun") then return "cross" end
              return "slide"
            end
            return "cross"
          end,
        },
        damage = 0,
        state = {id = "linger"},
        script = function(zom, dt)
          zom.colbox.x = zom.pos.x + 3; zom.colbox.y = zom.pos.y + 1

          -- for i, entity in pairs(zom.scene.zombies) do
          --   local diff = (zom.pos + vector(8, 8)) - (entity.pos + vector(8, 8))
          --   if diff:len() < 8 then
          --     zom.vel = zom.vel + diff:normalized() * 100 * dt
          --   end
          -- end

          if zom.vel.x < 0 then
            zom.sprite.scale.x = -1
            zom.attached.sprite.lpos.x = 16
          else
            zom.sprite.scale.x = 1
            zom.attached.sprite.lpos.x = 0
          end

          local state = zom.state
          if state.id == "linger" then

            zom.sprite.quad = animations.zidle

            zom.vel.x = zom.vel.x / 4
            zom.vel.y = zom.vel.y / 4

            if zom.scene.player.item and zom.scene.player.item.state.id == "fire" then
              local target = zom.scene.player.pos
              local diff = target - zom.pos

              if diff:len() < 10 * 16 then
                local flip = math.random(0, 1)
                if flip > .5 then
                  state.id = "go"
                  state.target = target
                  state.i = 1
                  state.last = love.timer.getTime()
                else
                  state.id = "circle"
                  state.target = target
                  state.start = love.timer.getTime()
                  state.i = 1
                  state.dir = math.floor(math.random(0, 1)) * 2 - 1
                  state.last = love.timer.getTime()
                end
              end
            end

          elseif state.id == "go" then

            if love.timer.getTime() - state.last > .2 then
              if state.i > 3 then state.i = 1 end
              zom.sprite.quad = animations.zrun[state.i]
              state.i = state.i + 1
              state.last = love.timer.getTime()
            end

            local diff = state.target - zom.pos
            zom.vel = zom.vel + diff:normalized() * 1000 * dt
            if zom.vel:len() > 75 then zom.vel = zom.vel:normalized() * 75 end

            if zom.scene.player.item and zom.scene.player.item.state.id == "fire" then
              state.target = zom.scene.player.pos + vector(math.random(-16, 16), math.random(-16, 16))
            end

            if diff:len() < 1 then
              state.id = "linger"
            end

          elseif state.id == "circle" then

            if love.timer.getTime() - state.last > .2 then
              if state.i > 3 then state.i = 1 end
              zom.sprite.quad = animations.zrun[state.i]
              state.i = state.i + 1
              state.last = love.timer.getTime()
            end

            local diff = state.target - zom.pos
            zom.vel = zom.vel + (diff:normalized() * 400 * state.dir * dt):perpendicular() + (diff:normalized() * 600 * dt)
            if zom.vel:len() > 75 then zom.vel = zom.vel:normalized() * 75 end

            if love.timer.getTime() - state.start > 4 then state.id = "go" end


          elseif state.id == "stun" then

            zom.vel.x = zom.vel.x / 1.05
            zom.vel.y = zom.vel.y / 1.05

            if zom.damage == 0 then
              state.id = "go"
              state.target = zom.scene.player.pos
              state.i = 1
              state.last = love.timer.getTime()
            end

            zom.damage = math.max(1, zom.damage)

            zom.sprite.quad = animations.zhurt[math.min(zom.damage, 6)]

            if zom.damage < 7 then
              local uf = (zom.scene.player.item.state.id == "fire" or zom.scene.player.item.state.id == "reload" or (zom.scene.player.item.state.id == "idle" and love.timer.getTime() - zom.scene.player.item.state.start < .1))
              if love.timer.getTime() - state.start > .3 and uf then zom.damage = zom.damage - 1 ; state.start = love.timer.getTime() end
            else
              zom.state.id = "dead"
            end
          elseif state.id == "dead" then
              zom.vel.x = zom.vel.x / 1.02
              zom.vel.y = zom.vel.y / 1.02
          end

        end,
        sprite = {
          img = sheet,
          quad = animations.zidle,
          pos = vector(0, 0),
          scale = vector(1, 1),
          z = 2,
        },
        animations = {},
        attached = {},
        scene = self,
      }

      table.insert(scene.zombies, zombie)

      scene.bump_world:add(zombie, zombie.colbox.x, zombie.colbox.y, zombie.colbox.w, zombie.colbox.h)

      zombie.attached["sprite"] = {body = zombie.sprite, lpos = vector(0, 0)}

      return zombie
    end

    self.zombies = {}

    local map = {
      tmap = tiled(require("assets/" .. self.parent.assets.levels[1]), require("assets/simple16")),
      batches = {}
    }

    map.tmap:createBatches()
    map.batches = map.tmap:getBatches()

    for i, brect in pairs(map.tmap:naive()) do
      --4848tiny.addEntity(world, {rect = brect})
      self.bump_world:add(brect[1], brect.x, brect.y, brect.w, brect.h)
    end

    local player_pos = vector(0, 0)

    for i, chunk in pairs(map.tmap:getLayer("things").chunks) do
      for r = 0, chunk.height - 1 do
        for c = 0, chunk.width - 1 do
          local tile = map.tmap:get(chunk, r, c)
          if tile.tag and tile.tag == "player" then player_pos.x = chunk.x + c; player_pos.y = chunk.y + r; end
          if tile.tag and ( (tile.tag == "light_f") or (tile.tag == "light_r") or (tile.tag == "light_l") ) then
            local pos = vector(chunk.x + c, chunk.y + r)
            pos.x = pos.x * map.tmap.sheet.tilewidth; pos.y = pos.y * map.tmap.sheet.tileheight;
            tiny.addEntity(world, makeTorch(pos, tile.tag))
            world:refresh()
          end
          if tile.tag and tile.tag == "zombie" then
            local pos = vector(chunk.x + c, chunk.y + r)
            pos.x = pos.x * map.tmap.sheet.tilewidth; pos.y = pos.y * map.tmap.sheet.tileheight;
            tiny.addEntity(world, makeZombie(pos, self))
            world:refresh()
          end
        end
      end
    end

    player_pos = vector(map.tmap.sheet.tilewidth * player_pos.x, map.tmap.sheet.tileheight * player_pos.y)

    local gun = {
      pos = vector(0, 0),
      rot = 0,
      state = {id = "idle", start = love.timer.getTime()},
      light = { pos = vector(0, 0), power = 10, color = {255 / 255, 204 / 255, 203 / 255} },
      bullets = 16,
      sprite = {
        img = sheet,
        quad = love.graphics.newQuad(0, 32, 9, 4, sheet:getDimensions()),
        pos = vector(0, 0),
        r = 0,
        origon = vector(5, 3),
        scale = vector(1, -1),
        z = 2,},
      script = function(gun, dt)
        gun.sprite.r = gun.rot

        local lp = gun.sprite.origon:clone() + vector(math.cos(gun.rot) * 30, math.sin(gun.rot) * 30)
        gun.attached["light"].lpos = lp

        if gun.state.id == "idle" then
          gun.light.power = 100000

          if gun.bullets <= 0 then
            gun.state.id = "reload"
            gun.state.start = love.timer.getTime()
             self.parent.assets.sounds.reload:play()
          end

          if love.mouse.isDown(1) and gun.scene.player.state.id == "normal" then
            gun.state.id = "fire"
            gun.light.power = 20
            gun.state.start = love.timer.getTime()

            gun.bullets = gun.bullets - 1
            local sound = self.parent.assets.sounds.shot:clone()
            sound:play()

            local world = gun.scene.parent.world
            local dis = 9
            if gun.rot > 4 and gun.rot < 5.5 then dis = 15 end
            local bullet = makeBullet(gun.scene, vector(gun.pos.x + math.cos(gun.rot) * dis, gun.pos.y + math.sin(gun.rot) * dis), vector(math.cos(gun.rot) * 200, math.sin(gun.rot) * 200))
            tiny.addEntity(world, bullet)
            world:refresh()
            gun.scene.cameraman.shake.mag = 2
          end
        elseif gun.state.id == "fire" then
          local duraion = love.timer.getTime() - gun.state.start

          if duraion > .08 then gun.light.power = 100000 end

          if duraion > .1 and  not(love.mouse.isDown(1)) then
            gun.state.id = "idle"
            gun.state.start = love.timer.getTime()
          end
        elseif gun.state.id == "reload" then

          if love.timer.getTime() - gun.state.start > 1 then
            gun.bullets = 16
            gun.state.id = "idle"
            gun.state.start = love.timer.getTime()
          end
        end

        --print(gun.rot / math.pi)
      end,
      attached = {},
      scene = self,
    }

    gun.attached["sprite"] = {body = gun.sprite, lpos = vector(0, 0)}
    gun.attached["light"] = {body = gun.light, lpos = vector(0, 0)}


    local player = {
      tag = "player",
      pos = vector(player_pos.x, player_pos.y),
      vel = vector(0, 0),
      sprite = {
        img = sheet,
        quad = love.graphics.newQuad(0, 16, 16, 16, sheet:getDimensions()),
        pos = vector(0, 0),
        scale = vector(1, 1);
        r = 0,
        z = 2,
      },
      colbox = {x = player_pos.x, y = player_pos.y, w = 10, h = 16,
        response = function(player, dt, ax, ay, cols, len)
          player.pos.x = ax - 3; player.pos.y = ay;
        end,
        filter = function(item, other)
          if other.tag == "bullet" or other.tag == "zombie" then return "cross" end
          if other.tag == "tile" then return "slide" end
        end
      },
      health = 1,
      state = {id = "normal", start = love.timer.getTime()},
      script = function(p, dt)

        if p.state.id == "normal" then

          if love.timer.getTime() - p.state.start > 5 and p.health < 1 then
            p.health = 1
          end

          p.vel.x = p.vel.x / 1.06
          p.vel.y = p.vel.y / 1.06

          local acc = vector(0, 0)

          if love.keyboard.isDown("w") then acc.y = -1 end
          if love.keyboard.isDown("s") then acc.y = 1 end
          if love.keyboard.isDown("a") then acc.x = -1 end
          if love.keyboard.isDown("d") then acc.x = 1 end
          acc = acc:normalized() * 300 * dt

          p.vel = p.vel + acc

          local maxspeed = 150
          if p.item.state.id == "fire" then maxspeed = 30 end
          if p.vel:len() > maxspeed then p.vel = p.vel:normalized() * maxspeed end

          local diff = gun.pos - vector(scene.parent.cam:mousePosition())
          local rot = diff:angleTo(vector(1, 0)) + math.pi;
          p.item.rot = rot

          local r = rot / math.pi
          local hp
          if r > .5 and r < 1.5 then
            p.item.sprite.scale.y = -1
            p.item.sprite.z = 3
            p.sprite.scale.x = -1
            p.attached.sprite.lpos.x = 16
            hp = vector(7, 11)
          else
            p.item.sprite.scale.y = 1
            p.item.sprite.z = 3
            p.sprite.scale.x = 1
            p.attached.sprite.lpos.x = 0
            hp = vector(9, 11)
          end

          p.attached["item"].lpos = hp

        elseif p.state.id == "stun" then

          p.vel.x = p.vel.x / 1.01
          p.vel.y = p.vel.y / 1.01

          if love.timer.getTime() - p.state.start > .2 then
            p.state.id = "normal"
            p.state.start = love.timer.getTime()
                  self.flashlight.light.power = 1
          end

        elseif p.state.id == "dead" then
          p.vel.x = p.vel.x / 1.04
          p.vel.y = p.vel.y / 1.04
        end

        if p.health <= 0 and p.state.id ~= "dead" then
          p.state.id = "dead"
          p.sprite.quad = love.graphics.newQuad(0, 0, 16, 16, sheet:getDimensions())

        end

        --p.rect.x = math.floor(p.pos.x); p.rect.y = math.floor(p.pos.y);
        p.colbox.x = p.pos.x + 3; p.colbox.y = p.pos.y;

      end,
      attached = {},
      scene = self,

      item = gun,
    }

    self.player = player

    player.attached["sprite"] = {body = player.sprite, lpos = vector(0, 0)}
    player.attached["item"] = {body = player.item, lpos = vector( 9, 11)}

    self.bump_world:add(player, player.colbox.x, player.colbox.y, player.colbox.w, player.colbox.h)


    local cameraman = {
      script = function(cm, dt)
        local camera = cm.scene.parent.cam
        local p = cm.player
        local dx,dy = p.pos.x - camera.x, p.pos.y - camera.y
        local sx,sy = love.math.random(-cm.shake.mag, cm.shake.mag), love.math.random(-cm.shake.mag, cm.shake.mag)
        camera:move(dx/20 + sx ,dy/20 + sy)

        cm.shake.mag = cm.shake.mag / cm.shake.damp
      end,
      player = player,
      shake = {
        mag = .5,
        damp = 1.5,
      },
      scene = self,
    }

    scene.cameraman = cameraman

    local mouse = {
      light = {pos = vector(0, 0), power = 90, color = {1, 1, 1}},
      bat = 200,
      script = function(mouse, dt)
        local camera = mouse.scene.parent.cam
        mouse.light.pos.x, mouse.light.pos.y = camera:mousePosition()
        mouse.light.power = mouse.bat + (math.sin(love.timer.getTime() * 2) * 10)
      end,
      scene = self,
    }

    self.flashlight = mouse

    tiny.addEntity(world, player)
    tiny.addEntity(world, cameraman)
    tiny.addEntity(world, gun)
    tiny.addEntity(world, mouse)
    tiny.addEntity(world, map)
    world:refresh()

    --print(inspect(world.entities))
    --print("ents", unpack(world.entities))

    for i, ent in pairs(world.entities) do
      --print(inspect(ent))
    end

    local cam = self.parent.cam
    cam:zoomTo(2)
    --tiny.update(self.parent.world, dt, self.startFilter)

  end

  function scene:update(dt)
    tiny.update(self.parent.world, dt, self.updateFilter)

    if love.keyboard.isDown("r") and (self.player.state.id == "dead"  or love.timer.getTime() - self.starts  > 1) then
      self.parent.world = tiny.world()
      self.bump_world = bump.newWorld(16)

      self:start()
    end

    if not (self.alldead) then
      local alldead = true
      for i, z in pairs(self.zombies) do alldead = alldead and (z.state.id == "dead" ) end
      self.alldead = alldead
    end

    if love.keyboard.isDown("c") and self.alldead then
      self.parent.world = tiny.world()
      self.bump_world = bump.newWorld(16)
      table.remove(self.parent.assets.levels, 1)
      self.alldead = false
      self:start()
    end

    return self
  end

  function scene:render()
    local cam = self.parent.cam
    local shader = self.parent.assets.shaders.crt
    local zrange = {0, 5}

    tiny.update(self.parent.world, dt, self.shaderFilter)

    love.graphics.setShader(shader)
    cam:attach()
    --love.graphics.clear({66 / 255, 57 / 255, 58 / 255})
    for z = zrange[1], zrange[2] do
      for i, sys in pairs(self.parent.world.systems) do
        --print(sys.z)
        if sys.pipeline == "render" then
          sys.z = z
        end
      end
      tiny.update(self.parent.world, dt, self.renderFilter)
    end
    --love.graphics.print("Hello World!", 0, 0, 0, 1)
    cam:detach()
    love.graphics.setShader()

    if self.player.state.id == "dead" and (love.timer.getTime() - self.player.state.start > 1) then
      local cam = self.parent.cam
      cam:zoomTo(5)
      self.flashlight.bat = 80
      love.graphics.setFont(love.graphics.newFont(32))
      love.graphics.print("DEAD", 600 - 12, 200)
      love.graphics.setFont(love.graphics.newFont(22))
      love.graphics.print("R to Reset", 600 - 19, 240)
    end

    if self.alldead then
      local cam = self.parent.cam
      cam:zoomTo(5)
      self.flashlight.bat = 80
      love.graphics.setFont(love.graphics.newFont(32))
      love.graphics.print("CONTINUE?", 600 - 50, 200)
      love.graphics.setFont(love.graphics.newFont(22))
      love.graphics.print("C to Continue", 600 - 36, 240)
    end

  end

  return scene
end


return create_scene(game)
