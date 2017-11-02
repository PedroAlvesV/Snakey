local GUI = {}

local Util = require("Util")
local menu = require("AbsMenu")

GUI.colors = Util.colors

GUI.main_color = GUI.colors.WHITE

GUI.hud_height = 50

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
   local buttons = {
      {'single', "Single Player"},
      {'multi', "Multiplayer"},
      {'opts', "Options"},
      {'ranks', "Rankings"},
      {'quit', "Quit"},
   }
   for _, item in ipairs(buttons) do
      item[3] = {
         label_color = {
            focused = GUI.colors.BLACK,
         },
         fill_colors = {
            default = GUI.colors.BLACK,
            focused = GUI.colors.GRAY,
            disabled = GUI.colors.BLACK,
         },
         outline_colors = {
            default = GUI.colors.WHITE,
            focused = GUI.colors.GRAY,
            disabled = GUI.colors.BLACK,
         },
      }
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

function GUI.draw_main_menu()
   GUI.main_menu:run()
   love.graphics.setColor(unpack(GUI.colors.WHITE))
   local title = love.graphics.newText(love.graphics.newFont(100), "Snakey")
   local title_w = title:getWidth()
   local title_h = title:getHeight()
   local title_x = math.ceil(GUI.w/2)
   local title_y = math.ceil(GUI.w/6)
   local box_w = title_w+30
   local box_h = title_h+20
   local box_x = title_x - box_w/2
   local box_y = title_y - box_h/2
   love.graphics.rectangle("line", box_x, box_y, box_w, box_h)
   love.graphics.rectangle("line", box_x, box_y, box_w, box_h)
   love.graphics.setColor(unpack(GUI.colors.BLACK))
   love.graphics.rectangle("fill", box_x, box_y, box_w, box_h)
   love.graphics.setColor(unpack(GUI.main_color))
   love.graphics.draw(title, title_x, title_y, nil, nil, nil, title_w/2, title_h/2)
end

function GUI.death_menu(w, h, score)
   -- must merely call death_menu:draw()
   love.graphics.rectangle("line", w/2-305, h/2-57, 620, 115)
   love.graphics.rectangle("line", w/2-305, h/2-57, 620, 115)
   love.graphics.setColor(unpack(GUI.colors.BLACK))
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

function GUI.run(control_vars, snake, initial_size, field, sqr_size)
   if not control_vars.on_main_menu and not control_vars.on_death then
      GUI.draw_main_menu()
   else
      if not control_vars.on_death then 
         GUI.draw_HUD(GUI.w, GUI.h, snake, GUI.hud_height) -- TODO
         GUI.draw_field(GUI.w, GUI.h, field, sqr_size) -- this one is handled entirely in GUI
         if control_vars.on_pause then
            GUI.pause_menu:draw(GUI.w, GUI.h) -- must merely draw menu created on the top of the code
         end
         if control_vars.is_mute then
            love.graphics.setFont(love.graphics.newFont(40))
            love.graphics.print("MUTE", GUI.w-117, 0)
         end
      else
         GUI.death_menu:draw(GUI.w, GUI.h, #snake:get_segments()-initial_size) -- must merely draw menu created on the top of the code
      end
   end
end

return GUI
