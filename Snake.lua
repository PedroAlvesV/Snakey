local Snake = {}

function Snake.new(x, y)
   local self = {
      segments = {},
   }
   self.segments[1] = {x = x, y = y, direction = 'right'}
   local mt = {
      __index = Snake,
   }
   setmetatable(self, mt)
   return self
end

function Snake:add_segment()
   local x, y = self.segments[#self.segments].x, self.segments[#self.segments].y
   local direction = self.segments[#self.segments].direction
   if direction == 'right' then
      x = x - 1
   elseif direction == 'left' then
      x = x + 1
   elseif direction == 'down' then
      y = y - 1
   elseif direction == 'up' then
      y = y + 1
   end
   table.insert(self.segments, {x = x, y = y, direction = direction})
end

function Snake:get_segments()
   return self.segments
end

function Snake:get_direction(index)
   return self.segments[index].direction
end

function Snake:get_X(index)
   return self.segments[index].x
end

function Snake:get_Y(index)
   return self.segments[index].y
end

function Snake:set_direction(index, direction)
   if self.segments[index].direction == 'up' and direction == 'down' then
      return
   elseif self.segments[index].direction == 'down' and direction == 'up' then
      return
   elseif self.segments[index].direction == 'right' and direction == 'left' then
      return
   elseif self.segments[index].direction == 'left' and direction == 'right' then
      return
   else
      self.segments[index].direction = direction
   end
end

function Snake:set_X(index, value)
   self.segments[index].x = value
end

function Snake:set_Y(index, value)
   self.segments[index].y = value
end

return Snake