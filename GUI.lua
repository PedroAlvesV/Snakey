local GUI = {}

local Util = require("Util")
local menu = require("AbsMenu")

local colors = Util.colors
local keys = Util.keys
local actions = Util.actions
local control_vars = Util.control_vars

GUI.main_color = Util.settings.main_color
GUI.create_functions = {}

function GUI.draw_HUD(x, y)
   local text_h = Util.hud_height*0.95
   local name_text = love.graphics.newText(love.graphics.newFont(text_h), Util.game.player_nick)
   local score_text = love.graphics.newText(love.graphics.newFont(text_h), "Score: "..Util.game.score)
   love.graphics.setColor(Util.settings.main_color)
   love.graphics.draw(name_text, x, y)
   love.graphics.draw(score_text, Util.settings.resolution_w-score_text:getWidth(), y)
end

function GUI.draw_field(x, y, w, h, field)
   local sqr = Util.game.sqr_size
   local total_field_width = Util.field_w * sqr
   local total_field_height = Util.field_h * sqr
   for i=1, Util.field_w do
      for j=1, Util.field_h do
         if field[i][j] then
            --love.graphics.setColor(unpack(Util.random_color()))
            local rect_x = x + w/2 - total_field_width/2 + sqr*(i-1)
            local rect_y = y + h/2 - total_field_height/2 + sqr*(j-1)
            love.graphics.rectangle("fill", rect_x, rect_y, sqr, sqr)
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
   colors_props.label_color.disabled = colors.GRAY
   colors_props.fill_colors.disabled = colors.BLACK
   colors_props.outline_colors.disabled = colors.GRAY
   local function singleplr_func()
      GUI.create_functions.singleplayer_setup_menu_1()
      Util.current_screen = Util.screens.on_singleplayer_setup_1
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

function GUI.create_functions.singleplayer_setup_menu_1()
   local singleplayer_setup_menu_1 = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   singleplayer_setup_menu_1:add_label('title', "Game Setup",
      {font = love.graphics.newFont(50), color = Util.settings.main_color, underline = true})
   singleplayer_setup_menu_1:add_checkbox('chk_borderless', "Borderless field", {
         text_colors = {
            default = Util.settings.main_color,
            focused = Util.settings.main_color,
         },
         fill_box_colors = {
            default = Util.settings.main_color,
            focused = Util.settings.main_color,
         },
         outline_box_colors = { focused = Util.settings.main_color },
      })
   singleplayer_setup_menu_1:set_enabled('chk_borderless', false)
   singleplayer_setup_menu_1:add_selector('sl_size', "Field size:", {"Small", "Medium", "Large"}, 2, Util.settings.main_color)
   singleplayer_setup_menu_1:add_selector('sl_velocity', "Speed:", {"Slow", "Regular", "Quick"}, 2, Util.settings.main_color)
   local cancel_func = function()
      GUI.create_functions.main_menu()
      Util.current_screen = Util.screens.on_main
   end
   local goto_next = function()
      local data = singleplayer_setup_menu_1:get_data()
      local function apply_game_settings()
         local sqr_size = Util.settings.resolution_h*0.0333--20
         if data.sl_size.index == 1 then
            sqr_size = sqr_size + sqr_size/2
         elseif data.sl_size.index == 3 then
            sqr_size = sqr_size/2
         end
         local velocity = 0.05
         if data.sl_velocity.index == 1 then
            velocity = 0.065
         elseif data.sl_velocity.index == 3 then
            velocity = 0.025
         end
         Util.game = {
            sqr_size = sqr_size,
            velocity = velocity,
            initial_size = 4,
            score = 0,
         }
      end
      apply_game_settings()
      GUI.create_functions.singleplayer_setup_menu_2()
      Util.current_screen = Util.screens.on_singleplayer_setup_2
   end
   local bt_properties = {
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
   singleplayer_setup_menu_1:add_buttongroup('btgp_navigation', {"Cancel", "Next"},
      {bt_properties, bt_properties}, {cancel_func, goto_next})
   GUI.singleplayer_setup_menu_1 = singleplayer_setup_menu_1
   return GUI.singleplayer_setup_menu_1
end

function GUI.create_functions.singleplayer_setup_menu_2()
   local singleplayer_setup_menu_2 = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   singleplayer_setup_menu_2:add_label('title', "Game Setup",
      {font = love.graphics.newFont(50), color = Util.settings.main_color, underline = true})
   
   --singleplayer_setup_menu_2:add_textinput('input_nick', "Player:", Util.settings.main_color)
   
   singleplayer_setup_menu_2:add_selector('sl_skin', "Skin:", {"White", "Light Blue", "Magenta", "Yellow"}, 1, Util.settings.main_color)
   local back_func = function()
      Util.current_screen = Util.screens.on_singleplayer_setup_1
   end
   local start_game = function()
      local data = singleplayer_setup_menu_2:get_data()
      local function apply_game_settings()
         Util.game.player_nick = singleplayer_setup_menu_2:get_value('input_nick') or "Player 1"
         Util.game.skin = Util.settings.main_color
         local skin_value = singleplayer_setup_menu_2:get_value('sl_skin')
         for _, value in ipairs(Util.game_pallete) do
            if skin_value == value[2] then
               Util.game.skin = value[1]
               break
            end
         end
      end
      apply_game_settings()
      Util.reset_game()
      Util.current_screen = Util.screens.on_singleplayer_game
   end
   local bt_properties = {
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
   singleplayer_setup_menu_2:add_buttongroup('btgp_navigation', {"Back", "Start"},
      {bt_properties, bt_properties}, {back_func, start_game})
   
   GUI.singleplayer_setup_menu_2 = singleplayer_setup_menu_2
   return GUI.singleplayer_setup_menu_2
end

function GUI.create_functions.multiplayer_setup_menu_1()
   -- TODO
end

function GUI.create_functions.multiplayer_setup_menu_2()
   -- TODO
end

function GUI.create_functions.pause_menu()
   local pause_menu = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   pause_menu:add_label('title', "Pause", {font = love.graphics.newFont(75), color = Util.settings.main_color, underline = true})
   local quit_game = function()
      local is_highscore = Util.is_highscore()
      if is_highscore then
         Util.update_ranking()
      end
      GUI.create_functions.death_menu(is_highscore)
      Util.current_screen = Util.screens.on_death
   end
   local bt_properties = {
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
      {'bt_resume', "Resume", bt_properties, function() Util.current_screen = Util.screens.on_singleplayer_game end},
      {'bt_quit', "Quit", bt_properties, quit_game},
   }
   for _, item in ipairs(buttons) do
      pause_menu:add_button(unpack(item))
   end
   GUI.pause_menu = pause_menu
   return GUI.pause_menu
end

function GUI.create_functions.death_menu(is_highscore)
   local death_menu = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   local properties = {font = love.graphics.newFont(50), color = Util.settings.main_color}
   death_menu:add_label('title', "Game Over", properties)
   if is_highscore then
--      death_menu:add_label('highscore', "New highscore! Congratulations, "..Util.player_name.."!",
--         {color = Util.settings.main_color, underline = true})
   end
   death_menu:add_label('score', "Your score: "..Util.game.score.." pts", {color = Util.settings.main_color})
   GUI.death_menu = death_menu
   return GUI.death_menu
end

function GUI.create_functions.options_menu()
   local options_menu = menu.new_menu(0, 0, Util.settings.resolution_w, Util.settings.resolution_h)
   local properties = {font = love.graphics.newFont(50), color = Util.settings.main_color, underline = true}
   options_menu:add_label('title', "Options", properties)
   local res_list = {}
   for _, resolution in ipairs(Util.resolutions) do
      table.insert(res_list, resolution[1].." x "..resolution[2])
   end
   local selected_res_index = 1
   for i, label in ipairs(res_list) do
      local label_resolution = label:split(" x ")
      if tonumber(label_resolution[1]) == Util.settings.resolution_w and
      tonumber(label_resolution[2]) == Util.settings.resolution_h then
         selected_res_index = i
         break
      end
   end
   options_menu:add_selector('sl_resolution', "Resolution:", res_list, selected_res_index, Util.settings.main_color)
   local chk_fullscreen_properties = {      
      text_colors = {
         default = Util.settings.main_color,
         focused = Util.settings.main_color,
      },
      fill_box_colors = {
         default = Util.settings.main_color,
         focused = Util.settings.main_color,
      },
      outline_box_colors = { focused = Util.settings.main_color },
      state = Util.settings.fullscreen,
   }
   options_menu:add_checkbox('chk_fullscreen', "Fullscreen", chk_fullscreen_properties)
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
   local function cancel_function()
      Util.current_screen = Util.screens.on_main
   end
   local function apply_function()
      local data = options_menu:get_data()
      Util.apply_settings(data, GUI.create_functions)
      Util.current_screen = Util.screens.on_main
   end
   local bt_properties = {
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
   options_menu:add_buttongroup('btgp_apply', {"Cancel", "Apply"},
      {bt_properties, bt_properties}, {cancel_function, apply_function})
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
   for i, entry in ipairs(Util.ranking) do
      ranking_menu:add_label('n'..i, i..'. '..entry[1].."\t\t\t\t\t\t"..entry[2].." pts.", {color = Util.settings.main_color})
   end
   local bt_properties = {
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
   local function back_function()
      Util.current_screen = Util.screens.on_main
   end
   local function erase_function()
      os.remove("ranking.sav")
      Util.ranking = Util.read_ranking()
      back_function()
   end
   ranking_menu:add_buttongroup('btgp_ranking', {"Back", "Erase ranking"},
      {bt_properties, bt_properties}, {back_function, erase_function})
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

function GUI.draw_singleplayer_setup_menu_1()
   return GUI.singleplayer_setup_menu_1:run()
end

function GUI.draw_singleplayer_setup_menu_2()
   return GUI.singleplayer_setup_menu_2:run()
end

function GUI.draw_multiplayer_setup_menu_1()
   return GUI.multiplayer_setup_menu_1:run()
end

function GUI.draw_multiplayer_setup_menu_2()
   return GUI.multiplayer_setup_menu_2:run()
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
