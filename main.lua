local GUI = require 'GUI'
local Util = require 'Util'
local engine = require 'engine'

local keys = Util.keys

love.window.setTitle("Snakey")

function love.load()
   engine.start()
end