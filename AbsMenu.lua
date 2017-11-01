local AbsMenu = {}

local GUI = require("GUI")

local Screen = {}

local Label = {}
local Button = {}
local TextInput = {}
local TextBox = {}
local CheckBox = {}
local CheckList = {} -- must value
local Slider = {}
local Selector = {} -- like Resolution < 1366x768 >

local colors = GUI.colors

local ASSIST_BUTTONS, NAV_BUTTONS = {}, {}

local actions = {
   PASSTHROUGH = 0,
   HANDLED = -2,
   PREVIOUS = -1,
   NEXT = 1,
}

local keys = {
   ENTER = 'return',
   ESC = 'escape',
   SPACE = 'space',
   DOWN = 'down',
   UP = 'up',
   LEFT = 'left',
   RIGHT = 'right',
}

local function run_callback(self, ...)
   if self.callback then
      return self.callback(self.id, ...)
   end
end

function AbsMenu.new_screen(title, w, h)
   local self = {
      title = title,
      w = w,
      h = h,
      widgets = {},
      focus = 1,
   }
   setmetatable(self, {__index = Screen})
   return self
end

function Label.new(label)
   -- MUST EDIT
   local original_label = label
   local size = utf8.len(label)
   local limit = scr_w-8
   local i = limit
   while i < size do
      while label:sub(i, i) ~= " " do
         i = i - 1
      end
      label = label:sub(1, i-1).."\n"..label:sub(i)
      i = i + limit
   end
   local lines = {}
   for line in label:gmatch("[^\n]*") do
      if line:sub(1,1) == " " then
         line = line:sub(2)
      end
      table.insert(lines, line)
   end
   local self = {
      height = #lines,
      lines = lines,
      label = original_label,
      focusable = false,
   }
   return setmetatable(self, { __index = Label })
end

function Label:draw(x, y)
   drawable:attrset(colors.default)
   for i, line in ipairs(self.lines) do
      drawable:mvaddstr(y+i-1, x, line)
   end
end

function Button.new(label, callback)
   local self = {
      label = label,
      focusable = true,
      callback = callback,
      enabled = true,
   }
   return setmetatable(self, { __index = Button })
end

function Button:draw(x, y, focus)
   -- MUST EDIT
   if self.focusable then
      drawable:attrset(colors.button)
   else
      drawable:attrset(colors.widget_disabled)
   end
   local label = " "..self.label.." "
   drawable:mvaddstr(y, x+1, label)
   local left, right = " ", " "
   if focus and self.focusable then
      left, right = ">", "<"
   end
   drawable:attrset(colors.title)
   drawable:mvaddstr(y, x, left)
   drawable:mvaddstr(y, x+string.len(label)+1, right)
end

function Button:process_key(key)
   -- MUST EDIT
   if self.focusable then
      if key == keys.ENTER or key == keys.SPACE then
         if index then
            return run_callback(self, index, self.label)
         else
            return run_callback(self, self.label)
         end
      end
   end
   if key == keys.TAB or key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function TextInput.new(label, visibility, default_value, callback)
   -- MUST EDIT
   local self = {
      height = 1,
      focusable = true,
      label = label or " ",
      visibility = visibility,
      text = default_value or "",
      hidden_text_start = "",
      hidden_text_end = "",
      cursor = 0,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   self.cursor = utf8.len(self.label) + utf8.len(self.text) + 5
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

function CheckBox.new(label, default_value, callback)
   -- MUST EDIT
   local self = {
      height = 1,
      label = label,
      state = default_value or false,
      focusable = true,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   return setmetatable(self, { __index = CheckBox })
end

function CheckBox:draw(x, y, focus)
   -- MUST EDIT
   if not focus then
      drawable:attrset(colors.default)
   else
      if type(focus) == 'table' then
         if focus.widget then
            drawable:attrset(colors.current)
         end
         if focus.subitem then
            if self.focusable then
               drawable:attrset(colors.subcurrent)
            end
         end
      else
         if self.focusable then
            drawable:attrset(colors.subcurrent)
         end
      end
   end
   local mark = " "
   if self.state then
      mark = "x"
   end
   local label = util.append_blank_space(self.label, scr_w-utf8.len(self.label)-12)
   drawable:mvaddstr(y, x, "["..mark.."] "..label)
end

function CheckBox:process_key(key, index)
   -- MUST EDIT
   if self.focusable then
      if key == keys.ENTER or key == keys.SPACE then
         self.state = not self.state
         if index then
            run_callback(self, index, self.state, self.label)
         else
            run_callback(self, self.state, self.label)
         end
      end
   end
   if key == keys.TAB or key == keys.DOWN then
      return actions.NEXT
   elseif key == keys.UP then
      return actions.PREVIOUS
   end
   return actions.PASSTHROUGH
end

function CheckList.new(title, list, default_value, callback)
   -- MUST EDIT
   local function make_item(i, label, value)
      return CheckBox.new(label, value, callback)
   end
   local checklist = util.make_list_items(make_item, list, default_value)
   local self = {
      height = #checklist+1,
      checklist = checklist,
      focusable = true,
      subfocus = 1,
      view_pos = 1,
      visible = 5,
      title = title,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   if self.height > self.visible then
      self.height = self.visible + 1
      self.scrollable = true
   end
   return setmetatable(self, { __index = CheckList })
end

function CheckList:draw(x, y, focus)
   -- MUST EDIT
   self.width = scr_w-8
   if focus and self.focusable then
      drawable:attrset(colors.current)
   else
      drawable:attrset(colors.default)
   end
   drawable:mvaddstr(y, x, self.title)
   for i=self.view_pos, #self.checklist do
      local attr = false
      if focus and self.focusable then
         if i == self.subfocus then
            attr = {widget = true, subitem = true}
         else
            attr = {widget = true, subitem = false}
         end
      end
      if i < self.view_pos + self.visible then
         self.checklist[i]:draw(x, y+i-self.view_pos+1, attr)
      end
   end
   if #self.checklist > self.visible then
      draw_scrollbar(self.width+3, y, self.visible, #self.checklist, self.view_pos)
   end
end

function CheckList:process_key(key)
   -- MUST EDIT
   if key == keys.TAB then
      return actions.NEXT
   end
   if self.focusable then
      if key == keys.DOWN then
         if self.subfocus < #self.checklist then
            self.subfocus = self.subfocus + 1
            if self.scrollable and self.subfocus - self.view_pos + 1 == self.visible + 1 then
               self.view_pos = self.view_pos + 1
            end
            return actions.HANDLED
         elseif self.subfocus == #self.checklist then
            return actions.NEXT
         end
      elseif key == keys.UP then
         if self.subfocus > 1 then
            self.subfocus = self.subfocus - 1
            if self.scrollable and self.subfocus == self.view_pos - 1 then
               self.view_pos = self.view_pos - 1
            end
            return actions.HANDLED
         elseif self.subfocus == 1 then
            return actions.PREVIOUS
         end
      elseif key == keys.HOME then
         self.subfocus = 1
         if self.scrollable then
            self.view_pos = 1
         end
         return actions.HANDLED
      elseif key == keys.END then
         self.subfocus = #self.checklist
         if self.scrollable then
            self.view_pos = self.subfocus - self.visible + 1
         end
         return actions.HANDLED
      else
         return self.checklist[self.subfocus]:process_key(key, self.subfocus)
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

function Selector.new(title, list, default_value, callback)
   -- MUST EDIT
   local function make_item(i, label, value)
      if value then
         default_value = i
      end
      return label
   end
   local items = util.make_list_items(make_item, list, default_value)
   local self = {
      height = #items+1,
      list = items,
      focusable = true,
      subfocus = 1,
      view_pos = 1,
      visible = 5,
      title = title,
      marked = default_value or 1,
      tooltip = tooltip,
      callback = callback,
      enabled = true,
   }
   if self.height > self.visible then self.height = self.visible + 1 end
   return setmetatable(self, { __index = Selector })
end

function Selector:draw(x, y, focus)
   -- MUST EDIT
   if self.height > self.visible then
      self.height = self.visible + 1
      self.scrollable = true
   end
   self.width = scr_w-8
   if focus and self.focusable then
      drawable:attrset(colors.current)
   else
      drawable:attrset(colors.default)
   end
   drawable:mvaddstr(y, x, self.title)
   for i=self.view_pos, #self.list do
      if focus and self.focusable then
         if i == self.subfocus then
            drawable:attrset(colors.subcurrent)
         else
            drawable:attrset(colors.current)
         end
      else
         drawable:attrset(colors.default)
      end
      local mark = " "
      if i == self.marked then
         mark = "*"
      end
      if i < self.view_pos + self.visible then
         local label = util.append_blank_space(self.list[i], scr_w-utf8.len(self.list[i])-12)
         drawable:mvaddstr(y+i-self.view_pos+1, x, "("..mark..") "..label)
      end
   end
   if #self.list > self.visible then
      draw_scrollbar(self.width+3, y, self.visible, #self.list, self.view_pos)
   end
end

function Selector:process_key(key)
   -- MUST EDIT
   if key == keys.TAB then
      return actions.NEXT
   end
   if self.focusable then
      if key == keys.ENTER or key == keys.SPACE then
         if self.marked ~= self.subfocus then
            self.marked = self.subfocus
            run_callback(self, self.marked, self.list[self.marked])
         end
      elseif key == keys.DOWN then
         if self.subfocus < #self.list then
            self.subfocus = self.subfocus + 1
            if self.scrollable and self.subfocus - self.view_pos + 1 == self.visible + 1 then
               self.view_pos = self.view_pos + 1
            end
            return actions.HANDLED
         elseif self.subfocus == #self.list then
            return actions.NEXT
         end
      elseif key == keys.UP then
         if self.subfocus > 1 then
            self.subfocus = self.subfocus - 1
            if self.scrollable and self.subfocus == self.view_pos - 1 then
               self.view_pos = self.view_pos - 1
            end
            return actions.HANDLED
         elseif self.subfocus == 1 then
            return actions.PREVIOUS
         end
      elseif key == keys.HOME then
         self.subfocus = 1
         if self.scrollable then
            self.view_pos = 1
         end
         return actions.HANDLED
      elseif key == keys.END then
         self.subfocus = #self.list
         if self.scrollable then
            self.view_pos = self.subfocus - self.visible + 1
         end
         return actions.HANDLED
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

function Screen:add_label(id, label)
   create_widget(self, 'LABEL', Label, id, label)
end

function Screen:add_button(id, label, callback)
   create_widget(self, 'BUTTON', Button, id, label, callback)
end

function Screen:add_image(id, path, dimensions, tooltip)
   return nil
end

function Screen:add_text_input(id, label, visibility, default_value, callback)
   create_widget(self, 'TEXT_INPUT', TextInput, id, label, visibility, default_value, callback)
end

function Screen:add_textbox(id, title, default_value, callback)
   create_widget(self, 'TEXTBOX', TextBox, id, title, default_value, callback)
end

function Screen:add_checkbox(id, label, default_value, callback)
   create_widget(self, 'CHECKBOX', CheckBox, id, label, default_value, callback)
end

function Screen:create_checklist(id, title, list, default_value, callback)
   local widget = create_widget(self, 'CHECKLIST', CheckList, id, title, list, default_value, callback)
   for _, checkbox in ipairs(widget.checklist) do
      checkbox.id = id
   end
end

function Screen:create_selector(id, title, list, default_value, callback)
   create_widget(self, 'SELECTOR', Selector, id, title, list, default_value, callback)
end

function Screen:show_message_box(message, buttons)
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

function Screen:set_enabled(id, bool, index)
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

function Screen:delete_widget(id)
   -- MUST TEST
   for i, item in ipairs(self.widgets) do
      if item.id == id then
         table.remove(self.widgets, i)
         return true
      end
   end
   return false
end

function Screen:set_value(id, value, index)
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

function Screen:get_value(id, index)
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
               if i == item.widget.marked then
                  return button
               end
            end
         end
      end
   end
end

local function run_screen(screen, pad, wizard)
   -- MUST EDIT
   local function scroll_screen(item)
      local widget = item.widget
      if item.y > pad.min and item.y <= pad.max then
         if item.y + widget.height - 1 > pad.max then
            pad.min = pad.min + (item.y + widget.height - pad.max)
         end
      else
         if item.y < pad.min then
            pad.min = item.y - 1
         else
            pad.min = item.y + widget.height - pad.viewport_h + 1
         end
      end
      pad.max = pad.min + pad.viewport_h - 1
      if pad.total_h > pad.viewport_h then
         draw_scrollbar(stdscr, scr_w-1, 1, pad.viewport_h-1, pad.total_h-1, pad.min)
      end
   end
   local function process_key(key, item)
      local function move_focus(direction)
         local widget = screen.widgets[screen.focus].widget
         local next_focus = screen.focus + direction
         if next_focus > 0 and next_focus <= #screen.widgets then
            screen.focus = next_focus
         end
         return actions.HANDLED
      end
      local widget = item.widget
      if key ~= keys.QUIT then
         local motion = widget:process_key(key)
         if motion == actions.PASSTHROUGH then
            if key == keys.LEFT or key == keys.RIGHT then
               screen.focus = #screen.widgets
            end
            if pad.total_h > pad.viewport_h then
               if key == keys.HOME then
                  pad.min = 1
                  scroll_screen(item)
               elseif key == keys.END then
                  pad.min = pad.last_pos
               end
            end
            return motion
         end
         if motion == actions.PREVIOUS then
            move_focus(-1)
         elseif motion == actions.NEXT then
            move_focus(1)
         end
      else
         return "QUIT"
      end
   end
   stdscr:attrset(colors.title)
   local title
   if wizard and screen.title then
      title = wizard.title.." - "..screen.title
   elseif not screen.title then
      title = wizard.title.." - Page "..wizard.current_page
   else
      title = screen.title
   end
   stdscr:mvaddstr(1, 1, title)
   for i, item in ipairs(screen.widgets) do
      local arrow = " "
      if i == screen.focus then
         if type(item.widget.tooltip) == 'string' then
            local tooltip = item.widget.tooltip
            if item.type == 'BUTTON_BOX' and item.widget.focusable then
               tooltip = item.widget.buttons[item.widget.subfocus].tooltip or ""
            end
            while utf8.len(tooltip) < scr_w do
               tooltip = tooltip.." "
            end
            stdscr:attrset(colors.widget)
            stdscr:mvaddstr(scr_h-1, 0, tooltip)
         else
            clear_tooltip_bar()
         end
         arrow = ">"
         if item.id ~= ASSIST_BUTTONS then
            scroll_screen(item)
         end
      end
      if item.widget.focusable then
         screen.pad:attrset(colors.title)
      else
         screen.pad:attrset(colors.default)
      end
      if item.id == NAV_BUTTONS or item.id == ASSIST_BUTTONS then
         item.widget:draw(stdscr, scr_w-item.widget.width-1, scr_h-3, i == screen.focus)
      else
         screen.pad:mvaddstr(item.y, 1, arrow)
         item.widget:draw(screen.pad, 3, item.y, i == screen.focus)
      end
      screen.pad:prefresh(pad.min, 0, 2, 1, pad.viewport_h, scr_w-2)
   end
   stdscr:move(scr_h-1,scr_w-1)
   return process_key(stdscr:getch(), screen.widgets[screen.focus])
end

local function iter_screen_items(screen)
   -- MUST EDIT
   local data = {}
   for _, item in ipairs(screen.widgets) do
      if item.id ~= ASSIST_BUTTONS and item.id ~= NAV_BUTTONS then
         data[item.id] = {}
         if item.type == 'BUTTON_BOX' or item.type == 'CHECKLIST' then
            if item.type == 'BUTTON_BOX' then
               for j=1, #item.widget.buttons do
                  data[item.id][j] = screen:get_value(item.id, j)
               end
            else
               for j=1, #item.widget.checklist do
                  data[item.id][j] = {label = nil, state = nil}
                  data[item.id][j].label, data[item.id][j].state = screen:get_value(item.id, j)
               end
            end
         else
            local value = screen:get_value(item.id)
            if item.type == 'CHECKBOX' then
               local _, v = screen:get_value(item.id)
               value = v
            end
            data[item.id] = value
         end
      end
   end
   return data
end

function Screen:run()
   -- MUST EDIT
   local done_curses = function()
      self.done = true
   end
   local function create_assistant_buttons()
      local labels, callbacks
      labels = {'Done'}
      callbacks = {done_curses}
      self:create_button_box(ASSIST_BUTTONS, labels, callbacks)
   end
   self.widgets[#self.widgets].widget.subfocus = 1
   local pad, actual_pad = create_pad(self)
   self.pad = actual_pad
   self.pad:wbkgd(attr_code(colors.default))
   create_assistant_buttons()
   while true do
      if run_screen(self, pad) == "QUIT" then
         done_curses()
      end
      if self.done then
         return util.collect_data(self, iter_screen_items)
      end
   end
end

return AbsMenu