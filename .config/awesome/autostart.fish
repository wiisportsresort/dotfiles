#!/bin/fish

set awesomepid (ps a | grep "xinit.*awesome.*vt[0-9]" | awk '{gsub(/^ +| +$/,"")} {print $1}')
set existing (cat "$XDG_RUNTIME_DIR/awesome.pid")

if test $existing = $awesomepid
    exit 1
end

echo "$awesomepid" >$XDG_RUNTIME_DIR/awesome.pid

if not pidof nextcloud
    fish -c 'sleep 15 && nextcloud &' >/dev/null &
end

if not pidof flameshot
    flameshot >/dev/null &
end

if not pidof nm-applet
    nm-applet >/dev/null &
end

awesome-client "
local naughty = require('naughty')
naughty.notification { title = 'autostart complete' }
"
