local Fruit = {}

function Fruit.new(x, y)
   local self = {
      x = x,
      y = y,
      effect = love.math.random(10),
   }
   local mt = {
      __index = Fruit,
   }
   setmetatable(self, mt)
   return self
end

function Fruit:get_X()
   return self.x
end

function Fruit:get_Y()
   return self.y
end

function Fruit:get_effect()
   return self.effect
end

function Fruit:set_X(value)
   self.x = value
end

function Fruit:set_Y(value)
   self.y = value
end

function Fruit:set_effect(value)
   self.effect = value
end

return Fruit