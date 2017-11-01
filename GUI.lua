local GUI = {}

local Util = require("Util")
local menu = require("AbsMenu")

GUI.colors = Util.colors

GUI.main_color = GUI.colors.WHITE

function GUI.set_main_color(color)
   for i in ipairs(color) do
      if color[i] < 0 or color[i] > 255 then
         return false
      end
   end
   GUI.main_color = color
   return true
end

function GUI.get_main_color()
   return GUI.main_color
end

function GUI.random_color()
   local keyset = {}
   for k in pairs(GUI.colors) do
      table.insert(keyset, k)
   end
   return GUI.colors[keyset[love.math.random(#keyset)]]
end

function GUI.draw_HUD(w, h, snake, hud_height)
   -- TODO
end

function GUI.draw_field(w, h, field, sqr_size)
   for i=1, w/sqr_size do
      for j=1, h/sqr_size do
         if field[i][j] then
            --love.graphics.setColor(unpack(GUI.random_color()))
            love.graphics.rectangle("fill", i*sqr_size-sqr_size, j*sqr_size-sqr_size, sqr_size, sqr_size)
         end
      end
   end
end

function GUI.create_main_screen(w, h)
   local main_screen = menu.new_screen(w, h)
   main_screen:set_background_color(GUI.colors.BLACK)
   main_screen:add_label('title', "Snakey")
   local buttons = {
      {'single', "Single Player"},
      {'multi', "Multiplayer"},
      {'opts', "Options"},
      {'ranks', "Rankings"},
      {'quit', "Quit"},
   }
   for _, item in ipairs(buttons) do
      main_screen:add_button(unpack(item))
   end
   GUI.main_screen = main_screen
   return GUI.main_screen
end

function GUI.create_death_screen(w, h)
   local death_screen
   -- TODO
   GUI.death_screen = death_screen
   return GUI.death_screen
end

function GUI.create_pause_screen(w, h)
   local pause_screen
   -- TODO
   GUI.pause_screen = pause_screen
   return GUI.pause_screen
end

--function GUI.main_screen()
--   GUI.main_screen:run()
   -- must merely call main_screen:draw()
--   love.graphics.rectangle("line", w/2-195, h/2-57, 381, 115)
--   love.graphics.rectangle("line", w/2-195, h/2-57, 381, 115)
--   love.graphics.setColor(unpack(colors.BLACK))
--   love.graphics.rectangle("fill", w/2-195, h/2-57, 381, 115)
--   love.graphics.setColor(unpack(GUI.main_color))
--   love.graphics.rectangle("line", w/2-160, h/2+50, 314, 40)
--   love.graphics.rectangle("line", w/2-160, h/2+50, 314, 40)
--   love.graphics.setColor(unpack(colors.BLACK))
--   love.graphics.rectangle("fill", w/2-160, h/2+50, 314, 40)
--   love.graphics.setColor(unpack(GUI.main_color))
--   love.graphics.setFont(love.graphics.newFont(100))
--   love.graphics.print("SNAKE", w/2-171, h/2-55)
--   love.graphics.setFont(love.graphics.newFont(20))
--   love.graphics.print("Press Space to Start", w/2-108, h/2+59)
--end

function GUI.death_screen(w, h, score)
   -- must merely call death_screen:draw()
   love.graphics.rectangle("line", w/2-305, h/2-57, 620, 115)
   love.graphics.rectangle("line", w/2-305, h/2-57, 620, 115)
   love.graphics.setColor(unpack(colors.BLACK))
   love.graphics.rectangle("fill", w/2-305, h/2-57, 620, 115)
   love.graphics.setColor(unpack(GUI.main_color))
   love.graphics.rectangle("line", w/2-100, h/2+50, 200, 40)
   love.graphics.rectangle("line", w/2-100, h/2+50, 200, 40)
   love.graphics.setColor(unpack(colors.BLACK))
   love.graphics.rectangle("fill", w/2-100, h/2+50, 200, 40)
   love.graphics.setColor(unpack(GUI.main_color))
   love.graphics.setFont(love.graphics.newFont(100))
   love.graphics.print("Game Over", w/2-280, h/2-55)
   love.graphics.setFont(love.graphics.newFont(20))
   love.graphics.print("Score: "..score, w/2-48, h/2+59)
end

function GUI.pause_screen(w, h)
   -- must merely call pause_screen:draw()
   love.graphics.rectangle("line", w/2-195, h/2-57, 381, 115)
   love.graphics.rectangle("line", w/2-195, h/2-57, 381, 115)
   love.graphics.setColor(unpack(colors.BLACK))
   love.graphics.rectangle("fill", w/2-195, h/2-57, 381, 115)
   love.graphics.setColor(unpack(GUI.main_color))
   love.graphics.rectangle("line", w/2-160, h/2+50, 314, 40)
   love.graphics.rectangle("line", w/2-160, h/2+50, 314, 40)
   love.graphics.setColor(unpack(colors.BLACK))
   love.graphics.rectangle("fill", w/2-160, h/2+50, 314, 40)
   love.graphics.setColor(unpack(GUI.main_color))
   love.graphics.setFont(love.graphics.newFont(100))
   love.graphics.print("PAUSE", w/2-170, h/2-55)
   love.graphics.setFont(love.graphics.newFont(20))
   love.graphics.print("Press Space to Resume", w/2-120, h/2+59)
end

return GUI
