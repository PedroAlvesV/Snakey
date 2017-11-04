local Util = {}

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

Util.w, Util.h = love.window.getMode()
Util.sqr_size = 20
Util.hud_height = 40
Util.initial_size = 4
Util.velocity = 0.05

Util.field_w, Util.field_h = math.floor(Util.w/Util.sqr_size), math.floor((Util.h-Util.hud_height)/Util.sqr_size)

Util.control_vars = {
   debug = false,
   is_mute = false,
}

Util.screens = {
   on_main = 1,
   on_pause = 0,
   on_death = -1,
   on_singleplayer_game = 2,
   on_multiplayer_setup = 3,
   on_multiplayer_game = 4,
   on_options = 5,
   on_rankings = 6,
}

Util.current_screen = Util.screens.on_main

return Util