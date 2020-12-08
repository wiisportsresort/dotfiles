local awful = require('awful')
local beautiful = require('beautiful')
local hotkeys_popup = require('awful.hotkeys_popup')
local naughty = require('naughty')

local globals = require('globals')

local menu = {}

menu.main = awful.menu({
  items = {
    {'awesome', {
      {'hotkeys', function() hotkeys_popup.show_help(nil, awful.screen.focused()) end},
      {'manual', globals.terminal .. ' -e man awesome'},
      {'edit config', globals.editor_cmd .. ' ' .. awesome.conffile},
      {'restart', awesome.restart},
      {'quit', awesome.quit}
    }, beautiful.awesome_icon},
    {'open terminal', globals.terminal}
  }
})


return menu
