local engine = EngineFactory.new()
    :set_title("Mega Rick")
    :set_width(1920)
    :set_height(1080)
    :set_fullscreen(false)
    :create()

engine:prefetch({
  "blobs/bomb1.ogg",
  "blobs/bomb2.ogg",
  "blobs/bullet.png",
  "blobs/candle.png",
  "blobs/explosion.png",
  "blobs/octopus.png",
  "blobs/player.png",
  "blobs/princess.png",
  "blobs/ship.png",
})

engine:set_scene("ship")

local postal = PostalService.new()

local soundmanager = engine:soundmanager()

local bullets = {}

local state = {
  space = false
}

local octopus = engine:spawn("octopus")
local life = 13

octopus:set_action("idle")
octopus:set_placement(1200, 620)
octopus:on_mail(function(self, message)
  if message == 'hit' then
    octopus:set_action("attack")
    life = life - 1
    if life <= 0 then
      self:set_action("dead")
    else
      -- local explosion = engine:spawn("explosion")
      -- explosion:set_action("explosion")
      -- explosion:set_placement(1300, 700)
    end
  end
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

-- local explosion = engine:spawn("explosion")
-- explosion:set_action("explosion")
-- explosion:set_placement(1300, 700)

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
local bullet_pool = {}

local function create_bullet_pool(size)
  for _ = 1, size do
    local bullet = engine:spawn("bullet")
    bullet:set_placement(-128, -128)

    bullet:on_update(function(self)
      if self.x > 1200 then
        print("self x " .. self.x)
        local message = Mail.new(0, "bullet", "hit")
        postal:post(message)

        bullet:unset_action()
        bullet:set_placement(-128, -128)
        table.insert(bullet_pool, bullet)
      end
    end)

    table.insert(bullet_pool, bullet)
  end
end

local function fire()
  if #bullet_pool > 0 then
    local bullet = table.remove(bullet_pool)
    local x, y = (player.x + player.size.width) - 30, player.y + 30
    local offset_y = (math.random(-2, 2)) * 20

    bullet:set_placement(x, y + offset_y)
    bullet:set_velocity(Vector2D.new(0.6, 0))
    bullet:set_action("shoot")

    local sound = "bomb" .. math.random(1, 2)
    soundmanager:play(sound)
  end
end

create_bullet_pool(3)


player:on_update(function(self)
  local velocity = Vector2D.new(0, 0)

  if engine:is_keydown(KeyEvent.a) then
    velocity.x = -.4
    -- octopus:set_action("attack")
  elseif engine:is_keydown(KeyEvent.d) then
    velocity.x = .4
    -- octopus:set_action("dead")
  end

  if engine:is_keydown(KeyEvent.space) then
    if not state.space then
      fire()
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
