bass source "$HOME/.config/environment"


#set fish_user_paths \
#    node_modules/.bin \
#    /opt/android-sdk/tools/bin \
#    /opt/android-sdk/platform-tools \
#    $HOME/.cargo/bin \
#    $HOME/.local/bin \
#    $HOME/.bin \
#    $fish_user_paths

# dirs
set c "$HOME/.config"
set d "$HOME/dev"
set df "$HOME/.dotfiles"
set dl "$XDG_DATA_HOME/downloads"
set lb "$HOME/.local/bin"
set ls "$XDG_DATA_HOME"
set ub "/usr/bin"
set us "/usr/share"
set sa "$HOME/.steam/root/steamapps"

# vcs
abbr -- gcm git commit --message
abbr -- gs git status
abbr -- gsp git status --porcelain
abbr -- y yadm

# config
abbr -- caw code "$XDG_CONFIG_HOME/awsome"
abbr -- cfs nvim "$XDG_CONFIG_HOME/fish/config.fish"
abbr -- fsc cd "$XDG_CONFIG_HOME/fish"
abbr -- cen nvim "$XDG_CONFIG_HOME/environment"
abbr -- cnx nvim "$XDG_CONFIG_HOME/X11/nvidia-xinitrc"
# abbr -- ci3 nvim "$XDG_CONFIG_HOME/i3/config"
# abbr -- i3c cd "$XDG_CONFIG_HOME/i3"
# abbr -- cpb nvim "$XDG_CONFIG_HOME/polybar"
# abbr -- pbc cd "$XDG_CONFIG_HOME/polybar"
abbr -- cpc nvim "$XDG_CONFIG_HOME/picom/picom.conf"
abbr -- pcc cd "$XDG_CONFIG_HOME/picom"
# abbr -- cdn nvim "$XDG_CONFIG_HOME/dunst/dunstrc"
abbr -- dnc cd "$XDG_CONFIG_HOME/dunst"
abbr -- cnv nvim "$XDG_CONFIG_HOME/nvim/init.vim"
abbr -- nvc cd "$XDG_CONFIG_HOME/nvim"
abbr -- cxi nvim "$XDG_CONFIG_HOME/X11/xinitrc"
abbr -- cxp nvim "$XDG_CONFIG_HOME/X11/xprofile"
abbr -- cxs nvim "$XDG_CONFIG_HOME/X11/xsession"
abbr -- cxr nvim "$XDG_CONFIG_HOME/X11/xresources"

# system
abbr -- jf journalctl -f
abbr -- s sudo systemctl
abbr -- sp sudo pacman
abbr -- sx startx
abbr -- nvsx nvidia-startx

# other
#abbr -- l ls -lah
abbr -- n nvim
abbr -- pkp pkill picom
abbr -- ... cd ../..
abbr -- .... cd ../../..
abbr -- ..... cd ../../../..
abbr -- ...... cd ../../../../..


function fish_greeting
end

function sudo -d "Replacement for Bash 'sudo !!' command to run last command using sudo."
    if test "$argv" = !!
        eval command sudo $history[1]
    else
        command sudo $argv
    end
end

function j -d "z but j"
    z $argv
end

function jj -d "z but single letters only"
    z (echo "$argv" | grep -o .)
end

function l -w exa
    set -- opts --long --all --group
    command git rev-parse --is-inside-work-tree >/dev/null ^&1
    and set -- opts $opts --git
    exa $opts $argv
end

function yay -w yay
    command yay --nodiffmenu --noeditmenu --nocleanmenu $argv
end

function mvn -w mvn
    command mvn -gs "$XDG_CONFIG_HOME/maven/settings.xml" $argv
end

function startx -w startx
    pushd $HOME
    command startx "$XDG_CONFIG_HOME/X11/xinitrc" $argv -- "$XDG_CONFIG_HOME/X11/xserverrc"
    popd
end

function yarn -w yarn
    command yarn --use-yarnrc "$XDG_CONFIG_HOME/yarn/config" $argv
end

function nvidia-settings -w nvidia-settings
    command nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings" $argv
end

function mkcd
    mkdir -p -- "$argv[1]" && cd "$argv[1]"
end

function brightness -w xrandr
    xrandr --output (xrandr | grep " connected" | cut -f1 -d " ") --brightness $argv
end

function nvidia-startx
    set dry_run 0

    function execute
        #if test $dry_run = 1
        #    echo "> Dry run: $argv"
        #else
        pushd $HOME
        eval $argv
        popd
        #end
    end

    if test $USER = "root"
        then
        echo "Cannot run as root." 1>&2
        return 1
    end

    #if test $argv[1] = "-d"
    #    set dry_run 1
    #end

    # calculate current VT
    set lvt (fgconsole)

    if test $status != 0
        return 1
    end

    # calculate first usable display
    set xnum "-1"
    set sock "something"
    while test "$sock" != ""
        set xnum (math $xnum + 1)
        set sock (ls -A -1 /tmp/.X11-unix | grep "X$xnum")
    end

    set newdisplay ":$xnum"

    set execl "/etc/X11/xinit/nvidia-xinitrc $XDG_CONFIG_HOME/X11/xinitrc $argv"

    set cmd "xinit $execl -- $newdisplay vt$lvt -nolisten tcp -br -config nvidia-xorg.conf -configdir nvidia-xorg.conf.d"

    execute $cmd
end

# prompt
function _prompt_ssh_status
    if [ -n "$SSH_CLIENT" ]
        set_color -d blue
        echo -ns "ssh "
    end
end

function _pretty_ms -S -a ms -a interval
    set -l interval_ms
    set -l scale 1

    switch $interval
        case s
            set interval_ms 1000
        case m
            set interval_ms 60000
        case h
            set interval_ms 3600000
            set scale 2
    end

    echo -ns (math -s$scale "$ms/$interval_ms")
    echo -ns $interval
end

function _prompt_cmd_duration -S -d "Show command duration"
    [ -z "$CMD_DURATION" -o "$CMD_DURATION" -lt 100 ]
    and return

    if [ "$CMD_DURATION" -lt 5000 ]
        set_color -d
        echo -ns $CMD_DURATION"ms"
    else if [ "$CMD_DURATION" -lt 60000 ]
        set_color -d
        _pretty_ms $CMD_DURATION s
    else if [ "$CMD_DURATION" -lt 3600000 ]
        set_color -d
        _pretty_ms $CMD_DURATION m
    else
        set_color -d
        _pretty_ms $CMD_DURATION h
    end

    set_color $fish_color_normal
    set_color $fish_color_autosuggestion

    echo -ns " "
end

function _prompt_return_status
    if [ $returncode -ne 0 ]
        set_color red
        echo -ns "$returncode "
    end
end

function _prompt_pwd
    set_color blue
    echo -ns (prompt_pwd) " "
end

function _prompt_git_status
    if command git rev-parse --is-inside-work-tree >/dev/null ^&1

        set -l dirty (
            command git status -s --ignore-submodules=dirty |
            wc -l |
            sed -e 's/^ *//' -e 's/ *$//' ^ /dev/null
        )

        set -l ref (
            command git describe --tags --exact-match ^ /dev/null
            or command git symbolic-ref --short HEAD ^ /dev/null
            or command git rev-parse --short HEAD ^ /dev/null
        )

        set -l ahead_count (
            command git rev-list --count --left-right "@{upstream}...HEAD" ^ /dev/null
        )

        if [ "$dirty" != "0" ]
            set_color red
            echo -ns "$dirty* "
        end

        switch "$ahead_count"
            case ""
                # no upstream
            case "0"\t"0"
                # none
            case "*"\t"0"
                set_color yellow
                echo -ns (echo $ahead_count | sed -e "s/\t0//")"v "
                set_color normal
            case "0"\t"*"
                set_color cyan
                echo -ns (echo $ahead_count | sed -e "s/0\t//")"^ "
                set_color normal
            case "*"
                set_color magenta
                echo -ns "+- "
                set_color normal
        end

        set_color green

        echo -ns "$ref "
    end
end

function _prompt_char
    if test (id -u $USER) = 0
        set_color red
        echo -ns "# "
    else
        echo -ns "x> "
    end
end

function _prompt_join
    for func in $argv
        set_color normal
        $func
    end
    set_color normal
end

function fish_prompt
    set -g returncode $status
    _prompt_join \
        _prompt_ssh_status \
        _prompt_cmd_duration \
        _prompt_return_status \
        _prompt_pwd \
        _prompt_git_status \
        _prompt_char
end
