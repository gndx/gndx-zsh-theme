function directory() {
    local color="%{$fg_no_bold[white]%}"
    local directory="${PWD/#$HOME/~}"
    local color_reset="%{$reset_color%}"
    echo "📁${color}${directory}${color_reset}"
}

function git_status() {
    local branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    local status=""
    if [[ -n $branch ]]; then
        if [[ -n $(git status --porcelain) ]]; then
            status="🚧"
        else
            status="✅"
        fi
        echo " [${branch}] ${status}"
    fi
}

function node_version() {
    local color="%{$fg_no_bold[green]%}"
    local version=$(node --version)
    local color_reset="%{$reset_color%}"
    echo " ⬢ Node ${version}${color_reset}"
}

function update_command_status() {
    local arrow=""
    local color_reset="%{$reset_color%}"
    local reset_font="%{$fg_no_bold[white]%}"
    if $1; then
        arrow="%{$fg_bold[yellow]%}⚡"
    else
        arrow="%{$fg_bold[red]%}⚡"
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset}"
}

update_command_status true

PROMPT='$(directory)$(git_status) $(node_version) $(command_status) '
