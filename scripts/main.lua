local helpers = require("helpers")

helpers.hello()

_G.engine = EngineFactory.new()
    :with_title("Mega Rick")
    :with_width(1920)
    :with_height(1080)
    -- :set_width(1280)
    -- :set_height(720)
    -- :with_gravity(980.2)
    :with_gravity(0)
    :with_fullscreen(false)
    :create()

function setup()
  print("setup")
end

function loop()
  print("on loop")
end

local postal = PostalService.new()
local timemanager = TimeManager.new()
local entitymanager = engine:entitymanager()
local statemanager = engine:statemanager()
local fontfactory = engine:fontfactory()
local overlay = engine:overlay()
local resourcemanager = engine:resourcemanager()
local soundmanager = engine:soundmanager()
local scenemanager = engine:scenemanager()

resourcemanager:prefetch({
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

scenemanager:set("ship")

local font = fontfactory:get("fixedsys")

local label = overlay:create(WidgetType.label)
label:set_font(font)
label:set("Hello World", 20, 20)

local candle1 = entitymanager:spawn("candle")
local candle2 = entitymanager:spawn("candle")
local octopus = entitymanager:spawn("octopus")
local player = entitymanager:spawn("player")
local princess = entitymanager:spawn("princess")
local floor = entitymanager:spawn("floor")

local io = Socket.new("ws://localhost:3000/socket.io/?transport=websocket&EIO=4")
io:connect()
-- scenemanager:set("ship")

-- local life = 20
-- local shooting = false
-- local bullet_pool = {}
-- local explosion_pool = {}

-- for _ = 1, 3 do
--   local bullet = entitymanager:spawn("bullet")
--   bullet:set_placement(-128, -128)
--   bullet:on_update(function(self)
--     if self.x > 1200 then
--       postal:post(Mail.new(0, "bullet", "hit"))
--       bullet:unset_action()
--       bullet:set_placement(-1024, -1024)
--       table.insert(bullet_pool, bullet)
--     end
--   end)
--   table.insert(bullet_pool, bullet)
-- end

-- for _ = 1, 9 do
--   local explosion = entitymanager:spawn("explosion")
--   explosion:set_placement(-1024, -1024)
--   table.insert(explosion_pool, explosion)
-- end

-- --
-- --
-- --
-- --
-- --

-- -- print("1")
-- -- local widget = overlay:create(WidgetType.label)
-- -- print("2")
-- -- print(widget)
-- -- print("3")
-- -- local label = to_label(widget)
-- -- print("4")
-- -- print(label)
-- -- print(5)
-- -- print(6)
-- -- print(font)
-- -- print(7)
-- --
-- -- local font = fontfactory:get("fixedsys")
-- -- print("font")
-- -- print(font)
-- -- local label = Label.new()
-- -- label:set("Hello world!", 10, 10)
-- -- label:set_font(font)
-- -- overlay:add(label)
-- -- label:set("Rodrigo")
-- -- overlay:remove(label)

-- -- local label = overlay:create(WidgetType.label)
-- -- label:set_font(font)
-- -- label:set("Hello World", 20, 20)
-- --overlay:destroy(label)
-- -- if label then
-- --   print("Label created successfully!")
-- --   label:set_font(fontfactory:get("fixedsys"))
-- --   label:set("Hello world!", 10, 10)
-- -- else
-- --   print("Failed to cast widget to label")
-- -- end

-- -- local label = to_label(overlay:create(WidgetType.label))
-- -- local font = fontfactory:get("fixedsys")
-- -- print(">>>>>>>>>>>")
-- -- print(label)
-- -- print(font)
-- -- print(">>>>>>>>>>>")
-- -- label:set_font(fontfactory:get("fixedsys"))
-- -- label:set("Hello world!", 10, 10)
-- --
-- --
-- --
-- --
-- --

-- local function bomb()
--   if #explosion_pool > 0 then
--     local explosion = table.remove(explosion_pool)
--     local x = octopus.x
--     local y = player.y
--     local offset_x = (math.random(-2, 2)) * 30
--     local offset_y = (math.random(-2, 2)) * 30

--     explosion:set_placement(x + offset_x, y + offset_y)
--     explosion:set_action("default")
--     explosion:on_animationfinished(function(self)
--       self:unset_action()
--       self:set_placement(-1024, -1024)
--       table.insert(explosion_pool, self)
--     end)
--   end
-- end

-- local timer = false

octopus:set_action("idle")
octopus:set_placement(1200, 622)
-- octopus:on_mail(function(self, message)
--   if message == 'hit' then
--     bomb()
--     octopus:set_action("attack")
--     life = life - 1
--     if life <= 0 then
--       self:set_action("dead")

--       if not timer then
--         timemanager:singleshot(3000, function()
--           local function destroy(pool)
--             for i = #pool, 1, -1 do
--               entitymanager:destroy(pool[i])
--               table.remove(pool, i)
--             end
--           end

--           destroy(bullet_pool)
--           destroy(explosion_pool)

--           entitymanager:destroy(octopus)
--           entitymanager:destroy(player)
--           entitymanager:destroy(princess)
--           entitymanager:destroy(candle1)
--           entitymanager:destroy(candle2)

--           engine:flush()
--           engine:prefetch({ "blobs/gameover.png" })
--           engine:set_scene("gameover")
--         end)

--         timer = true
--       end
--     end
--   end
-- end)

player:set_action("idle")
player:set_placement(30, 794)

princess:set_action("default")
princess:set_placement(1600, 806)

candle1:set_action("default")
candle1:set_placement(60, 100)

candle2:set_action("default")
candle2:set_placement(1800, 100)

floor:set_placement(-16192, 923)

local sound = "bomb" .. math.random(1, 2)
soundmanager:play(sound)

-- local function fire()
--   print("jump!")
--   -- if #bullet_pool > 0 then
--   --   local bullet = table.remove(bullet_pool)
--   --   local x = (player.x + player.size.width) - 30
--   --   local y = player.y + 30
--   --   local offset_y = (math.random(-2, 2)) * 20

--   --   bullet:set_placement(x, y + offset_y)
--   --   -- bullet:set_velocity(Vector2D.new(0.6, 0))
--   --   bullet:set_action("default")

--   local sound = "bomb" .. math.random(1, 2)
--   soundmanager:play(sound)
--   -- end
-- end

player:on_update(function(self)
  if statemanager:is_keydown(KeyEvent.a) then
    self:set_flip(Flip.horizontal)
    self:set_action("run")
    self:move(-300, self.velocity.y)
  elseif statemanager:is_keydown(KeyEvent.d) then
    self:set_flip(Flip.none)
    self:set_action("run")
    self:move(300, self.velocity.y)
  else
    self:set_action("idle")
    self:move(0, self.velocity.y)
  end

  if statemanager:is_keydown(KeyEvent.space) then -- and self.velocity.y == 0 then
    -- fire()
    --
    print("before")
    io:emit("messsage", "hello world")
    print("after")
    self:move(self.velocity.x, -1000)
  end
end)

-- engine:run()

function run()
  engine:run()
end
