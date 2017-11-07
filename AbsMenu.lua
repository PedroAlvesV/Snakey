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
   -- MUST EDIT
   local self = {
      focusable = true,
      label = label or "",
      text = default_value or "",
      hidden_text_start = "",
      hidden_text_end = "",
      callback = callback,
      enabled = true,
   }
   return setmetatable(self, { __index = TextInput })
end

function TextInput:draw(x, y, focus)
   -- MUST EDIT
   self.field_limit = scr_w - 6
   self.max_text = self.field_limit - utf8.len(self.label) - 3
   if utf8.len(self.text) > self.field_limit then
      self.hidden_text_start = self.text:sub(1, self.field_limit-utf8.len(self.text)) -- MUST FIX
      self.text = self.text:sub( -(utf8.len(self.hidden_text_start)) )
   end
   if self.focusable then
      drawable:attrset(colors.widget)
   else
      drawable:attrset(colors.widget_disabled)
   end
   local gap = utf8.len(self.label) + 5
   local iter = gap
   while iter < scr_w-5 do
      drawable:mvaddstr(y, iter, " ")
      iter = iter + 1
   end
   local placeholder = ""
   if self.visibility then
      placeholder = self.text or ""
   else
      for i=1, utf8.len(self.text or "") do
         placeholder = placeholder.."*"
      end
   end
   drawable:mvaddstr(y, gap, placeholder)
   if focus and self.focusable then
      drawable:attrset(colors.cursor)
      local ch_pos_x = self.cursor-utf8.len(self.label)-utf8.len(self.text)-5
      if self.visibility then
         drawable:mvaddstr(y, self.cursor, string.sub(self.text, ch_pos_x, ch_pos_x))
      else
         drawable:mvaddstr(y, self.cursor, "*")
      end
      if ch_pos_x == 0 then
         drawable:mvaddstr(y, self.cursor, " ")
      end
      drawable:attrset(colors.subcurrent)
   else
      drawable:attrset(colors.default)
   end
   local title = self.label.." ".."["
   if self.label == "" then
      title = "["
   end
   drawable:mvaddstr(y, x, title)
   drawable:mvaddstr(y, iter, "]")
end

function TextInput:process_key(key)
   -- MUST EDIT
   local first_position = utf8.len(self.label) + 5
   local last_position = first_position + utf8.len(self.text)
   local has_hidden_text_at_start = utf8.len(self.hidden_text_start) > 0
   local has_hidden_text_at_end = utf8.len(self.hidden_text_end) > 0
   local function bring_char()
      if has_hidden_text_at_end then
         self.text = self.text..self.hidden_text_end:sub(1,1)
         self.hidden_text_end = self.hidden_text_end:sub(2)
      end
   end
   if utf8.len(self.text) >= self.max_text-1 then
      last_position = last_position - 1
   end
   if key == keys.TAB or key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   elseif key == keys.PAGE_UP or key == keys.PAGE_DOWN then
      return actions.PASSTHROUGH
   end
   if self.focusable then
      if key == keys.LEFT then
         if self.cursor > first_position then
            self.cursor = self.cursor - 1
         elseif has_hidden_text_at_start then
            local iter = 0
            while utf8.len(self.text) < self.max_text-1 do
               self.text = self.hidden_text_start:sub(-iter)..self.text
               iter = iter + 1
            end
            self.hidden_text_end = self.text:sub(-1)..self.hidden_text_end
            self.text = self.text:sub(1,-2)
            self.text = self.hidden_text_start:sub(-1)..self.text
            self.hidden_text_start = self.hidden_text_start:sub(1,-2)
         end
         return actions.HANDLED
      elseif key == keys.RIGHT then
         if self.cursor < last_position then
            self.cursor = self.cursor + 1
         elseif utf8.len(self.text) >= self.max_text-1 then
            self.hidden_text_start = self.hidden_text_start..self.text:sub(1,1)
            self.text = self.text:sub(2)
            bring_char()
         end
         return actions.HANDLED
      elseif key == keys.HOME then
         self.cursor = first_position
         return actions.HANDLED
      elseif key == keys.END then
         self.cursor = last_position
         return actions.HANDLED
      elseif key >= 32 and key <= 382 then
         local pos_x = self.cursor-utf8.len(self.label)-utf8.len(self.text)-5
         if key == curses.KEY_BACKSPACE then
            if self.cursor == first_position then
               if has_hidden_text_at_start then
                  self.hidden_text_start = self.hidden_text_start:sub(1,-2)
               end
            else
               if self.cursor == last_position then
                  self.text = self.text:sub(1,-2)
                  bring_char()
               else
                  self.text = self.text:sub(1, pos_x-2)..self.text:sub(pos_x)
                  bring_char()
               end
               self.cursor = self.cursor-1
            end
            run_callback(self, self.text)
            return actions.HANDLED
         elseif key == curses.KEY_DC then
            if self.cursor < last_position then
               if self.cursor == last_position - 1 then
                  self.text = self.text:sub(1,-2)
               else
                  self.text = self.text:sub(1, pos_x-1)..self.text:sub(pos_x+1)
               end
               bring_char()
            end
            run_callback(self, self.text)
            return actions.HANDLED
         else
            if self.cursor == last_position then
               self.text = self.text..string.char(key)
               self.cursor = self.cursor + 1
               if self.cursor > self.field_limit then
                  self.cursor = self.cursor - 1
                  self.hidden_text_start = self.hidden_text_start..self.text:sub(1,1)
                  self.text = self.text:sub(2)
               end
            else
               self.text = self.text:sub(1, pos_x-1)..string.char(key)..self.text:sub(pos_x)
               if utf8.len(self.text) >= self.max_text then
                  self.hidden_text_end = self.text:sub(-1)..self.hidden_text_end
                  self.text = self.text:sub(1,-2)
               end
            end
            run_callback(self, self.text)
            return actions.HANDLED
         end
      end
   end
   return actions.PASSTHROUGH
end

function TextBox.new(title, default_value, callback)
   -- MUST EDIT
   local self = {
      height = 12,
      width = scr_w-5,
      view_pos = 1,
      title = title,
      original_text = default_value,
      focusable = true,
      inside = false,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   if type(title) == 'string' then
      self.height = self.height + 1
   end
   self.text, self.text_height = "", 0
   local size = utf8.len(default_value)
   local limit = scr_w-9
   local i = limit
   while i < size do
      default_value = default_value:sub(1, i-1).."\n"..default_value:sub(i)
      i = i + limit
   end
   default_value = default_value.."\n"
   if default_value then
      self.text = {}
      for line in default_value:gmatch("[^\n]*") do
         table.insert(self.text, line)
      end
   end
   return setmetatable(self, { __index = TextBox })
end

function TextBox:draw(x, y, focus)
   -- MUST EDIT
   self.inside_box_h = self.height - 2
   if type(self.title) == 'string' then
      self.inside_box_h = self.inside_box_h - 1
   end
   local function title_colors()
      if focus and self.focusable then
         return colors.current
      end
      return colors.default
   end
   local function box_colors()
      if self.inside then
         return colors.widget
      end
      return colors.default
   end
   if self.title then
      drawable:attrset(title_colors())
      drawable:mvaddstr(y, x, self.title)
      y = y + 1
   end
   local pad = curses.newpad(self.inside_box_h+2, self.width-2)
   pad:wbkgd(attr_code(box_colors()))
   for i=self.view_pos, self.view_pos + self.height - 1 do
      pad:mvaddstr(i-self.view_pos+1, 1, self.text[i] or "")
   end
   pad:attrset(colors.default)
   pad:border(0,0)
   pad:copywin(0, 0, y, x, y+self.inside_box_h+1, self.width, false)
   if #self.text > self.inside_box_h then
      draw_scrollbar(self.width, y, self.inside_box_h, #self.text, self.view_pos)
   end
end

function TextBox:process_key(key)
   -- MUST EDIT
   if key == keys.TAB then
      self.inside = false
      return actions.NEXT
   end
   if self.focusable then
      if key == keys.ENTER then
         self.inside = not self.inside
         return actions.HANDLED
      elseif key == keys.ESC then -- must fix delay
         self.inside = false
         return actions.HANDLED
      elseif key == keys.DOWN then
         if self.inside and #self.text > self.inside_box_h then
            if self.view_pos <= #self.text - self.inside_box_h then
               self.view_pos = self.view_pos + 1
            end
            return actions.HANDLED
         end
         self.inside = false
         return actions.NEXT
      elseif key == keys.UP then
         if self.inside and #self.text > self.inside_box_h then
            if self.view_pos > 1 then
               self.view_pos = self.view_pos - 1
            end
            return actions.HANDLED
         end
         self.inside = false
         return actions.PREVIOUS
      elseif key == keys.PAGE_DOWN then
         if self.inside and #self.text > self.inside_box_h then
            if self.view_pos <= #self.text - self.inside_box_h then
               local temp_vpos = self.view_pos + 5
               if temp_vpos > #self.text - self.inside_box_h then
                  self.view_pos = #self.text - self.inside_box_h + 1
               else
                  self.view_pos = temp_vpos
               end
            end
            return actions.HANDLED
         end
      elseif key == keys.PAGE_UP then
         if self.inside and #self.text > self.inside_box_h then
            if self.view_pos > 1 then
               local temp_vpos = self.view_pos - 5
               if temp_vpos < 1 then
                  self.view_pos = 1
               else
                  self.view_pos = temp_vpos
               end
            end
            return actions.HANDLED
         end
      elseif key == keys.HOME then
         if self.inside then
            self.view_pos = 1
            return actions.HANDLED
         end
      elseif key == keys.END then
         if self.inside then
            self.view_pos = #self.text - self.inside_box_h + 1
            return actions.HANDLED
         end
      end
   else
      if key == keys.DOWN then
         return actions.NEXT
      elseif key == keys.UP then
         return actions.PREVIOUS
      end
   end
   return actions.PASSTHROUGH
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

function Selector.new(title, list, color, callback)
   local self = {
      title = title,
      list = list,
      focusable = true,
      color = color or colors.WHITE,
      selected = 1,
      gap = 12,
      callback = callback,
      enabled = true,
   }
   self.title_text = love.graphics.newText(love.graphics.newFont(20), self.title)
   return setmetatable(self, { __index = Selector })
end

function Selector:draw(x, y, focus)
   local delimiter = {' ',' '}
   if focus then
      delimiter = {'‹','›'}
   end
   local title_text_x = x
   x = x + self.title_text:getWidth() + self.gap
   local selector = love.graphics.newText(love.graphics.newFont(20), delimiter[1].." "..self.list[self.selected].." "..delimiter[2])
   local total_width = self.title_text:getWidth() + self.gap + selector:getWidth()
   love.graphics.setColor(unpack(self.color))
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

function Menu:add_selector(id, title, list, color, callback)
   create_widget(self, 'SELECTOR', Selector, id, title, list, color, callback)
end

function Menu:add_implicit_button(callback)
   create_widget(self, 'IMPLICIT_BUTTON', Implicit_Button, IMPLICIT_BUTTON_ID, callback)
end

function Menu:show_message_box(message, buttons)
   -- MUST EDIT
   local function create_buttons()
      local labels, callbacks
      if buttons == 'OK' or not buttons then
         labels = {"Ok"}
         callbacks = { function() return "OK" end }
      elseif buttons == 'CLOSE' then
         labels = {"Close"}
         callbacks = { function() return "CANCEL" end }
      elseif buttons == 'YES_NO' then
         labels = {"Yes", "No"}
         callbacks = { function() return "YES" end, function() return "NO" end }
      elseif buttons == 'OK_CANCEL' then
         labels = {"Ok", "Cancel"}
         callbacks = { function() return "OK" end, function() return "CANCEL" end }
      else
         error('Invalid argument "'..buttons..'"')
      end
      return ButtonBox.new(labels, callbacks)
   end
   local bbox = create_buttons()
   local height, width = math.floor(scr_h/3), math.floor(scr_w/1.25)
   local y, x = math.floor(scr_h/3), math.floor(scr_w/10)
   local pad = curses.newpad(height, width)
   pad:wbkgd(colors.default)
   pad:attrset(colors.widget)
   pad:border(0,0)
   pad:attrset(colors.title)
   pad:mvaddstr(math.floor(y/2)-1, math.floor((width/2)-(utf8.len(message)/2)), message or "")
   while true do
      bbox:draw(pad, math.floor((width/2)-(bbox.width/2)), math.floor(y/2)+1, true)
      pad:prefresh(0, 0, y, x, y+height-1, x+width-1, false)
      clear_tooltip_bar()
      local tooltip = bbox.buttons[bbox.subfocus].tooltip
      tooltip = util.append_blank_space(scr_w)
      stdscr:attrset(colors.widget)
      stdscr:mvaddstr(scr_h-1, 0, tooltip)
      local motion = bbox:process_key(stdscr:getch())
      if type(motion) == 'string' then
         stdscr:clear()
         stdscr:attrset(colors.default)
         stdscr:sub(scr_h-1, scr_w, 0, 0):box(0, 0)
         stdscr:mvaddstr(scr_h-3, 2, "Tab/Arrows: move focus   Enter: select   Ctrl+Q: Quit")
         stdscr:refresh()
         return motion
      end
   end
end

function Menu:set_background_color(color)
   for i in ipairs(color) do
      if color[i] < 0 or color[i] > 255 then
         return false
      end
   end
   self.background_color = color
   return true
end

function Menu:set_enabled(id, bool, index)
   -- MUST EDIT
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         local widget = item.widget
         if item.type == 'BUTTON_BOX' then
            widget.buttons[index].focusable = bool
            widget.subfocus = 1
            while not widget.buttons[widget.subfocus].focusable and widget.subfocus < #widget.buttons do
               widget.subfocus = widget.subfocus + 1
            end
            widget.focusable = widget.buttons[widget.subfocus].focusable
            if not widget.focusable then
               widget.subfocus = 0
            end
         else
            if item.type ~= 'LABEL' then
               widget.focusable = bool
            end
         end
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
   -- MUST EDIT
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'LABEL' or item.type == 'BUTTON' then
            item.widget.label = value
         elseif item.type == 'TEXT_INPUT' then
            local entry = item.widget
            entry.text = value
            entry.hidden_text_start = ""
            entry.hidden_text_end = ""
            entry.cursor = utf8.len(entry.label) + utf8.len(entry.text) + 6
         elseif item.type == 'TEXTBOX' then
            local textbox = item.widget
            textbox.text = {}
            for line in value:gmatch("[^\n]*") do
               table.insert(textbox.text, line)
            end
         elseif item.type == 'CHECKBOX' then
            item.widget.state = value
         elseif item.type == 'CHECKLIST' then
            item.widget.checklist[index].state = value
         elseif item.type == 'SELECTOR' then
            local selector = item.widget
            if type(value) == 'table' then
               selector.height = #value+1
               if selector.height > selector.visible then
                  selector.height = selector.visible + 1
               end
               local _, actual_pad = create_pad(self)
               self.pad = actual_pad
               self.pad:wbkgd(attr_code(colors.default))
               selector.list = value
               if selector.subfocus > #value then
                  selector.subfocus = 1
               end
            end
            if index then
               if index > #selector.list or index < 1 then
                  index = 1
               end
               selector.marked = index
            end
            if selector.marked > #selector.list then
               selector.marked = #selector.list
            end
         end
      end
   end
end

function Menu:get_value(id, index)
   -- MUST EDIT
   for _, item in ipairs(self.widgets) do
      if item.id == id then
         if item.type == 'LABEL' then
            return item.widget.label
         elseif item.type == 'BUTTON' then
            local label = item.widget.label
            return label
         elseif item.type == 'TEXT_INPUT' then
            local entry = item.widget
            local text = entry.hidden_text_start..entry.text..entry.hidden_text_end
            return text
         elseif item.type == 'TEXTBOX' then
            return item.widget.original_text
         elseif item.type == 'CHECKBOX' then
            return item.widget.label, item.widget.state
         elseif item.type == 'CHECKLIST' then
            return item.widget.checklist[index].label, item.widget.checklist[index].state
         elseif item.type == 'SELECTOR' then
            local list = item.widget.list
            for i, button in ipairs(list) do
               if i == item.widget.selected then
                  return button
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
   -- MUST EDIT
   local data = {}
   for _, item in ipairs(self.widgets) do
      data[item.id] = {}
      local value = self:get_value(item.id)
      if item.type == 'CHECKBOX' then
         local _, v = self:get_value(item.id)
         value = v
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
            if item.widget.focusable then
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