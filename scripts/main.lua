---@diagnostic disable: undefined-global, undefined-field, lowercase-global

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

local vitality

local key_states = {}
local bullet_pool = {}
local explosion_pool = {}
local jet_pool = {}

local timer = false

local behaviors = {
  hit = function(self)
    if #explosion_pool > 0 then
      local explosion = table.remove(explosion_pool)
      local x = octopus.x
      local y = player.y
      local offset_x = (math.random(-2, 2)) * 30
      local offset_y = (math.random(-2, 2)) * 30

      explosion.placement:set(x + offset_x, y + offset_y)
      explosion.action:set("default")

      timemanager:singleshot(math.random(100, 600), function()
        if #jet_pool > 0 then
          local jet = table.remove(jet_pool)
          jet.placement:set(980, 812)
          jet.action:set("default")
          jet.velocity.x = -200 * math.random(3, 6)
        end
      end)
    end

    self.action:set("attack")
    self.kv:set("life", self.kv:get("life") - 1)
  end
}

function setup()
  _G.engine = EngineFactory.new()
      :with_title("Mega Rick")
      :with_width(1920)
      :with_height(1080)
      :with_scale(1.0)
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

  vitality = overlay:create(WidgetType.label)
  vitality.font = fontfactory:get("playful")
  vitality:set("16+", 1350, 620)

  candle1 = entitymanager:spawn("candle")
  candle1.placement:set(60, 100)
  candle1.action:set("default")

  candle2 = entitymanager:spawn("candle")
  candle2.placement:set(1800, 100)
  candle2.action:set("default")

  octopus = entitymanager:spawn("octopus")
  octopus.kv:set("life", 16)
  octopus.placement:set(1200, 622)
  octopus.action:set("idle")
  octopus:on_mail(function(self, message)
    local behavior = behaviors[message]
    if behavior then
      behavior(self)
    end
  end)
  octopus.kv:subscribe("life", function(value)
    vitality:set(string.format("%02d-", math.max(value, 0)))

    if value <= 0 then
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
          destroy(jet_pool)

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

          scenemanager:set("gameover")

          collectgarbage("collect")

          resourcemanager:flush()
        end)
        timer = true
      end
    end
  end)
  octopus:on_animationfinished(function(self)
    self.action:set("idle")
  end)

  princess = entitymanager:spawn("princess")
  princess.action:set("default")
  princess.placement:set(1600, 806)

  player = entitymanager:spawn("player")
  player.action:set("idle")
  player.placement:set(30, 794)

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

  for _ = 1, 9 do
    local jet = entitymanager:spawn("jet")
    jet.placement:set(3000, 3000)
    jet:on_update(function(self)
      if self.x <= -300 then
        self.action:unset()
        self.placement:set(3000, 3000)
        table.insert(jet_pool, self)
      end
    end)
    table.insert(jet_pool, jet)
  end

  scenemanager:set("ship")
end

function loop()
  if not player then
    return
  end

  player.velocity.x = 0

  if statemanager:is_keydown(KeyEvent.left) then
    print("L")
    player.reflection:set(Reflection.horizontal)
    player.velocity.x = -360
  elseif statemanager:is_keydown(KeyEvent.right) then
    print("R")
    player.reflection:unset()
    player.velocity.x = 360
  end

  player.action:set(player.velocity.x ~= 0 and "run" or "idle")

  if statemanager:is_keydown(KeyEvent.space) then
    if not key_states[KeyEvent.space] then
      key_states[KeyEvent.space] = true

      if octopus.kv:get("life") <= 0 then
        return
      end

      if #bullet_pool > 0 then
        local bullet = table.remove(bullet_pool)
        local x = (player.x + player.size.width) + 100
        local y = player.y + 10
        local offset_y = (math.random(-2, 2)) * 30

        bullet.placement:set(x, y + offset_y)
        bullet.action:set("default")
        bullet.velocity.x = 800

        local sound = "bomb" .. math.random(1, 2)
        soundmanager:play(sound)
      end

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
