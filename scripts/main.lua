local engine = EngineFactory.new()
    :set_title("Mega Rick")
    :set_width(854)
    :set_height(480)
    :set_fullscreen(false)
    :create()

engine:prefetch({
  "blobs/fx.ogg",
})

local sm = engine:soundmanager()

sm:play("blobs/fx.ogg")
sleep(1000)
sm:play("blobs/sample.ogg")

-- local mr = engine:spawn("megarick")

-- mr:on_update(function(self)
--   print("bump")
-- end)

-- local head = engine:spawn()

engine:run()
