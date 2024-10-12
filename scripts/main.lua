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
  "blobs/ship.png"
})

engine:set_scene("ship")

local postal = PostalService.new()
local timemanager = TimeManager.new()
local soundmanager = engine:soundmanager()
local octopus = engine:spawn("octopus")
local player = engine:spawn("player")
local princess = engine:spawn("princess")
local candle1 = engine:spawn("candle")
local candle2 = engine:spawn("candle")

local life = 20
local shooting = false
local bullet_pool = {}
local explosion_pool = {}

for _ = 1, 3 do
  local bullet = engine:spawn("bullet")
  bullet:set_placement(-128, -128)
  bullet:on_update(function(self)
    if self.x > 1200 then
      postal:post(Mail.new(0, "bullet", "hit"))
      bullet:unset_action()
      bullet:set_placement(-128, -128)
      table.insert(bullet_pool, bullet)
    end
  end)
  table.insert(bullet_pool, bullet)
end

for _ = 1, 9 do
  local explosion = engine:spawn("explosion")
  explosion:set_placement(-128, -128)
  table.insert(explosion_pool, explosion)
end

local function bomb()
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

octopus:set_action("idle")
octopus:set_placement(1200, 620)
octopus:on_mail(function(self, message)
  if message == 'hit' then
    bomb()
    octopus:set_action("attack")
    life = life - 1
    if life <= 0 then
      self:set_action("dead")

      timemanager:set(3000, function()
        local function destroy(pool)
          for i = #pool, 1, -1 do
            engine:destroy(pool[i])
            table.remove(pool, i)
          end
        end

        destroy(bullet_pool)
        destroy(explosion_pool)

        engine:destroy(octopus)
        engine:destroy(player)
        engine:destroy(princess)
        engine:destroy(candle1)
        engine:destroy(candle2)
      end)
    end
  end
end)

player:set_action("idle")
player:set_placement(30, 794)

princess:set_action("default")
princess:set_placement(1600, 806)

candle1:set_action("default")
candle1:set_placement(60, 100)

candle2:set_action("default")
candle2:set_placement(1800, 100)

local function fire()
  if #bullet_pool > 0 then
    local bullet = table.remove(bullet_pool)
    local x = (player.x + player.size.width) - 30
    local y = player.y + 30
    local offset_y = (math.random(-2, 2)) * 20

    bullet:set_placement(x, y + offset_y)
    bullet:set_velocity(Vector2D.new(0.6, 0))
    bullet:set_action("default")

    local sound = "bomb" .. math.random(1, 2)
    soundmanager:play(sound)
  end
end

player:on_update(function(self)
  local velocity = Vector2D.new(0, 0)

  if engine:is_keydown(KeyEvent.space) then
    if not shooting then
      fire()
      shooting = true
    end
  else
    shooting = false
  end

  if engine:is_keydown(KeyEvent.a) then
    velocity.x = -.4
  elseif engine:is_keydown(KeyEvent.d) then
    velocity.x = .4
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
