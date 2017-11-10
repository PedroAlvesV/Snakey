local AbsMenu = {}

local Util = require("Util")

local Menu = {}

local Label = {}
local Button = {}
local TextInput = {}
local TextBox = {}
local CheckBox = {}
local Slider = {}
local Selector = {}
local Implicit_Button = {}

local IMPLICIT_BUTTON_ID = {}

local colors = Util.colors
local default_bg_color = colors.BLACK

local actions = Util.actions
local keys = Util.keys

local function run_callback(self, ...)
   if self.callback then
      return self.callback(self.id, ...)
   end
end

function AbsMenu.new_menu(x, y, w, h)
   local self = {
      x = x,
      y = y,
      w = w,
      h = h,
      widgets = {},
      focus = 0,
      background_color = default_bg_color,
   }
   setmetatable(self, {__index = Menu})
   return self
end

function Label.new(label, properties)
   properties = properties or {}
   local self = {
      label = label,
      color = properties.color or colors.WHITE,
      font = properties.font or love.graphics.newFont(20),
      underline = properties.underline or false,
      focusable = false,
   }
   self.text = love.graphics.newText(self.font, self.label)
   return setmetatable(self, { __index = Label })
end

function Label:draw(x, y)
   love.graphics.setColor(unpack(self.color))
   if self.underline then
      local oversize = 10
      love.graphics.line(x - self.text:getWidth()/2 - oversize, y + self.text:getHeight()/2,
         x + self.text:getWidth()/2 + oversize, y + self.text:getHeight()/2)
      love.graphics.line(x - self.text:getWidth()/2 - oversize, y + self.text:getHeight()/2,
         x + self.text:getWidth()/2 + oversize, y + self.text:getHeight()/2)
   end
   love.graphics.draw(self.text, x, y, nil, nil, nil, self.text:getWidth()/2, self.text:getHeight()/2)
end

function Label:process_key(key)
   return actions.PASSTHROUGH
end

function Button.new(label, properties, callback)
   properties = properties or {}
   properties.label_color = properties.label_color or {}
   properties.fill_colors = properties.fill_colors or {}
   properties.outline_colors = properties.outline_colors or {}
   local self = {
      label = love.graphics.newText(love.graphics.newFont(20), label),
      label_color = {
         default = properties.label_color.default or colors.WHITE,
         focused = properties.label_color.focused or colors.WHITE,
         disabled = properties.label_color.disabled or colors.WHITE,
      },
      fill_colors = {
         default = properties.fill_colors.default or default_bg_color,
         focused = properties.fill_colors.focused or default_bg_color,
         disabled = properties.fill_colors.disabled or default_bg_color,
      },
      outline_colors = {
         default = properties.outline_colors.default or default_bg_color,
         focused = properties.outline_colors.focused or default_bg_color,
         disabled = properties.outline_colors.disabled or default_bg_color,
      },
      width = properties.width,
      height = properties.height,
      focusable = true,
      callback = callback,
      enabled = true,
   }
   self.width = self.width or self.label:getWidth()
   self.height = self.height or self.label:getHeight()
   self.width = self.width + 15
   self.height = self.height + 10
   return setmetatable(self, { __index = Button })
end

function Button:draw(x, y, focus)
   local color_set = 'default'
   if self.focusable then
      if focus then
         color_set = 'focused'
      end
   else
      color_set = 'disabled'
   end
   love.graphics.setColor(unpack(self.fill_colors[color_set]))
   love.graphics.rectangle("fill", x-self.width/2, y-self.height/2, self.width, self.height)
   love.graphics.setColor(unpack(self.outline_colors[color_set]))
   love.graphics.rectangle("line", x-self.width/2, y-self.height/2, self.width, self.height)
   love.graphics.setColor(unpack(self.label_color[color_set]))
   love.graphics.draw(self.label, x, y, nil, nil, nil, self.label:getWidth()/2, self.label:getHeight()/2)
end

function Button:process_key(key)
   if self.focusable then
      if key == keys.ENTER or key == keys.SPACE then
         return run_callback(self, self.label)
      end
   end
   if key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function TextInput.new(label, default_value, properties, callback)
   local self = {
      -- TODO
   }
   return setmetatable(self, { __index = TextInput })
end

function TextInput:draw(x, y, focus)
   -- TODO
end

function TextInput:process_key(key)
   -- TODO
end

function TextBox.new(title, default_value, callback)
   local self = {
      -- TODO
   }
   return setmetatable(self, { __index = TextBox })
end

function TextBox:draw(x, y, focus)
   -- TODO
end

function TextBox:process_key(key)
   -- TODO
end

function CheckBox.new(label, properties, callback)
   properties = properties or {}
   properties.text_colors = properties.text_colors or {}
   properties.fill_box_colors = properties.fill_box_colors or {}
   properties.outline_box_colors = properties.outline_box_colors or {}
   properties.cross_box_colors = properties.cross_box_colors or {}
   local self = {
      label = label,
      text_colors = {
         default = properties.text_colors.default or colors.WHITE,
         focused = properties.text_colors.focused or colors.WHITE,
         disabled = properties.text_colors.disabled or colors.GRAY,
      },
      fill_box_colors = {
         default = properties.fill_box_colors.default or colors.WHITE,
         focused = properties.fill_box_colors.focused or colors.WHITE,
         disabled = properties.fill_box_colors.disabled or colors.WHITE,
      },
      outline_box_colors = {
         default = properties.outline_box_colors.default or colors.BLACK,
         focused = properties.outline_box_colors.focused or colors.WHITE,
         disabled = properties.outline_box_colors.disabled or colors.GRAY,
      },
      cross_box_colors = {
         default = properties.cross_box_colors.default or colors.BLACK,
         focused = properties.cross_box_colors.focused or colors.BLACK,
         disabled = properties.cross_box_colors.disabled or colors.GRAY,
      },
      state = properties.state or false,
      box_align = properties.box_align or 'left',
      box = {
         x = 0,
         y = 0,
         size = 20,
      },
      gap = 12,
      callback = callback,
      focusable = true,
      enabled = true,
   }
   self.text = love.graphics.newText(love.graphics.newFont(20), self.label)
   return setmetatable(self, { __index = CheckBox })
end

function CheckBox:draw(x, y, focus)
   local total_width = self.box.size + self.gap + self.text:getWidth()
   self.box.x, self.box.y = x, y
   if self.box_align == 'right' then
      self.box.x = self.box.x + self.text:getWidth() + self.gap
   else
      x = x + self.box.size + self.gap
   end
   local color_set = 'default'
   if self.enabled then
      if focus then
         color_set = 'focused'
      end
   else
      color_set = 'disabled'
   end
   love.graphics.setColor(unpack(self.fill_box_colors[color_set]))
   love.graphics.rectangle("fill", self.box.x - total_width/2, self.box.y, self.box.size, self.box.size)
   love.graphics.setColor(unpack(self.outline_box_colors[color_set]))
   love.graphics.rectangle("line", self.box.x - total_width/2, self.box.y, self.box.size, self.box.size)
   if self.state then
      love.graphics.setColor(unpack(self.cross_box_colors[color_set]))
      love.graphics.line(self.box.x - total_width/2 + self.box.size/5, self.box.y + self.box.size/5,
         self.box.x + self.box.size - total_width/2 - self.box.size/5, self.box.y + self.box.size - self.box.size/5)
      love.graphics.line(self.box.x + self.box.size - total_width/2 - self.box.size/5, self.box.y + self.box.size/5,
         self.box.x - total_width/2 + self.box.size/5, self.box.y + self.box.size - self.box.size/5)
   end
   love.graphics.setColor(unpack(self.text_colors[color_set]))
   love.graphics.draw(self.text, x - total_width/2, y)
end

function CheckBox:process_key(key)
   if self.focusable then
      if key == keys.ENTER or key == keys.SPACE then
         self.state = not self.state
         run_callback(self, self.state, self.label)
      end
   end
   if key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function Selector.new(title, list, default_value, default_color, disabled_color, callback)
   local self = {
      title = title,
      list = list,
      focusable = true,
      default_color = default_color or colors.WHITE,
      disabled_color = disabled_color or colors.GRAY,
      selected = default_value or 1,
      gap = 12,
      callback = callback,
      enabled = true,
   }
   self.title_text = love.graphics.newText(love.graphics.newFont(20), self.title)
   return setmetatable(self, { __index = Selector })
end

function Selector:draw(x, y, focus)
   local delimiter = {'I','I'}
   if focus then
      delimiter = {'‹','›'}
   end
   local title_text_x = x
   x = x + self.title_text:getWidth() + self.gap
   local selector = love.graphics.newText(love.graphics.newFont(20), delimiter[1].." "..self.list[self.selected].." "..delimiter[2])
   local total_width = self.title_text:getWidth() + self.gap + selector:getWidth()
   love.graphics.setColor(unpack(self.default_color))
   if not self.enabled then
      love.graphics.setColor(unpack(self.disabled_color))
   end
   love.graphics.draw(self.title_text, title_text_x - total_width/2, y)
   love.graphics.draw(selector, x - total_width/2 , y)
end

function Selector:process_key(key)
   if key == keys.LEFT then
      if self.selected > 1 then
         self.selected = self.selected - 1
         run_callback(self, self.selected, self.list[self.selected])
      end
      return actions.HANDLED
   elseif key == keys.RIGHT then
      if self.selected < #self.list then
         self.selected = self.selected + 1
         run_callback(self, self.selected, self.list[self.selected])
      end
      return actions.HANDLED
   elseif key == keys.ENTER or key == keys.SPACE or key == keys.DOWN then
      run_callback(self, self.selected, self.list[self.selected])
      return actions.NEXT
   elseif key == keys.UP then
      run_callback(self, self.selected, self.list[self.selected])
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function Implicit_Button.new(callback)
   local self = {
      callback = callback,
      focusable = true,
   }
   return setmetatable(self, { __index = Implicit_Button })
end

function Implicit_Button:draw() end

function Implicit_Button:process_key(key)
   if key == keys.ENTER or key == keys.SPACE then
      run_callback(self, self.callback)
      return actions.HANDLED
   end
   return actions.PASSTHROUGH
end

local function create_widget(self, type_name, class, id, ...)
   local item = {
      id = id,
      type = type_name,
      widget = class.new(...),
   }
   item.widget.id = id
   table.insert(self.widgets, item)
   return item.widget
end

function Menu:add_label(id, label, properties)
   create_widget(self, 'LABEL', Label, id, label, properties)
end

function Menu:add_button(id, label, properties, callback)
   create_widget(self, 'BUTTON', Button, id, label, properties, callback)
end

function Menu:add_text_input(id, label, visibility, default_value, callback)
   create_widget(self, 'TEXT_INPUT', TextInput, id, label, visibility, default_value, callback)
end

function Menu:add_textbox(id, title, default_value, callback)
   create_widget(self, 'TEXTBOX', TextBox, id, title, default_value, callback)
end

function Menu:add_checkbox(id, label, properties, callback)
   create_widget(self, 'CHECKBOX', CheckBox, id, label, properties, callback)
end

function Menu:add_selector(id, title, list, default_value, default_color, disabled_color, callback)
   create_widget(self, 'SELECTOR', Selector, id, title, list, default_value, default_color, disabled_color, callback)
end

function Menu:add_implicit_button(callback)
   create_widget(self, 'IMPLICIT_BUTTON', Implicit_Button, IMPLICIT_BUTTON_ID, callback)
end

function Menu:show_message_box(message, buttons)
   -- TODO
end

function Menu:set_background_color(color)
   if Util.valid_color(color) then
      self.background_color = color
      return true
   end
   return false
end

function Menu:set_enabled(id, bool)
   -- MUST EDIT
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         local widget = item.widget
         widget.focusable = bool
         widget.enabled = bool
      end
   end
end

function Menu:delete_widget(id)
   for i, item in ipairs(self.widgets) do
      if item.id == id then
         table.remove(self.widgets, i)
         return true
      end
   end
   return false
end

function Menu:set_value(id, value, index)
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'LABEL' or item.type == 'BUTTON' then
            item.widget.label = value
         elseif item.type == 'TEXT_INPUT' then
            -- TODO
         elseif item.type == 'TEXTBOX' then
            -- TODO
         elseif item.type == 'CHECKBOX' then
            item.widget.state = value
         elseif item.type == 'SELECTOR' then
            -- TODO
         end
      end
   end
end

function Menu:get_value(id, index)
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'LABEL' or item.type == 'BUTTON' then
            return item.widget.label
         elseif item.type == 'TEXT_INPUT' then
            -- TODO
         elseif item.type == 'TEXTBOX' then
            -- TODO
         elseif item.type == 'CHECKBOX' then
            return item.widget.label, item.widget.state
         elseif item.type == 'SELECTOR' then
            local list = item.widget.list
            for index, option in ipairs(list) do
               if index == item.widget.selected then
                  return index, option
               end
            end
         end
      end
   end
end

function Menu:set_focus(widget_n)
   if widget_n > 0 and widget_n <= #self.widgets then
      self.focus = widget_n
      return true
   end
   return false
end

function Menu:get_data()
   local data = {}
   for _, item in ipairs(self.widgets) do
      data[item.id] = {}
      local value = self:get_value(item.id)
      if item.type == 'CHECKBOX' then
         local _, v = self:get_value(item.id)
         value = v
      elseif item.type == 'SELECTOR' then
         local index, option = self:get_value(item.id)
         value = {index = index, option = option}
      end
      data[item.id] = value
   end
   return data
end

function Menu:process_key(key)
   local function move_focus(direction)
      local widget = self.widgets[self.focus].widget
      local next_focus = self.focus + direction
      if next_focus > 0 and next_focus <= #self.widgets then
         if self.widgets[next_focus].widget.focusable then
            self.focus = next_focus
         else
            move_focus(direction+direction)
         end
      end
      return actions.HANDLED
   end
   local widget = self.widgets[self.focus].widget
   local motion = widget:process_key(key)
   if motion == actions.PASSTHROUGH then
      return motion
   end
   if motion == actions.PREVIOUS then
      return move_focus(-1)
   elseif motion == actions.NEXT then
      return move_focus(1)
   end
end

function Menu:run(implicit_callback)
   if self.focus == 0 then
      local function apply_focus()
         for i, item in ipairs(self.widgets) do
            if (item.widget.focusable and item.widget.enabled) or item.id == IMPLICIT_BUTTON_ID then
               self.focus = i
               return true
            end
         end
         return false
      end
      if not apply_focus() then
         self:add_implicit_button(implicit_callback or
            function()
               io.stdout:setvbuf('no')
               print("[AbsMenu]: Please, pass an implicit callback function to Menu:run()")
               love.window.close()
            end)
      end
   end
   love.graphics.setColor(unpack(self.background_color))
   love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
   local valid_widgets = 0
   for i=1, #self.widgets do
      if self.widgets[i].id ~= IMPLICIT_BUTTON_ID then
         valid_widgets = valid_widgets + 1
      end
   end
   for i, item in ipairs(self.widgets) do
      item.y = self.h * (i/(valid_widgets+1))
   end
   for i, item in ipairs(self.widgets) do
      item.widget:draw(self.x + self.w/2, self.y + item.y, i == self.focus)
   end
   function love.keypressed(key)
      return self:process_key(key)
   end
end

return AbsMenu