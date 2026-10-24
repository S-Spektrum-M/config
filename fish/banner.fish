# Print the Mach banner when an interactive Fish session starts.

# test "$SHLVL" -eq 1; or return 0              # Only print the banner for the first shell level

function mach_banner
    set -l banner \
        '                        █▀▄▀█ ▄▀█ █▀▀ █░█                        ' \
        '                        █░▀░█ █▀█ █▄▄ █▀█                        '
    set -l banner_width 65
    set -l padding 0

    if set -q COLUMNS; and test "$COLUMNS" -gt "$banner_width"
        set padding (math --scale=0 "($COLUMNS - $banner_width) / 2")
    end

    printf '\n\e[36m'
    for line in $banner
        printf '%*s%s\n' "$padding" '' "$line"
    end
    printf '\e[0m\n'
end

mach_banner
functions -e mach_banner
