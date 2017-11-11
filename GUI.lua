local GUI = {}

local Util = require("Util")
local menu = require("AbsMenu")

local colors = Util.colors
local keys = Util.keys
local actions = Util.actions
local control_vars = Util.control_vars

GUI.main_color = Util.settings.main_color
GUI.create_functions = {}

function GUI.draw_HUD(x, y, score)
   local text_h = Util.hud_height*0.95
   local score_text = love.graphics.newText(love.graphics.newFont(text_h), "Score: "..score.." pts")
   love.graphics.setColor(Util.settings.main_color)
   if control_vars.is_mute then
      local mute_text = love.graphics.newText(love.graphics.newFont(text_h), "MUTE")
      love.graphics.draw(mute_text, Util.settings.resolution_w-mute_text:getWidth(), y)
   end
   love.graphics.draw(score_text, x, y)
end

function GUI.draw_field(x, y, w, h, field)
   for i=1, Util.field_w do
      for j=1, Util.field_h do
         if field[i][j] then
            --love.graphics.setColor(unpack(Util.random_color()))
            love.graphics.rectangle("fill", (i*Util.sqr_size-Util.sqr_size)+x, (j*Util.sqr_size-Util.sqr_size)+y, Util.sqr_size, Util.sqr_size)
         end
      end
   end
end

function GUI.create_functions.main_menu()
   local shift = 200
   local main_menu = menu.new_menu(0, shift, Util.settings.resolution_w, Util.settings.resolution_h-shift)
   local colors_props = {
      label_color = {
         default = Util.settings.main_color,
         focused = colors.BLACK,
         disabled = colors.GRAY,
      },
      fill_colors = {
         default = colors.BLACK,
         focused = Util.settings.main_color,
         disabled = colors.BLACK,
      },
      outline_colors = {
         default = Util.settings.main_color,
         focused = Util.settings.main_color,
         disabled = colors.GRAY,
      },
   }
   local function singleplr_func()
      Util.reset_game()
      Util.current_screen = Util.screens.on_singleplayer_game
   end
   local function goto_options()
      GUI.create_functions.options_menu()
      Util.current_screen = Util.screens.on_options
   end
   local function goto_ranking()
      GUI.create_functions.ranking_menu()
      Util.current_screen = Util.screens.on_ranking
   end
   local buttons = {
      {'bt_singleplr', "Single Player", colors_props, singleplr_func},
      {'bt_multip', "Multiplayer", colors_props},
      {'bt_opts', "Options", colors_props, goto_options},
      {'bt_ranks', "Ranking", colors_props, goto_ranking},
      {'bt_quit', "Quit", colors_props, function() love.window.close() end},
   }
   for _, item in ipairs(buttons) do
      main_menu:add_button(unpack(item))
   end
   main_menu:set_enabled('bt_multip', false)
   GUI.main_menu = main_menu
   return GUI.main_menu
end

function GUI.create_functions.pause_menu()
   local pause_menu = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   pause_menu:add_label('title', "Pause", {font = love.graphics.newFont(100), color = Util.settings.main_color, underline = true})
   local colors_props = {
      label_color = {
         default = Util.settings.main_color,
         focused = colors.BLACK,
      },
      fill_colors = {
         default = colors.BLACK,
         focused = Util.settings.main_color,
      },
      outline_colors = {
         default = Util.settings.main_color,
         focused = Util.settings.main_color,
      },
   }
   local buttons = {
      {'bt_resume', "Resume", colors_props, function() Util.current_screen = Util.screens.on_singleplayer_game end},
      {'bt_quit', "Quit", colors_props, function() Util.current_screen = Util.screens.on_death end},
   }
   for _, item in ipairs(buttons) do
      pause_menu:add_button(unpack(item))
   end
   pause_menu:set_focus(2)
   GUI.pause_menu = pause_menu
   return GUI.pause_menu
end

function GUI.create_functions.death_menu()
   local death_menu = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   local properties = {font = love.graphics.newFont(50), color = Util.settings.main_color}
   death_menu:add_label('title', "Game Over", properties)
   death_menu:add_label('score', "Your score: "..Util.score.." pts", {color = Util.settings.main_color})
   GUI.death_menu = death_menu
   return GUI.death_menu
end

function GUI.create_functions.options_menu()
   local options_menu = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   local properties = {font = love.graphics.newFont(50), color = Util.settings.main_color, underline = true}
   options_menu:add_label('title', "Options", properties)
   local res_list = {"800 x 600", "1024 x 768", "1366 x 768"}
   options_menu:add_selector('sl_resolution', "Resolution:", res_list, 1, Util.settings.main_color)
   options_menu:add_checkbox('chk_fullscreen', "Fullscreen",
      {
         box_align = 'right',
         state = Util.settings.fullscreen,
         text_colors = {
            default = Util.settings.main_color,
            focused = Util.settings.main_color,
         },
         fill_box_colors = {
            default = Util.settings.main_color,
            focused = Util.settings.main_color,
         },
         outline_box_colors = { focused = Util.settings.main_color },
      }
   )
   local colors_list = {}
   for i, value in ipairs(Util.game_pallete) do
      colors_list[i] = value[2]
   end
   local selected_color_index = 1
   for i, value in ipairs(Util.game_pallete) do
      if Util.settings.main_color == Util.colors[value[1]] then
         selected_color_index = i
         break
      end
   end
   options_menu:add_selector('sl_color', "Color scheme:", colors_list, selected_color_index, Util.settings.main_color)
   local volume_table = {}
   for i=1, 11 do volume_table[i] = i-1 end
   options_menu:add_selector('sl_volume', "Volume:", volume_table, Util.settings.volume+1, Util.settings.main_color)
   local function go_back()
      local data = options_menu:get_data()
      Util.apply_settings(data, GUI.create_functions)
      Util.current_screen = Util.screens.on_main
   end
   options_menu:add_button('bt_back', "Back",
      {
         label_color = {
            default = Util.settings.main_color,
            focused = colors.BLACK,
         },
         fill_colors = {
            default = colors.BLACK,
            focused = Util.settings.main_color,
         },
         outline_colors = {
            default = Util.settings.main_color,
            focused = Util.settings.main_color,
         },
      },
      go_back)
   GUI.options_menu = options_menu
   return GUI.options_menu
end

function GUI.create_functions.ranking_menu()
   local ranking_menu = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   ranking_menu:add_label('title', "Ranking", {
         color = Util.settings.main_color,
         font = love.graphics.newFont(50),
         underline = true,
      })
   local ranking_table = Util.load_table('ranking.sav')
   for i, entry in ipairs(ranking_table) do
      ranking_menu:add_label('n'..i, i..'. '..entry[1].."\t\t\t"..entry[2].." pts.", {color = Util.settings.main_color})
   end
   ranking_menu:add_button('bt_back', "Back", {
         label_color = {
            default = Util.settings.main_color,
            focused = colors.BLACK,
         },
         fill_colors = {
            default = colors.BLACK,
            focused = Util.settings.main_color,
            disabled = colors.BLACK,
         },
         outline_colors = {
            default = Util.settings.main_color,
            focused = Util.settings.main_color,
            disabled = colors.BLACK,
         },
      },
      function() Util.current_screen = Util.screens.on_main end)
   GUI.ranking_menu = ranking_menu
   return GUI.ranking_menu
end

function GUI.draw_main_menu()
   local action = GUI.main_menu:run()
   love.graphics.setColor(unpack(Util.settings.main_color))
   local title = love.graphics.newText(love.graphics.newFont(100), "Snakey")
   local title_w = title:getWidth()
   local title_h = title:getHeight()
   local title_x = math.ceil(Util.settings.resolution_w/2)
   local title_y = math.ceil(133)
   local box_w = title_w+30
   local box_h = title_h+20
   local box_x = title_x - box_w/2
   local box_y = title_y - box_h/2
   love.graphics.rectangle("line", box_x, box_y, box_w, box_h)
   love.graphics.rectangle("line", box_x, box_y, box_w, box_h)
   love.graphics.setColor(unpack(colors.BLACK))
   love.graphics.rectangle("fill", box_x, box_y, box_w, box_h)
   love.graphics.setColor(unpack(Util.settings.main_color))
   love.graphics.draw(title, title_x, title_y, nil, nil, nil, title_w/2, title_h/2)
   return action
end

function GUI.draw_pause_menu()
   return GUI.pause_menu:run()
end

function GUI.draw_death_menu()
   return GUI.death_menu:run(function() Util.current_screen = Util.screens.on_main end)
end

function GUI.draw_options_menu()
   local action = GUI.options_menu:run()
   local _, is_fullscreen = GUI.options_menu:get_value('chk_fullscreen')
   GUI.options_menu:set_enabled('sl_resolution', not is_fullscreen)
   return action
end

function GUI.draw_ranking_menu()
   return GUI.ranking_menu:run()
end

return GUI
