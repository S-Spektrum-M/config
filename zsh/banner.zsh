# Print the Mach banner when an interactive Zsh session starts.

# (( SHLVL == 1 )) || return 0                  # Only print the banner for the first shell level

function mach_banner() {
    # local -a banner=(
    #     '                        █▀▄▀█ ▄▀█ █▀▀ █░█                        '
    #     '                 .      █░▀░█ █▀█ █▄▄ █▀█      .                 '
    #     '                //                             \\                '
    #     '               //                               \\               '
    #     '              //             zsh 0.9             \\              '
    #     '             //                _._                \\             '
    #     '          .---.              .//|\\.              .---.          '
    #     '________ / .-. \_________..-~ _.-._ ~-..________ / .-. \_________'
    #     "         \ ._. /    H-     '--.___.--'     -H    \ ._. /         "
    #     '          •---•     H          [H]          H     •---•          '
    #     '                   _H_         _H_         _H_                   '
    #     '                   UUU         UUU         UUU                   '
    # )
    local -a banner=(
        '                        █▀▄▀█ ▄▀█ █▀▀ █░█                        '
        '                        █░▀░█ █▀█ █▄▄ █▀█                        '
    )
    local banner_width=65
    local padding=0
    local line

    (( COLUMNS > banner_width )) && padding=$(( (COLUMNS - banner_width) / 2 ))

    print -- $'\n'                              # Print a padding newline before the banner
    print -n -- $'\e[36m'
    for line in "${banner[@]}"; do
        printf '%*s%s\n' "$padding" '' "$line"  # centered
        # print -r -- "$line"                   # left-aligned
    done
    print -- $'\e[0m'                           # Print a padding newline after the banner
}

mach_banner
unfunction mach_banner
