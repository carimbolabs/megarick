local engine = EngineFactory.new()
    :set_title("Mega Rick")
    :set_width(1280)
    :set_height(720)
    :set_fullscreen(false)
    :create()

engine:prefetch({
  "blobs/player.png",
})

local state = {
  space = false
}

local postal = PostalService.new()

local octopus = engine:spawn("octopus")
octopus:set_action("idle")
octopus:set_placement(720, 410)

local player = engine:spawn("player")
player:set_action("idle")
player:set_placement(0, 580)

local princess = engine:spawn("princess")
princess:set_action("idle")
princess:set_placement(1150, 580)

local candle1 = engine:spawn("candle")
candle1:set_action("light")
candle1:set_placement(30, 100)

local candle2 = engine:spawn("candle")
candle2:set_action("light")
candle2:set_placement(800, 100)

local bullet = engine:spawn("bullet")
bullet:set_action("shoot")
bullet:set_placement(300, 200)
bullet:set_velocity(Vector2D.new(0.4, 0))
bullet:on_update(function(self)
  local pos = self.id
  print("bullet id: " .. pos)
  print("bullet x: " .. self.x .. ", y: " .. self.y)
end)

local function loop(delta)
  print("loop function called with delta: " .. delta)
end

local proxy = loopable_proxy.new(function()
  print("loop function")
end)

print("proxy " .. type(proxy))

-- engine.add_loopable(proxy)

player:on_mail(function(self, message)
  print("from lua " .. message)
end)

player:on_update(function(self)
  local velocity = Vector2D.new(0, 0)

  if engine:is_keydown(KeyEvent.a) then
    velocity.x = -.4
  elseif engine:is_keydown(KeyEvent.d) then
    velocity.x = .4
  end

  if engine:is_keydown(KeyEvent.space) then
    if not state.space then
      local message = Mail.new(1, "hit")
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
  elseif velocity:stationary() then
    self:set_action("idle")
  end

  self:set_velocity(velocity)
end)

engine:run()
