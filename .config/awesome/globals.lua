local globals = {}

globals.terminal = 'env vblank_mode=1 alacritty'
globals.editor = 'code' or os.getenv('EDITOR') or 'nano'
globals.editor_cmd = globals.terminal .. ' -e ' .. globals.editor
globals.modkey = 'Mod4'
globals.pulseaudio = require("pulseaudio_widget")
globals.tags = {'1 www', '2 work', '3 chat', '4 game'}

return globals
