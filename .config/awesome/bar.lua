local awful = require('awful')
local beautiful = require('beautiful')
local gears = require('gears')
local wibox = require('wibox')

local globals = require('globals')
local menu = require('menu')

local bar = {}

function bar.init(screen)
  screen.prompt_widget = awful.widget.prompt()
  screen.launcher_widget = awful.widget.launcher(
    {
      image = beautiful.awesome_icon,
      menu = menu.main
    }
  )


  screen.taglist_widget = awful.widget.taglist {
    screen = screen,
    filter  = awful.widget.taglist.filter.all,
    buttons = gears.table.join(
      awful.button({}, 1, function(t) t:view_only() end),
      -- awful.button({modkey}, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
      awful.button({}, 3, awful.tag.viewtoggle),
      -- awful.button({modkey}, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
      awful.button({}, 4, function(t) awful.tag.viewprev(t.screen) end),
      awful.button({}, 5, function(t) awful.tag.viewnext(t.screen) end)
    ),
  }

  screen.tasklist_widget = awful.widget.tasklist {
    screen = screen,
    filter = awful.widget.tasklist.filter.currenttags,
    buttons = gears.table.join(
      awful.button({}, 1, function(c)
        if c == client.focus then c.minimized = true
        else c:activate { context = "tasklist", action = "toggle_minimization" } end
      end),
      awful.button({}, 2, function(c) c:kill() end),
      awful.button({}, 3, function() awful.menu.client_list({theme = {width = 500}}) end),
      awful.button({}, 4, function() awful.client.focus.byidx(1) end),
      awful.button({}, 5, function() awful.client.focus.byidx(-1) end)
    ),
  }

  screen.tray_widget = wibox.widget.systray()

  screen.clock_widget = wibox.widget.textclock()

  screen.layout_widget = awful.widget.layoutbox {
    screen = screen,
    buttons = gears.table.join(
      awful.button({}, 1, function() awful.layout.inc(1) end),
      awful.button({}, 4, function() awful.layout.inc(1) end),
      awful.button({}, 3, function() awful.layout.inc(-1) end),
      awful.button({}, 5, function() awful.layout.inc(-1) end)
    ),
  }

  screen.bar = awful.wibar({position = 'top', screen = screen})
  screen.bar:setup {
    layout = wibox.layout.align.horizontal,
    -- left
    {
      layout = wibox.layout.fixed.horizontal,
      screen.launcher_widget,
      screen.taglist_widget,
      screen.rompt_widget,
    },
    -- middle
    screen.tasklist_widget,
    -- right
    {
      layout = wibox.layout.fixed.horizontal,
      screen.tray_widget,
      screen.clock_widget,
      globals.pulseaudio,
      screen.layout_widget,
    }
  }

  return screen.bar
end

return bar
