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

function GUI.create_main_menu(x, y, w, h)
   local main_menu = menu.new_menu(x, y, w, h)
   --main_menu:add_label('title', "Snakey")
   local buttons = {
      {'single', "Single Player"},
      {'multi', "Multiplayer"},
      {'opts', "Options"},
      {'ranks', "Rankings"},
      {'quit', "Quit"},
   }
   for _, item in ipairs(buttons) do
      main_menu:add_button(unpack(item))
   end
   GUI.main_menu = main_menu
   return GUI.main_menu
end

function GUI.create_death_menu(w, h)
   local death_menu
   -- TODO
   GUI.death_menu = death_menu
   return GUI.death_menu
end

function GUI.create_pause_menu(w, h)
   local pause_menu
   -- TODO
   GUI.pause_menu = pause_menu
   return GUI.pause_menu
end

--function GUI.main_menu()
--   GUI.main_menu:run()
   -- must merely call main_menu:draw()
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

function GUI.death_menu(w, h, score)
   -- must merely call death_menu:draw()
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

function GUI.pause_menu(w, h)
   -- must merely call pause_menu:draw()
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
