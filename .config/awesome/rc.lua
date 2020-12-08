local awful = require('awful')

local config_path = awful.util.getdir("config")
package.path = config_path .. "/?.lua;" .. package.path

-- pcall(require, 'luarocks.loader')

local array = require('array')
require('awful.autofocus')
local beautiful = require('beautiful')
local gears = require('gears')
local delayed_call = require("gears.timer").delayed_call
local menubar = require('menubar')
local naughty = require('naughty')
local wibox = require('wibox')

beautiful.init(os.getenv('XDG_CONFIG_HOME') .. '/awesome/theme.lua')

local globals = require('globals')
local bar = require('bar')
local menu = require('menu')
local utils = require('utils')
naughty.connect_signal("request::display_error", function(message, startup)
  naughty.notification {
    urgency = "critical",
    title = startup and "Startup error!" or "Runtime error!",
    message = message
  }
end)

modkey = globals.modkey

awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  awful.layout.suit.max
}

menubar.utils.terminal = globals.terminal

local function set_wallpaper(screen)
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == 'function' then
      wallpaper = wallpaper(screen)
    end
    gears.wallpaper.maximized(wallpaper, screen, true)
  end
end

-- re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal('property::geometry', set_wallpaper)

awful.screen.connect_for_each_screen(
  function(screen)
    -- wallpaper
    set_wallpaper(screen)

    -- set tags
    awful.tag(
      array.map(utils.table_pad_end(globals.tags, 9, function(i) return i end), function(t) return ' ' .. t .. ' ' end),
      screen,
      awful.layout.layouts[1]
    )

    bar.init(screen)
  end
)

-- mouse keybindings
root.buttons(gears.table.join(
  awful.button({}, 3, function() menu.main:toggle() end),
  awful.button({}, 4, awful.tag.viewnext),
  awful.button({}, 5, awful.tag.viewprev)
))

-- keybindings
local keys = require('keys')
root.keys(keys.keyboard.global)

awful.rules.rules = {
  -- all clients
  {
    rule = {},
    properties = {
      border_width = beautiful.border_width,
      border_color = beautiful.border_normal,
      focus = awful.client.focus.filter,
      raise = true,
      keys = keys.keyboard.client,
      buttons = keys.mouse.client,
      screen = awful.screen.preferred,
      placement = awful.placement.no_overlap + awful.placement.no_offscreen
    }
  },
  -- floating
  {
    rule_any = {
      instance = {'pinentry'},
      class = {},
      name = {'Event Tester'},
      role = {'pop-up'},
      type = {'dialog'}
    },
    properties = { floating = true }
  },
  { rule_any = { type = {'normal', 'dialog'} }, properties = { titlebars_enabled = false } },
  { rule = { class = "firefoxdeveloperedition" }, properties = { screen = 1, tag = "1" } },
  { rule = { class = "discord" }, properties = { screen = 1, tag = "3" } },
}

client.connect_signal(
  'manage',
  function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
      -- Prevent clients from being unreachable after screen count changes.
      awful.placement.no_offscreen(c)
    end
  end
)

-- focus follows mouse
client.connect_signal('mouse::enter', function(c) c:activate { context = "mouse_enter", raise = false } end)
client.connect_signal('focus', function(c) c.border_color = beautiful.border_focus end)
client.connect_signal('unfocus', function(c) c.border_color = beautiful.border_normal end)

-- autostart
awful.spawn('fish ' .. os.getenv('XDG_CONFIG_HOME') .. '/awesome/autostart.fish', nil, nil, 'autostart')

-- rounded borders
-- https://github.com/awesomeWM/awesome/issues/920
-- local function apply_shape(draw, shape, outer_shape_args, inner_shape_args)

--   local geo = draw:geometry()

--   local border = beautiful.base_border_width
--   local titlebar_height = border
--   --local titlebar_height = titlebar.is_enabled(draw) and beautiful.titlebar_height or border

--   local img = cairo.ImageSurface(cairo.Format.A1, geo.width, geo.height)
--   local cr = cairo.Context(img)

--   cr:set_operator(cairo.Operator.CLEAR)
--   cr:set_source_rgba(0,0,0,1)
--   cr:paint()
--   cr:set_operator(cairo.Operator.SOURCE)
--   cr:set_source_rgba(1,1,1,1)

--   shape(cr, geo.width, geo.height, outer_shape_args)
--   cr:fill()
--   draw.shape_bounding = img._native

--   cr:set_operator(cairo.Operator.CLEAR)
--   cr:set_source_rgba(0,0,0,1)
--   cr:paint()
--   cr:set_operator(cairo.Operator.SOURCE)
--   cr:set_source_rgba(1,1,1,1)

--   gears.shape.transform(shape):translate(border, titlebar_height)(
--     cr,
--     geo.width - border*2,
--     geo.height - titlebar_height - border,
--     inner_shape_args
--   )
--   cr:fill()
--   draw.shape_clip = img._native

--   img:finish()
-- end


-- local pending_shapes = {}
-- local function round_up_client_corners(c, force, reference)
--   if not force and (
--     (not beautiful.client_border_radius or beautiful.client_border_radius == 0)
--     or (not c.valid)
--     or (c.fullscreen)
--     or (pending_shapes[c])
--     or (#c:tags() < 1)
--   ) or beautiful.skip_rounding_for_crazy_borders then
--     --clog('R1 F='..(force or 'nil').. ', R='..(reference or '')..', C='.. (c and c.name or '<no name>'), c)
--     return
--   end
--   --clog({"Geometry", c:tags()}, c)
--   pending_shapes[c] = true
--   delayed_call(function()
--     local client_tag = choose_tag(c)
--     if not client_tag then
--       nlog('no client tag')
--       return
--     end
--     local num_tiled = get_num_tiled(client_tag)
--     --clog({"Shape", num_tiled, client_tag.master_fill_policy, c.name}, c)
--     --if not force and (c.maximized or (
--     if (c.maximized or c.fullscreen or (
--       (num_tiled<=1 and client_tag.master_fill_policy=='expand')
--       and not c.floating
--       and client_tag.layout.name ~= "floating"
--     )) then
--       pending_shapes[c] = nil
--       --nlog('R2 F='..(force and force or 'nil').. ', R='..reference..', C='.. c.name)
--       return
--     end
--     -- Draw outer shape only if floating layout or useless gaps
--     local outer_shape_args = 0
--     if client_tag.layout.name == "floating" or client_tag:get_gap() ~= 0 then
--       outer_shape_args = beautiful.client_border_radius
--     end
--     local inner_shape_args = beautiful.client_border_radius * 0.75
--     --local inner_shape_args = beautiful.client_border_radius - beautiful.base_border_width
--     --if inner_shape_args < 0 then inner_shape_args = 0 end
--     apply_shape(c, gears.shape.rounded_rect, outer_shape_args, inner_shape_args)
--     --clog("apply_shape "..(reference or 'no_ref'), c)
--     pending_shapes[c] = nil
--     --nlog('OK F='..(force and "true" or 'nil').. ', R='..reference..', C='.. c.name)
--   end)
-- end

-- client.connect_signal("manage", function (c)
--   local awesome_startup = awesome.startup
--   delayed_call(function()
--       if c == client.focus then
--         on_client_focus(c)
--         if awesome_startup then
--           round_up_client_corners(c, false, "MF")
--         end
--       else
--         on_client_unfocus(c, true, function(_c)
--           if awesome_startup then
--             round_up_client_corners(_c, false, "MU")
--           end
--         end)
--       end
--   end)
-- end)

-- client.connect_signal("property::size", function (c)
--   if not awesome.startup then
--     round_up_client_corners(c, false, "S")
--   end
-- end)
