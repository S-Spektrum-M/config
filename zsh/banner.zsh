# Print the Mach banner when an interactive Zsh session starts.

function mach_banner() {
    local -a banner=(
        '                        █▀▄▀█ ▄▀█ █▀▀ █░█                        '
        '                 .      █░▀░█ █▀█ █▄▄ █▀█      .                 '
        '                //                             \\                '
        '               //                               \\               '
        '              //             zsh 0.9             \\              '
        '             //                _._                \\             '
        '          .---.              .//|\\.              .---.          '
        '________ / .-. \_________..-~ _.-._ ~-..________ / .-. \_________'
        "         \ ._. /    H-     '--.___.--'     -H    \ ._. /         "
        '          •---•     H          [H]          H     •---•          '
        '                   _H_         _H_         _H_                   '
        '                   UUU         UUU         UUU                   '
    )
    local banner_width=65
    local padding=0
    local line

    (( COLUMNS > banner_width )) && padding=$(( (COLUMNS - banner_width) / 2 ))

    print -n -- $'\e[36m'
    for line in "${banner[@]}"; do
        printf '%*s%s\n' "$padding" '' "$line"
    done
    print -n -- $'\e[0m'
}

mach_banner
unfunction mach_banner
