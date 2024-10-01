local engine = EngineFactory.new()
    :set_title("Mega Rick")
    :set_width(854)
    :set_height(480)
    :set_fullscreen(false)
    :create()

engine:prefetch({
  "blobs/spritesheet.png",
})


local player = engine:spawn("player")

-- mr:on_update(function(self)
--   print("bump")
-- end)

-- local head = engine:spawn()

engine:run()
