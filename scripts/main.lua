---@diagnostic disable: undefined-global

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
local label

local key_states = {}
local bullet_pool = {}
local explosion_pool = {}

local life = 20
local timer = false

local function fire()
  if #bullet_pool > 0 then
    local bullet = table.remove(bullet_pool)
    local x = (player.x + player.size.width) + 100
    local y = player.y + 10
    local offset_y = (math.random(-2, 2)) * 30

    bullet:set_placement(x, y + offset_y)
    bullet:move(1000, 0)
    bullet:set_action("default")

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

    explosion:set_placement(x + offset_x, y + offset_y)
    explosion:set_action("default")
    explosion:on_animationfinished(function(self)
      self:unset_action()
      self:set_placement(-128, -128)
      table.insert(explosion_pool, self)
    end)
  end
end

local function gameover()
  octopus:set_action("dead")
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

      collectgarbage("collect")

      resourcemanager:flush()
      scenemanager:set("gameover")
    end)
    timer = true
  end
end

local actions = {
  hit = function(self)
    boom()

    octopus:set_action("attack")
    life = life - 1
    if life <= 0 then
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

  font = fontfactory:get("fixedsys")
  label = overlay:create(WidgetType.label)
  label:set_font(font)
  label:set("Hello World!", 20, 20)

  candle1 = entitymanager:spawn("candle")
  candle1:set_placement(60, 100)
  candle1:set_action("default")

  candle2 = entitymanager:spawn("candle")
  candle2:set_placement(1800, 100)
  candle2:set_action("default")

  octopus = entitymanager:spawn("octopus")
  octopus:set_placement(1200, 622)
  octopus:set_action("idle")
  octopus:on_mail(function(self, message)
    local action = actions[message]
    if action then
      action(self)
    end
  end)

  princess = entitymanager:spawn("princess")
  princess:set_action("default")
  princess:set_placement(1600, 806)

  player = entitymanager:spawn("player")
  player:set_action("idle")
  player:set_placement(30, 794)

  floor = entitymanager:spawn("floor")
  floor:set_placement(-16192, 923)

  for _ = 1, 3 do
    local bullet = entitymanager:spawn("bullet")
    bullet:set_placement(-128, -128)
    bullet:on_update(function(self)
      if self.x > 1200 then
        -- postalservice:post(Mail.new(octopus, "bullet", "hit"))
        bullet:unset_action()
        bullet:set_placement(-128, -128)
        table.insert(bullet_pool, bullet)
      end
    end)
    table.insert(bullet_pool, bullet)
  end

  for _ = 1, 6 do
    local explosion = entitymanager:spawn("explosion")
    explosion:set_placement(-128, -128)
    table.insert(explosion_pool, explosion)
  end

  scenemanager:set("ship")
end

function loop()
  if not player then
    return
  end

  if statemanager:is_keydown(KeyEvent.a) then
    player:set_flip(Flip.horizontal)
    player:set_action("run")
    player:move(-300, player.velocity.y)
  elseif statemanager:is_keydown(KeyEvent.d) then
    player:set_flip(Flip.none)
    player:set_action("run")
    player:move(300, player.velocity.y)
  else
    player:set_action("idle")
    player:move(0, player.velocity.y)
  end

  if statemanager:is_keydown(KeyEvent.space) then
    if not key_states[KeyEvent.space] then
      key_states[KeyEvent.space] = true
      fire()

      io:rpc("send", { ["message"] = "hello world" }, function(result)
        print("RPC " .. JSON.stringify(result))
      end)
    end
  else
    key_states[KeyEvent.space] = false
  end
end

function run()
  engine:run()
end
