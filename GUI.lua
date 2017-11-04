local GUI = {}

local Util = require("Util")
local menu = require("AbsMenu")

local colors = Util.colors
local keys = Util.keys
local actions = Util.actions

GUI.main_color = colors.WHITE

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
   for k in pairs(colors) do
      table.insert(keyset, k)
   end
   return colors[keyset[love.math.random(#keyset)]]
end

function GUI.draw_HUD(w, h, snake)
   -- TODO
end

function GUI.draw_field(x, y, w, h, field)
   for i=1, Util.field_w do
      for j=1, Util.field_h do
         if field[i][j] then
            love.graphics.setColor(unpack(GUI.random_color()))
            love.graphics.rectangle("fill", (i*Util.sqr_size-Util.sqr_size)+x, (j*Util.sqr_size-Util.sqr_size)+y, Util.sqr_size, Util.sqr_size)
         end
      end
   end
end

function GUI.create_main_menu(x, y, w, h)
   local main_menu = menu.new_menu(x, y, w, h)
   local buttons = {
      {'b_singleplr', "Single Player"},
      {'b_multip', "Multiplayer"},
      {'b_opts', "Options"},
      {'b_ranks', "Rankings"},
      {'b_quit', "Quit"},
   }
   for _, item in ipairs(buttons) do
      item[3] = {
         label_color = {
            focused = colors.BLACK,
         },
         fill_colors = {
            default = colors.BLACK,
            focused = colors.WHITE,
            disabled = colors.BLACK,
         },
         outline_colors = {
            default = colors.WHITE,
            focused = colors.WHITE,
            disabled = colors.BLACK,
         },
      }
      main_menu:add_button(unpack(item))
   end
   GUI.main_menu = main_menu
   return GUI.main_menu
end

function GUI.create_death_menu(w, h, score)
   local death_menu = menu.new_menu(0, 0, w, h)
   death_menu:add_label('dead', "Game over")
   death_menu:add_label('score', "Score: "..score)
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
   love.graphics.setColor(unpack(colors.WHITE))
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
   love.graphics.setColor(unpack(colors.BLACK))
   love.graphics.rectangle("fill", box_x, box_y, box_w, box_h)
   love.graphics.setColor(unpack(GUI.main_color))
   love.graphics.draw(title, title_x, title_y, nil, nil, nil, title_w/2, title_h/2)
   return GUI.main_menu
end

function GUI.draw_death_menu(w, h)
   GUI.death_menu:run()
--   love.graphics.rectangle("line", w/2-305, h/2-57, 620, 115)
--   love.graphics.rectangle("line", w/2-305, h/2-57, 620, 115)
--   love.graphics.setColor(unpack(colors.BLACK))
--   love.graphics.rectangle("fill", w/2-305, h/2-57, 620, 115)
--   love.graphics.setColor(unpack(GUI.main_color))
--   love.graphics.rectangle("line", w/2-100, h/2+50, 200, 40)
--   love.graphics.rectangle("line", w/2-100, h/2+50, 200, 40)
--   love.graphics.setColor(unpack(colors.BLACK))
--   love.graphics.rectangle("fill", w/2-100, h/2+50, 200, 40)
--   love.graphics.setColor(unpack(GUI.main_color))
--   love.graphics.setFont(love.graphics.newFont(100))
--   love.graphics.print("Game Over", w/2-280, h/2-55)
--   love.graphics.setFont(love.graphics.newFont(20))
--   love.graphics.print("Score: "..score, w/2-48, h/2+59)
   return GUI.death_menu
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

function GUI.run(snake, field)
   if not Util.control_vars.in_game and not Util.control_vars.on_death then
      return GUI.draw_main_menu()
   else
      if not Util.control_vars.on_death then 
         GUI.draw_HUD(0, 0, GUI.w, GUI.h, #snake:get_segments()-Util.initial_size, Util.hud_height) -- TODO
         GUI.draw_field(0, Util.hud_height, GUI.w, GUI.h-Util.hud_height, field, Util.sqr_size) -- this one is handled entirely in GUI
         if Util.control_vars.on_pause then
            return GUI.pause_menu:draw(GUI.w, GUI.h) -- must merely draw menu created on the top of the code
         end
         if Util.control_vars.is_mute then
            love.graphics.setFont(love.graphics.newFont(40))
            love.graphics.print("MUTE", GUI.w-117, 0)
         end
      else
         GUI.create_death_menu(GUI.w, GUI.h, #snake:get_segments()-Util.initial_size)
         return GUI.draw_death_menu(GUI.w, GUI.h) -- must merely draw menu created on the top of the code
      end
   end
end

return GUI
