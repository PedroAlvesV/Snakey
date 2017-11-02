local GUI = require 'GUI'
local Util = require 'Util'

local Snake = require 'Snake'
local Fruit = require 'Fruit'

local w, h = love.window.getMode()
local sqr_size = 20
local initial_size = 4
local v = 0.05

local control_vars = {
   debug = false,
   is_mute = false,
   on_pause = false,
   on_main_menu = false,
   on_death = false,
}

local field = {}
local snake, fruit, sfx

local current_screen

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
         fruit:set_X(love.math.random(2, (w/sqr_size)-1))
         fruit:set_Y(love.math.random(2, (h/sqr_size)-1))
      end
      if reset then
         i = 1
      end
   end
   return fruit
end

local function start(first_time)

   GUI.create_main_menu(0, 200, w, h-200)
   GUI.w, GUI.h = w, h
   
   -- sets field
   for i=1, w/sqr_size do
      field[i] = {}
      for j=1, h/sqr_size do
         field[i][j] = i == 1 or j == 1 or i == w/sqr_size or j == h/sqr_size
      end
   end

   -- sets snake and fruit
   snake = Snake.new(w/sqr_size/2, h/sqr_size/2)
   fruit = Fruit.new(love.math.random(2, (w/sqr_size)-1), love.math.random(2, (h/sqr_size)-1))
   fruit = valid_fruit(snake, fruit)

   for i=1, initial_size-1 do
      snake:add_segment()
   end
   for _, segment in ipairs(snake:get_segments()) do
      field[segment.x][segment.y] = true
   end

   -- plays start tune
   if not control_vars.is_mute and not first_time then
      sfx.inicio:play()
   end

end

local function move_snake(v)
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
   love.timer.sleep(v)
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
   fruit:set_X(love.math.random(2, (w/sqr_size)-1))
   fruit:set_Y(love.math.random(2, (h/sqr_size)-1))
   return fruit
end

local function die()
   control_vars.on_death = true
   control_vars.on_main_menu = false
   if not control_vars.is_mute then
      sfx.toque:play()
   end
end

function love.load()
   start(true)
end

function love.keypressed(key)
   local action = current_screen:process_key(key)
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
--      if control_vars.on_main_menu then
--         control_vars.on_pause = not control_vars.on_pause
--      else
--         if control_vars.on_death then
--            control_vars.on_death = not control_vars.on_death
--         end
--         control_vars.on_main_menu = not control_vars.on_death
--         start(false)
--      end
--   end
--   if key == ('\'') then
--      control_vars.debug = not control_vars.debug
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
--      if control_vars.on_main_menu then
--         control_vars.on_main_menu = false
--         control_vars.on_pause = false
--         control_vars.on_death = false
--      else
--         love.window.close()
--      end
--   end
end

function love.update(dt)
   if control_vars.on_main_menu then
      if not control_vars.on_pause and not control_vars.on_death then
         for i=1, w/sqr_size do
            for j=1, h/sqr_size do
               field[i][j] = i == 1 or j == 1 or i == w/sqr_size or j == h/sqr_size
            end
         end
         field[fruit:get_X()][fruit:get_Y()] = true
         if snake:get_X(1) > 1 and snake:get_Y(1) > 1 and snake:get_X(1) < w/sqr_size and snake:get_Y(1) < h/sqr_size then
            for i, segment in ipairs(snake:get_segments()) do
               if i ~= 1 then
                  if segment.x == snake:get_X(1) and segment.y == snake:get_Y(1) then
                     die()
                  end
               end
            end
            move_snake(v)
         else
            die()
         end
         if snake:get_X(1) == fruit:get_X() and snake:get_Y(1) == fruit:get_Y() then
            snake:add_segment()
            apply_effect(fruit)
            fruit = valid_fruit(snake, reset_fruit(fruit))
            if not control_vars.is_mute then
               sfx.ponto:play()
            end
         end
      end
   end
end

function love.draw()
   current_screen = GUI.run(control_vars, snake, initial_size, field, sqr_size)
end
