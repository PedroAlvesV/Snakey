require('table2file')

local Util = {}

---------------
-- Tables
---------------

Util.colors = {
   BLACK    = {0,0,0},
   WHITE    = {255,255,255},
   GRAY     = {128,128,128},
   RED      = {255,0,0},
   ORANGE   = {255,128,0},
   YELLOW   = {255,255,0},
   LIME     = {128,255,0},
   GREEN    = {0,255,0},
   CYAN     = {0,255,255},
   LBLUE    = {0,128,255},
   DBLUE    = {0,0,255},
   PURPLE   = {127,0,255},
   MAGENTA  = {255,0,255},
   PINK     = {255,0,127},
}

Util.game_pallete = {
   {"WHITE", "White"},
   {"GRAY", "Gray"},
   {"RED", "Red"},
   {"ORANGE", "Orange"},
   {"YELLOW", "Yellow"},
   {"LIME", "Lime"},
   {"GREEN", "Green"},
   {"CYAN", "Cyan"},
   {"LBLUE", "Light Blue"},
   {"DBLUE", "Dark Blue"},
   {"PURPLE", "Purple"},
   {"MAGENTA", "Magenta"},
   {"PINK", "Pink"},
}

Util.resolutions = {
   {800, 600},
   {1024, 768},
   {1280, 720},
   {1280, 768},
   {1360, 768},
   {1366, 768},
}

Util.screens = {
   on_main = 0,
   on_singleplayer_setup_1 = 1,
   on_singleplayer_setup_2 = 2,
   on_singleplayer_game = 3,
   on_multiplayer_setup_1 = 4,
   on_multiplayer_setup_2 = 5,
   on_multiplayer_game = 6,
   on_pause = 7,
   on_death = 8,
   on_options = 9,
   on_ranking = 10,
}

Util.actions = {
   PASSTHROUGH = 0,
   HANDLED = -2,
   PREVIOUS = -1,
   NEXT = 1,
}

Util.keys = {
   ENTER = 'return',
   ESC = 'escape',
   SPACE = 'space',
   DOWN = 'down',
   UP = 'up',
   LEFT = 'left',
   RIGHT = 'right',
   S = 's',
   W = 'w',
   A = 'a',
   D = 'd',
   M = 'm',
   KP_MINUS = 'kp-',
   KP_PLUS = 'kp+',
}

Util.sfx = {
   ponto = love.audio.newSource("/sfx/ponto.ogg", "static"),
   toque = love.audio.newSource("/sfx/toque.ogg", "static"),
   inicio = love.audio.newSource("/sfx/inicio.ogg", "static"),
}

Util.control_vars = {
   debug = false,
   is_mute = false,
}

Util.settings = {
   main_color = Util.colors.WHITE,
   fullscreen = false,
   volume = 5,
}
Util.settings.resolution_w, Util.settings.resolution_h = love.window.getMode()

Util.game = {score = 0}

---------------
-- Values
---------------

Util.hud_height = 40

---------------
-- Functions
---------------

function Util.apply_settings(data, functions)
   local selected_color
   for i, value in ipairs(Util.game_pallete) do
      if data.sl_color.option == value[2] then
         selected_color = value[1]
         break
      end
   end
   Util.settings.main_color = Util.colors[selected_color]
   Util.settings.fullscreen = data.chk_fullscreen
   love.window.setFullscreen(Util.settings.fullscreen)
   if not Util.settings.fullscreen then
      love.window.setMode(Util.resolutions[data.sl_resolution.index][1],
         Util.resolutions[data.sl_resolution.index][2])
   end
   Util.settings.resolution_w, Util.settings.resolution_h = love.window.getMode()
   Util.settings.volume = data.sl_volume.option
   love.audio.setVolume(Util.settings.volume/10)
   for _, func in pairs(functions) do
      func()
   end
end

function Util.valid_color(color)
   for i in ipairs(color) do
      if color[i] < 0 or color[i] > 255 or i > 4 then
         return false
      end
   end
   return true
end

function Util.set_main_color(color)
   if Util.valid_color(color) then
      Util.settings.main_color = color
      return true
   end
   return false
end

function Util.get_main_color()
   return Util.settings.main_color
end

function Util.is_highscore()
   return (Util.game.score >= Util.ranking[#Util.ranking][2]) and (Util.game.score > 0)
end

function Util.update_ranking()
   if Util.is_highscore() then
      local new_score = Util.game.score
      local ranking = Util.ranking
      for pos, entry in ipairs(ranking) do
         if new_score >= entry[2] then
            table.insert(ranking, pos, {Util.player_name, new_score})
            table.remove(ranking, #ranking)
            Util.ranking = ranking
            Util.write_ranking()
            return true
         end
      end
   end
   return false, "It wasn't highscore."
end

function Util.write_ranking()
   return table.save(Util.ranking, 'ranking.sav')
end

function Util.read_ranking()
   local f, inexistent = io.open('ranking.sav')
   if inexistent then
      local default_ranking = {}
      for i=1, 10 do
         default_ranking[#default_ranking+1] = {"Empty", 0}
      end
      return default_ranking
   end
   f:close()
   return table.load('ranking.sav')
end

----------
-- Init --
----------

string.split = function(str, delimiter)
   local t = {}
   for substr in str:gmatch('([^'..delimiter..']+)') do
      t[#t+1] = substr
   end
   return t
end

Util.current_screen = Util.screens.on_main
love.audio.setVolume(Util.settings.volume/10)
Util.ranking = Util.read_ranking()

return Util