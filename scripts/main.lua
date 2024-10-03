local engine = EngineFactory.new()
    :set_title("Mega Rick")
    :set_width(1280)
    :set_height(720)
    :set_fullscreen(false)
    :create()

engine:prefetch({
  "blobs/player.png",
})


local player = engine:spawn("player")
player:set_action("run")
player:set_placement(0, 580)

local function loop(delta)
  print("loop function called with delta: " .. delta)
end

local proxy = loopable_proxy.new(function()
  print("loop function")
end)

print("proxy " .. type(proxy))

-- engine.add_loopable(proxy)


player:on_update(function(self)
  local velocity = Vector2D.new(0, 0)

  if engine:is_keydown(KeyEvent.a) then
    velocity.x = -.4
  elseif engine:is_keydown(KeyEvent.d) then
    velocity.x = .4
  end

  if engine:is_keydown(KeyEvent.space) then
    velocity.y = -3
  end

  self:set_velocity(velocity)
end)

engine:run()
