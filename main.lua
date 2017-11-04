local GUI = require 'GUI'
local Util = require 'Util'
local engine = require 'engine'

local keys = Util.keys

--GUI.set_main_color(GUI.colors.WHITE)

love.window.setTitle("Snakey")

function love.load()
   engine.start()
end