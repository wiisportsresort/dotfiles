local awful = require('awful')
local gears = require('gears')
local hotkeys_popup = require('awful.hotkeys_popup')
require('awful.hotkeys_popup.keys')
local menubar = require('menubar')
local naughty = require('naughty')

local globals = require('globals')
local utils = require('utils')

local function mod(keys)
  local mods = {}
  for _, key in ipairs(keys) do
    if key == 'mod' or key == 'Mod' then
      table.insert(mods, globals.modkey)
    else
      table.insert(mods, key)
    end
  end
  return mods
end

local function keytable(t)
  local packed = {}
  for _, keydef in ipairs(t) do
    local keys = utils.strsplit(keydef.keys or keydef[3], '+')
    local modifiers = {table.unpack(keys)}
    table.remove(modifiers, #modifiers)
    local key = {table.unpack(keys)}
    key = key[#key]
    table.insert(packed, awful.key(
      mod(modifiers),
      key,
      keydef.exec or keydef[4],
      { group = keydef.group or keydef[1], description = keydef.doc or keydef[2] }
    ))
  end
  return table.unpack(packed)
end


local view_tag = awful.key {
  modifiers = {globals.modkey},
  keygroup = "numrow",
  description = "only view tag",
  group = "tag",
  on_press = function(n)
    local screen = awful.screen.focused()
    local tag = screen.tags[n]
    if tag then tag:view_only() end
  end,
}

local toggle_tag = awful.key {
  modifiers   = {globals.modkey, "Control"},
  keygroup    = "numrow",
  description = "toggle tag",
  group       = "tag",
  on_press    = function (n)
      local screen = awful.screen.focused()
      local tag = screen.tags[n]
      if tag then awful.tag.viewtoggle(tag) end
  end,
}

local move_to_tag = awful.key {
  modifiers = { globals.modkey, "Shift" },
  keygroup = "numrow",
  description = "move focused client to tag",
  group = "tag",
  on_press = function(n)
    if client.focus then
      local tag = client.focus.screen.tags[n]
      if tag then client.focus:move_to_tag(tag) end
    end
  end,
}

local function unminimize()
  local c = awful.client.restore()
  if c then
    c:emit_signal('request::activate', 'key.unminimize', {raise = true})
  end
end

local keys = { keyboard = {}, mouse = {} }

keys.keyboard.global = gears.table.join(view_tag, toggle_tag, move_to_tag, keytable({
  {'awesome', 'show help', 'mod+s', hotkeys_popup.show_help},
  {'awesome', 'reload', 'mod+Shift+r', awesome.restart},
  {'awesome', 'exit', 'mod+Shift+e', awesome.quit},
  {'client', 'focus next', 'mod+Right', function() awful.client.focus.byidx(1) end},
  {'client', 'focus prev', 'mod+Left', function() awful.client.focus.byidx(-1) end},
  {'client', 'swap with next', 'mod+Shift+Right', function() awful.client.swap.byidx(1) end},
  {'client', 'swap with prev', 'mod+Shift+Left', function() awful.client.swap.byidx(-1) end},
  {'client', 'unminimize', 'mod+Shift+n', unminimize},
  {'layout', 'inc master width', 'mod+Control+Right', function() awful.tag.incmwfact(0.05) end},
  {'layout', 'dec master width', 'mod+Control+Left', function() awful.tag.incmwfact(-0.05) end},
  {'layout', 'inc master count', 'mod+Control+Down', function() awful.tag.incnmaster(1, nil, true) end},
  {'layout', 'dec master count', 'mod+Control+Up', function() awful.tag.incnmaster(-1, nil, true) end},
  {'layout', 'tab layout', 'mod+w', function() awful.layout.set(awful.layout.suit.max) end},
  {'layout', 'tiled', 'mod+e', function() awful.layout.set(awful.layout.suit.tile) end},
  {'layout', 'cycle layout', 'mod+Shift+space', function() awful.layout.inc(1) end},
  {'programs', 'take screenshot', 'Print', function() os.execute('flameshot gui') end},
  {'programs', 'open terminal', 'mod+Return', function() awful.spawn(globals.terminal) end},
  {'programs', 'show exec prompt', 'mod+Shift+d', function() awful.screen.focused().prompt_widget:run() end},
  {'programs', 'show launcher', 'mod+d', function() menubar.show() end},
  {'audio', 'inc volume', 'XF86AudioRaiseVolume', globals.pulseaudio.volume_up},
  {'audio', 'dec volume', 'XF86AudioLowerVolume', globals.pulseaudio.volume_down},
  {'audio', 'toggle mute', 'XF86AudioMute', globals.pulseaudio.toggle_muted},
}))

keys.keyboard.client = gears.table.join(keytable({
  {'client', 'toggle fullscreen', 'mod+f', function(c) c.fullscreen = not c.fullscreen; c:raise() end},
  {'client', 'kill', 'mod+Shift+q', function(c) c:kill() end},
  {'client', 'toggle floating', 'mod+Shift+space', awful.client.floating.toggle},
  {'client', 'swap with master', 'mod+Shift+Return', function(c) c:swap(awful.client.getmaster()) end},
  {'client', 'toggle always-on-top', 'mod+t', function(c) c.ontop = not c.ontop end},
  {'client', 'minimize', 'mod+n', function(c) c.minimized = true end},
}))

keys.mouse.client = gears.table.join(
  awful.button({}, 1, function(c) c:activate { context = "mouse_click" } end),
  awful.button({modkey}, 1, function(c) c:activate { context = "mouse_click", action = "mouse_move" } end),
  awful.button({modkey}, 3, function(c) c:activate { context = "mouse_click", action = "mouse_resize" } end)
)

return keys
