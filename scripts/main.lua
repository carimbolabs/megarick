local engine = EngineFactory.new()
    :set_title("Mega Rick")
    :set_width(1920)
    :set_height(1080)
    :set_fullscreen(false)
    :create()

engine:prefetch({
  "blobs/bullet.png",
  "blobs/candle.png",
  "blobs/octopus.png",
  "blobs/player.png",
  "blobs/princess.png",
  "blobs/ship.png",
})

engine:set_scene("ship")

local postal = PostalService.new()

local bullets = {}

local function i()
  local bullet = engine:spawn("bullet")
  bullet:set_action("shoot")
  bullet:on_update(function(self)
    if self.x > 860 then
      local message = Mail.new(0, "hit")
      postal:post(message)
      engine:destroy(bullet)
    end
  end)

  local x, y = 300, 580
  local offset_x = math.random(-20, 20)
  local offset_y = math.random(-20, 20)

  bullet:set_placement(x + offset_x, y + offset_y)
  table.insert(bullets, bullet)
end

local state = {
  space = false
}

local octopus = engine:spawn("octopus")
octopus:set_action("attack")
octopus:set_placement(1200, 620)
octopus:on_mail(function(self, message)
  print('octopus received ' .. message)
end)

local player = engine:spawn("player")
player:set_action("idle")
player:set_placement(30, 794)

local princess = engine:spawn("princess")
princess:set_action("idle")
princess:set_placement(1600, 806)

local candle1 = engine:spawn("candle")
candle1:set_action("light")
candle1:set_placement(60, 100)

local candle2 = engine:spawn("candle")
candle2:set_action("light")
candle2:set_placement(1800, 100)

local explosion = engine:spawn("explosion")
explosion:set_action("explosion")
explosion:set_placement(1300, 700)

-- local bullet = engine:spawn("bullet")
-- bullet:set_action("shoot")
-- bullet:set_placement(300, 580)
-- bullet:set_velocity(Vector2D.new(0.4, 0))
-- bullet:on_update(function(self)
--   if self.x > 860 then
--     local message = Mail.new(0, "hit")
--     postal:post(message)
--     engine:destroy(bullet)
--   end
-- end)



local function loop(delta)
  print("loop function called with delta: " .. delta)
end

local proxy = loopable_proxy.new(function()
  print("loop function")
end)

print("proxy " .. type(proxy))

-- engine.add_loopable(proxy)

player:on_mail(function(self, message)
  -- print("from lua " .. message)
end)

player:on_update(function(self)
  local velocity = Vector2D.new(0, 0)

  if engine:is_keydown(KeyEvent.a) then
    velocity.x = -.4
    -- octopus:set_action("attack")
  elseif engine:is_keydown(KeyEvent.d) then
    velocity.x = .4
    octopus:set_action("dead")
  end

  if engine:is_keydown(KeyEvent.space) then
    if not state.space then
      local message = Mail.new(0, "player", "hit")
      postal:post(message)
      state.space = true
    end
  else
    state.space = false
  end

  if velocity:moving() then
    self:set_action("run")
    if velocity:left() then
      self:set_flip(Flip.horizontal)
    else
      self:set_flip(Flip.none)
    end
  elseif velocity:zero() then
    self:set_action("idle")
  end

  self:set_velocity(velocity)
end)

engine:run()
