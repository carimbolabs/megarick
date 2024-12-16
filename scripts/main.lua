---@diagnostic disable: undefined-global, lowercase-global

local postalservice
local timemanager
local entitymanager
local fontfactory
local io
local overlay
local resourcemanager
local scenemanager
local soundmanager
local statemanager

local candle1
local candle2
local octopus
local princess
local player
local floor

local font
local vitality

local key_states = {}
local bullet_pool = {}
local explosion_pool = {}

local timer = false

local function fire()
  if #bullet_pool > 0 then
    local bullet = table.remove(bullet_pool)
    local x = (player.x + player.size.width) + 100
    local y = player.y + 10
    local offset_y = (math.random(-2, 2)) * 30

    bullet.placement:set(x, y + offset_y)
    bullet.action:set("default")
    bullet:move(800, 0)

    local sound = "bomb" .. math.random(1, 2)
    soundmanager:play(sound)
  end
end

local function boom()
  if #explosion_pool > 0 then
    local explosion = table.remove(explosion_pool)
    local x = octopus.x
    local y = player.y
    local offset_x = (math.random(-2, 2)) * 30
    local offset_y = (math.random(-2, 2)) * 30

    explosion.placement:set(x + offset_x, y + offset_y)
    explosion.action:set("default")
  end
end

local function gameover()
  octopus.action:set("dead")
  if not timer then
    timemanager:singleshot(3000, function()
      local function destroy(pool)
        for i = #pool, 1, -1 do
          entitymanager:destroy(pool[i])
          table.remove(pool, i)
          pool[i] = nil
        end
      end

      destroy(bullet_pool)
      destroy(explosion_pool)

      entitymanager:destroy(octopus)
      octopus = nil

      entitymanager:destroy(player)
      player = nil

      entitymanager:destroy(princess)
      princess = nil

      entitymanager:destroy(candle1)
      candle1 = nil

      entitymanager:destroy(candle2)
      candle2 = nil

      entitymanager:destroy(floor)
      floor = nil

      overlay:destroy(vitality)
      vitality = nil

      collectgarbage("collect")

      resourcemanager:flush()
      scenemanager:set("gameover")
    end)
    timer = true
  end
end

local behaviors = {
  hit = function(self)
    boom()

    self.action:set("attack")
    self.kv.life = self.kv.life - 1
    if self.kv.life <= 0 then
      gameover()
    end
  end
}

function setup()
  _G.engine = EngineFactory.new()
      :with_title("Mega Rick")
      :with_width(1920)
      :with_height(1080)
      :with_gravity(0)
      :with_fullscreen(false)
      :create()

  postalservice = PostalService.new()
  timemanager = TimeManager.new()
  entitymanager = engine:entitymanager()
  fontfactory = engine:fontfactory()
  io = Socket.new()
  overlay = engine:overlay()
  resourcemanager = engine:resourcemanager()
  scenemanager = engine:scenemanager()
  soundmanager = engine:soundmanager()
  statemanager = engine:statemanager()

  emoji = fontfactory:get("emoji")
  vitality = overlay:create(WidgetType.label)
  vitality.font = emoji
  vitality:set("ooooo", 1300, 660)

  candle1 = entitymanager:spawn("candle")
  candle1.placement:set(60, 100)
  candle1.action:set("default")

  candle2 = entitymanager:spawn("candle")
  candle2.placement:set(1800, 100)
  candle2.action:set("default")

  octopus = entitymanager:spawn("octopus")
  octopus.kv.life = 16
  octopus.placement:set(1200, 622)
  octopus.action:set("idle")
  octopus:on_mail(function(self, message)
    print("on mail " .. message)
    local behavior = behaviors[message]
    if behavior then
      behavior(self)
    end
  end)

  princess = entitymanager:spawn("princess")
  princess.action:set("default")
  princess.placement:set(1600, 806)

  player = entitymanager:spawn("player")
  player.action:set("idle")
  player.placement:set(30, 794)

  floor = entitymanager:spawn("floor")
  floor.placement:set(-16192, 923)

  for _ = 1, 3 do
    local bullet = entitymanager:spawn("bullet")
    bullet.placement:set(-128, -128)
    bullet:on_update(function(self)
      if self.x > 1200 then
        self.action:unset()
        self.placement:set(-128, -128)
        postalservice:post(Mail.new(octopus, "bullet", "hit"))
        table.insert(bullet_pool, self)
      end
    end)
    table.insert(bullet_pool, bullet)
  end

  for _ = 1, 9 do
    local explosion = entitymanager:spawn("explosion")
    explosion.placement:set(-128, -128)
    explosion:on_animationfinished(function(self)
      self.action:unset()
      self.placement:set(-128, -128)
      table.insert(explosion_pool, self)
    end)

    table.insert(explosion_pool, explosion)
  end

  scenemanager:set("ship")
end

function loop()
  if not player then
    return
  end

  if statemanager:is_keydown(KeyEvent.a) then
    player.reflection:set(Reflection.horizontal)
    player.action:set("run")
    -- player.velocity:set(-300, player.velocity.y)
  elseif statemanager:is_keydown(KeyEvent.d) then
    player.reflection:set(Reflection.none)
    player.action:set("run")

    -- player.velocity:set(300, player.velocity.y)
  else
    player.action:set("idle")
    -- player.velocity:set(0, player.velocity.y)
  end

  if statemanager:is_keydown(KeyEvent.space) then
    if not key_states[KeyEvent.space] then
      key_states[KeyEvent.space] = true
      fire()

      io:rpc("send", { ["message"] = "hello world from client" }, function(result)
        print(JSON.stringify(result))
      end)
    end
  else
    key_states[KeyEvent.space] = false
  end
end

function run()
  engine:run()
end
