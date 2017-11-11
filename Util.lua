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

Util.screens = {
   on_main = 1,
   on_pause = 0,
   on_death = -1,
   on_singleplayer_game = 2,
   on_multiplayer_setup = 3,
   on_multiplayer_game = 4,
   on_options = 5,
   on_ranking = 6,
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

---------------
-- Values
---------------

Util.settings.resolution_w, Util.settings.resolution_h = love.window.getMode()
love.audio.setVolume(Util.settings.volume/10)

Util.sqr_size = 20
Util.hud_height = 40
Util.initial_size = 4
Util.velocity = 0.05
Util.score = 0

Util.field_w = math.floor(Util.settings.resolution_w/Util.sqr_size)
Util.field_h = math.floor((Util.settings.resolution_h-Util.hud_height)/Util.sqr_size)

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

function Util.load_table(filename)
   local ftables, err = loadfile(filename)
   if err then return _, err end
   local tables = ftables()
   for idx=1, #tables do
      local tolinki = {}
      for i, v in pairs(tables[idx]) do
         if type(v) == "table" then
            tables[idx][i] = tables[v[1]]
         end
         if type(i) == "table" and tables[i[1]] then
            table.insert(tolinki, { i, tables[i[1]] })
         end
      end
      for _, v in ipairs(tolinki) do
         tables[idx][v[2]], tables[idx][v[1]] = tables[idx][v[1]], nil
      end
   end
   return tables[1]
end

----------
-- Init --
----------

Util.current_screen = Util.screens.on_main

return Util