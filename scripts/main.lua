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
  print("Lua loop function called with delta: " .. delta)
end

print(type(loopable_proxy))

-- engine.add_loopable(loopable_proxy(loop))

engine:run()
