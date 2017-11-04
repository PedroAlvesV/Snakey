local GUI = require 'GUI'
local Util = require 'Util'

local Snake = require 'Snake'
local Fruit = require 'Fruit'

local field = {}
local snake, fruit, sfx

--GUI.set_main_color(GUI.colors.WHITE)

love.window.setTitle("Snakey")

sfx = {
   ponto = love.audio.newSource("/sfx/ponto.ogg", "static"),
   toque = love.audio.newSource("/sfx/toque.ogg", "static"),
   inicio = love.audio.newSource("/sfx/inicio.ogg", "static"),
}

local function valid_fruit(snake, fruit)
   for i=1, #snake:get_segments() do
      local reset = false
      while snake:get_X(i) == fruit:get_X() and snake:get_Y(i) == fruit:get_Y() do
         reset = true
         fruit:set_X(love.math.random(2, (Util.field_w)-1))
         fruit:set_Y(love.math.random(2, (Util.field_h)-1))
      end
      if reset then
         i = 1
      end
   end
   return fruit
end

local function start(first_time)

   GUI.create_main_menu(0, 200, Util.w, Util.h-200)
   GUI.w, GUI.h = Util.w, Util.h

   -- sets field
   for i=1, Util.field_w do
      field[i] = {}
      for j=1, Util.field_h do
         field[i][j] = i == 1 or j == 1 or i == Util.field_w or j == Util.field_h
      end
   end

   -- sets snake and fruit
   snake = Snake.new(math.ceil(Util.field_w/2), math.ceil(Util.field_h/2))
   fruit = Fruit.new(love.math.random(2, (Util.field_w)-1), love.math.random(2, (Util.field_h)-1))
   fruit = valid_fruit(snake, fruit)

   for i=1, Util.initial_size-1 do
      snake:add_segment()
   end
   for _, segment in ipairs(snake:get_segments()) do
      field[segment.x][segment.y] = true
   end

   -- plays start tune
   if not Util.control_vars.is_mute and not first_time then
      sfx.inicio:play()
   end

end

local function move_snake()
   local function follow_segment(index, direction)
      if index <= #snake:get_segments() then
         local segment = snake:get_segments()[index]
         if segment.direction == 'up' then
            snake:set_Y(index, snake:get_Y(index)-1)
         elseif segment.direction == 'down' then
            snake:set_Y(index, snake:get_Y(index)+1)
         elseif segment.direction == 'left' then
            snake:set_X(index, snake:get_X(index)-1)
         elseif segment.direction == 'right' then
            snake:set_X(index, snake:get_X(index)+1)
         end
         field[segment.x][segment.y] = true
         follow_segment(index+1, snake:get_direction(index))
         if index > 1 then
            snake:set_direction(index, direction)
         end
      end
   end
   follow_segment(1, snake:get_direction(1))
   love.timer.sleep(Util.velocity)
end

local function apply_effect(fruit)
   local effect = fruit:get_effect()
   if effect == 1 then
      return -- normal fruit, has no special effect
   elseif effect == 2 then
      -- adds several fake fruits
   elseif effect == 3 then
      -- hurts/cuts snake
   elseif effect == 4 then
      -- mirrors controls
   elseif effect == 5 then
      -- turns field
   elseif effect == 6 then
      -- adds fake/mimic snake
   elseif effect == 7 then
      -- speeds snake up
   elseif effect == 8 then
      -- makes snake walk backwards
   elseif effect == 9 then
      -- empty
   elseif effect == 10 then
      -- empty
   end
end

local function reset_fruit(fruit)
   fruit:set_X(love.math.random(2, (Util.field_w)-1))
   fruit:set_Y(love.math.random(2, (Util.field_h)-1))
   return fruit
end

local function die()
   Util.current_screen = Util.screens.on_death
   if not Util.control_vars.is_mute then
      sfx.toque:play()
   end
end

function love.load()
   start(true)
end

function love.keypressed(key)
   local action = current_screen:process_key(key)
   -- TODO
--   if key == ('m') then
--      control_vars.is_mute = not control_vars.is_mute
--   end
--   if key == ('kp-') then
--      v = v + 0.05
--   end
--   if key == ('kp+') then
--      if v > 0 then
--         v = v - 0.05
--      end
--   end
--   if key == ('space') then
--      if Util.control_vars.in_game then
--         Util.control_vars.on_pause = not Util.control_vars.on_pause
--      else
--         if Util.control_vars.on_death then
--            Util.control_vars.on_death = not Util.control_vars.on_death
--         end
--         Util.control_vars.in_game = not Util.control_vars.on_death
--         start(false)
--      end
--   end
--   if key == ('\'') then
--      Util.control_vars.debug = not Util.control_vars.debug
--   end
--   if key == ('up') or key == ('down') or key == ('left') or key == ('right') or key == ('w') or key == ('s') or key == ('a') or key == ('d') then
--      if key == ('w') then
--         key = 'up'
--      end
--      if key == ('s') then
--         key = 'down'
--      end
--      if key == ('a') then
--         key = 'left'
--      end
--      if key == ('d') then
--         key = 'right'
--      end
--      snake:set_direction(1, key)
--   end
--   if key == ('escape') then
--      if Util.control_vars.in_game then
--         Util.control_vars.in_game = false
--         Util.control_vars.on_pause = false
--         Util.control_vars.on_death = false
--      else
--         love.window.close()
--      end
--   end
end

function love.update(dt)
   if Util.current_screen == Util.screens.on_singleplayer_game then
      for i=1, Util.field_w do
         for j=1, Util.field_h do
            field[i][j] = i == 1 or j == 1 or i == Util.field_w or j == Util.field_h
         end
      end
      field[fruit:get_X()][fruit:get_Y()] = true
      if snake:get_X(1) > 1 and snake:get_Y(1) > 1 and snake:get_X(1) < Util.field_w and snake:get_Y(1) < Util.field_h then
         for i, segment in ipairs(snake:get_segments()) do
            if i ~= 1 then
               if segment.x == snake:get_X(1) and segment.y == snake:get_Y(1) then
                  die()
               end
            end
         end
         move_snake()
      else
         die()
      end
      if snake:get_X(1) == fruit:get_X() and snake:get_Y(1) == fruit:get_Y() then
         snake:add_segment()
         apply_effect(fruit)
         fruit = valid_fruit(snake, reset_fruit(fruit))
         if not Util.control_vars.is_mute then
            sfx.ponto:play()
         end
      end
   elseif Util.current_screen == Util.screens.on_multiplayer_game then
      -- TODO
   end
end

function love.draw()
   current_screen = GUI.run(snake, field)
end
