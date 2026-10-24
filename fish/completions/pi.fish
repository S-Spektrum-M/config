# Fish completion for pi, the AI coding assistant.

function __fish_pi_providers
    if not set -q __pi_cached_providers; or test (count $__pi_cached_providers) -eq 0
        set -g __pi_cached_providers (pi --list-models 2>/dev/null | awk 'NR > 1 { print $1 }' | sort -u)
    end
    printf '%s\n' $__pi_cached_providers
end

function __fish_pi_models
    if not set -q __pi_cached_models; or test (count $__pi_cached_models) -eq 0
        set -g __pi_cached_models (pi --list-models 2>/dev/null | awk 'NR > 1 { print $1 "/" $2; print $2 }' | sort -u)
    end
    printf '%s\n' $__pi_cached_models
end

function __fish_pi_installed_sources
    if not set -q __pi_cached_sources; or test (count $__pi_cached_sources) -eq 0
        set -g __pi_cached_sources (pi list 2>/dev/null | awk '/^  [^ \/]/ { print $1 }')
    end
    printf '%s\n' $__pi_cached_sources
end

function __fish_pi_package_source
    set -l tok (commandline -ct)
    switch "$tok"
        case 'npm:*' 'git:*' 'https://*' 'ssh://*'
            return
        case './*' '../*' '/*' '~*'
            __fish_complete_path "$tok"
        case '*'
            printf '%s\t%s\n' \
                'npm:' 'package source prefix' \
                'git:' 'package source prefix' \
                'https://' 'package source prefix' \
                'ssh://' 'package source prefix'
            __fish_complete_path "$tok"
    end
end

# Subcommand helpers
set -l __pi_subcommands install remove uninstall update list config auth

function __fish_pi_needs_subcommand
    set -l cmd (commandline -opc)
    for c in $cmd[2..-1]
        if contains -- "$c" install remove uninstall update list config auth
            return 1
        end
    end
    return 0
end

function __fish_pi_using_subcommand
    set -l cmd (commandline -opc)
    for c in $cmd[2..-1]
        if contains -- "$c" $argv
            return 0
        end
    end
    return 1
end

function __fish_pi_auth_needs_subcommand
    __fish_pi_using_subcommand auth; or return 1
    set -l cmd (commandline -opc)
    for c in $cmd[2..-1]
        if contains -- "$c" print-api-key print-bearer-token check
            return 1
        end
    end
    return 0
end

function __fish_pi_auth_using_subcommand
    __fish_pi_using_subcommand auth; or return 1
    set -l cmd (commandline -opc)
    for c in $cmd[2..-1]
        if contains -- "$c" $argv
            return 0
        end
    end
    return 1
end

# Subcommands
complete -c pi -f -n __fish_pi_needs_subcommand -a install -d 'Install a package and add it to settings'
complete -c pi -f -n __fish_pi_needs_subcommand -a remove -d 'Remove a package and its source from settings'
complete -c pi -f -n __fish_pi_needs_subcommand -a uninstall -d 'Alias for remove'
complete -c pi -f -n __fish_pi_needs_subcommand -a update -d 'Update pi, packages, or model catalogs'
complete -c pi -f -n __fish_pi_needs_subcommand -a list -d 'List installed packages'
complete -c pi -f -n __fish_pi_needs_subcommand -a config -d 'Configure package resources'
complete -c pi -f -n __fish_pi_needs_subcommand -a auth -d 'Print credentials or check provider readiness'

# Root options
complete -c pi -n __fish_pi_needs_subcommand -l provider -r -f -a '(__fish_pi_providers)' -d 'Provider name'
complete -c pi -n __fish_pi_needs_subcommand -l model -r -f -a '(__fish_pi_models)' -d 'Model pattern or ID'
complete -c pi -n __fish_pi_needs_subcommand -l api-key -r -f -d 'API key'
complete -c pi -n __fish_pi_needs_subcommand -l system-prompt -r -f -d 'Replace the system prompt'
complete -c pi -n __fish_pi_needs_subcommand -l append-system-prompt -r -d 'Append text or file contents to the system prompt'
complete -c pi -n __fish_pi_needs_subcommand -l mode -r -f -a 'text json rpc' -d 'Output mode'
complete -c pi -n __fish_pi_needs_subcommand -s p -l print -d 'Process the prompt non-interactively and exit'
complete -c pi -n __fish_pi_needs_subcommand -s c -l continue -d 'Continue the previous session'
complete -c pi -n __fish_pi_needs_subcommand -s r -l resume -d 'Select a session to resume'
complete -c pi -n __fish_pi_needs_subcommand -l session -r -F -d 'Use a session file or partial UUID'
complete -c pi -n __fish_pi_needs_subcommand -l session-id -r -f -d 'Use an exact project session ID'
complete -c pi -n __fish_pi_needs_subcommand -l fork -r -F -d 'Fork a session'
complete -c pi -n __fish_pi_needs_subcommand -l session-dir -r -a '(__fish_complete_directories)' -d 'Set the session storage directory'
complete -c pi -n __fish_pi_needs_subcommand -l no-session -d 'Use an ephemeral session'
complete -c pi -n __fish_pi_needs_subcommand -s n -l name -r -f -d 'Set the session display name'
complete -c pi -n __fish_pi_needs_subcommand -l models -r -f -a '(__fish_pi_models)' -d 'Set comma-separated model patterns for cycling'
complete -c pi -n __fish_pi_needs_subcommand -o nt -l no-tools -d 'Disable all tools by default'
complete -c pi -n __fish_pi_needs_subcommand -o nbt -l no-builtin-tools -d 'Disable built-in tools by default'
complete -c pi -n __fish_pi_needs_subcommand -s t -l tools -r -f -a 'read bash edit write grep find ls' -d 'Enable only these comma-separated tools'
complete -c pi -n __fish_pi_needs_subcommand -o xt -l exclude-tools -r -f -a 'read bash edit write grep find ls' -d 'Disable these comma-separated tools'
complete -c pi -n __fish_pi_needs_subcommand -l thinking -r -f -a 'off minimal low medium high xhigh max' -d 'Set the thinking level'
complete -c pi -n __fish_pi_needs_subcommand -s e -l extension -r -F -d 'Load an extension file'
complete -c pi -n __fish_pi_needs_subcommand -o ne -l no-extensions -d 'Disable extension discovery'
complete -c pi -n __fish_pi_needs_subcommand -l skill -r -F -d 'Load a skill file or directory'
complete -c pi -n __fish_pi_needs_subcommand -o ns -l no-skills -d 'Disable skill discovery and loading'
complete -c pi -n __fish_pi_needs_subcommand -l prompt-template -r -F -d 'Load a prompt template file or directory'
complete -c pi -n __fish_pi_needs_subcommand -o np -l no-prompt-templates -d 'Disable prompt template discovery'
complete -c pi -n __fish_pi_needs_subcommand -l theme -r -F -d 'Load a theme file or directory'
complete -c pi -n __fish_pi_needs_subcommand -l no-themes -d 'Disable theme discovery'
complete -c pi -n __fish_pi_needs_subcommand -o nc -l no-context-files -d 'Disable context-file discovery'
complete -c pi -n __fish_pi_needs_subcommand -l export -r -F -d 'Export a session to HTML and exit'
complete -c pi -n __fish_pi_needs_subcommand -l list-models -r -f -d 'List available models, optionally filtered'
complete -c pi -n __fish_pi_needs_subcommand -l verbose -d 'Force verbose startup'
complete -c pi -n __fish_pi_needs_subcommand -l tui-mode -r -f -a 'regular fullscreen' -d 'Set the TUI mode'
complete -c pi -s a -l approve -d 'Trust project-local files'
complete -c pi -o na -l no-approve -d 'Ignore project-local files'
complete -c pi -n __fish_pi_needs_subcommand -l offline -d 'Disable startup network operations'
complete -c pi -s h -l help -d 'Show help'
complete -c pi -n __fish_pi_needs_subcommand -s v -l version -d 'Show the version'

# install subcommand
complete -c pi -f -n '__fish_pi_using_subcommand install' -s l -l local -d 'Install project-locally'
complete -c pi -f -n '__fish_pi_using_subcommand install' -a '(__fish_pi_package_source)'

# remove / uninstall subcommand
complete -c pi -f -n '__fish_pi_using_subcommand remove uninstall' -s l -l local -d 'Remove from project settings'
complete -c pi -f -n '__fish_pi_using_subcommand remove uninstall' -a '(__fish_pi_installed_sources)' -d 'installed package'

# update subcommand
complete -c pi -f -n '__fish_pi_using_subcommand update' -l self -d 'Update pi only'
complete -c pi -f -n '__fish_pi_using_subcommand update' -l extensions -d 'Update installed packages only'
complete -c pi -f -n '__fish_pi_using_subcommand update' -l models -d 'Refresh model catalogs only'
complete -c pi -f -n '__fish_pi_using_subcommand update' -l all -d 'Update pi and installed packages'
complete -c pi -f -n '__fish_pi_using_subcommand update' -l extension -r -a '(__fish_pi_installed_sources)' -d 'Update one package only'
complete -c pi -f -n '__fish_pi_using_subcommand update' -l force -d 'Reinstall pi even when already current'
complete -c pi -f -n '__fish_pi_using_subcommand update' -a 'self pi (__fish_pi_installed_sources)'

# config subcommand
complete -c pi -f -n '__fish_pi_using_subcommand config' -s l -l local -d 'Edit project overrides'

# auth subcommand
complete -c pi -f -n __fish_pi_auth_needs_subcommand -a print-api-key -d 'Print a credential for an external client'
complete -c pi -f -n __fish_pi_auth_needs_subcommand -a print-bearer-token -d 'Print or refresh an OAuth bearer token'
complete -c pi -f -n __fish_pi_auth_needs_subcommand -a check -d 'Check provider readiness and credentials'
complete -c pi -f -n '__fish_pi_auth_using_subcommand print-api-key print-bearer-token check' -l provider -r -a '(__fish_pi_providers)' -d 'Provider name'
complete -c pi -f -n '__fish_pi_auth_using_subcommand print-api-key print-bearer-token check' -l model -r -a '(__fish_pi_models)' -d 'Model pattern or ID'
complete -c pi -f -n '__fish_pi_auth_using_subcommand print-bearer-token' -l min-expiry -r -d 'Require a minimum remaining token lifetime'
complete -c pi -f -n '__fish_pi_auth_using_subcommand check' -l json -d 'Emit JSON output'
complete -c pi -f -n '__fish_pi_auth_using_subcommand check' -l credentials -d 'Include the credential in output'
complete -c pi -f -n '__fish_pi_auth_using_subcommand check' -l no-refresh -d 'Do not refresh expired OAuth credentials'
