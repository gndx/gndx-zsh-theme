function directory() {
    local color="%F{white}"
    local directory="${PWD/#$HOME/~}"
    local color_reset="%f"
    echo "📁${color}${directory}${color_reset} "
}

function node_version() {
    local color="%F{green}"
    local version=$(node --version)
    local color_reset="%f"
    echo "${color}⬢ Node ${version}${color_reset} "
}

ZSH_THEME_GIT_PROMPT_PREFIX="%F{red}[%F{yellow}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f] "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{red}] 🚧"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{red}] ✅"

function update_git_status() {
    GIT_STATUS=$(git_prompt_info)
}

function git_status() {
    echo "${GIT_STATUS}${color_reset}"
}

function git_problema() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local rebase_in_progress=$(git rev-parse --is-rebase 2>/dev/null)
        local rebase_merge_dir=$(git rev-parse --git-dir)/rebase-merge

        if [ "$rebase_in_progress" = "true" ] || [ -d "$rebase_merge_dir" ]; then
            local conflicts=$(git diff --name-only --diff-filter=U)

            echo "Conflicts: $conflicts"

            if [ -n "$conflicts" ]; then
                echo "%F{red}⚠️ REBASE CONFLICTS%f"
            else
                echo "%F{red}🌱 REBASE IN PROGRESS%f"
            fi
        else
            local merge_in_progress=$(git rev-parse --is-merge 2>/dev/null)

            if [ "$merge_in_progress" = "true" ]; then
                echo "%F{red}⚡ MERGE IN PROGRESS%f"
            else
                echo "%F{red}%f"
            fi
        fi
    else
        echo "%F{red}%f"
    fi
}

function git_stash_count() {
    local count=$(git stash list 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        echo "%F{yellow}⚑ Stash: ${count}%f "
    fi
}

function git_cambios_remotos() {
    local remote_changes=0

    # Verificar cambios en la rama remota 'develop'
    git fetch origin develop >/dev/null 2>&1
    local develop_changes=$(git rev-list --count HEAD..origin/develop 2>/dev/null)
    if [[ "$develop_changes" && "$develop_changes" -gt 0 ]]; then
        remote_changes=1
    fi

    # Verificar cambios en la rama remota 'main'
    git fetch origin main >/dev/null 2>&1
    local main_changes=$(git rev-list --count HEAD..origin/main 2>/dev/null)
    if [[ "$main_changes" && "$main_changes" -gt 0 ]]; then
        remote_changes=1
    fi

    if [ "$remote_changes" -eq 1 ]; then
        echo "%F{red}🔀 REMOTE CHANGES%f"
    else
        echo "%F{green}✔️ NO REMOTE CHANGES%f"
    fi
}



function update_command_status() {
    local arrow=""
    local color_reset="%f"
    local reset_font="%F{white}"
    if $1; then
        arrow="%F{yellow}⚡"
    else
        arrow="%F{red}⚡"
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset} "
}

update_command_status true

function command_status() {
    echo "${COMMAND_STATUS}"
}

output_command_execute_after() {
    if [ "$COMMAND_TIME_BEGIN" = "" ]; then
        COMMAND_TIME_BEGIN=$(date +%s)
        return 1
    fi

    if [ "$COMMAND_TIME_BEGIN" = "-20200325" ] || [ "$COMMAND_TIME_BEGIN" = "" ]; then
        return 1
    fi

    local cmd="${$(fc -l | tail -1)#*  }"
    local color_cmd=""
    if $1; then
        color_cmd="%F{green}"
    else
        color_cmd="%F{red}"
    fi
    local color_reset="%f"
    cmd="${color_cmd}${cmd}${color_reset}"

    local time="[$(date +%H:%M:%S)]"
    local color_time="%F{cyan}"
    time="${color_time}${time}${color_reset}"
}

function docker_container_count() {
    local count=$(docker ps -q | wc -l)
    echo "%F{magenta}🐳 Docker Containers: ${count}%f "
}

function docker_image_count() {
    local count=$(docker images -q | wc -l)
    echo "%F{blue}📦 Docker Images: ${count}%f "
}

precmd() {
    local last_cmd_return_code=$?
    local last_cmd_result=true
    if [ "$last_cmd_return_code" = "0" ]; then
        last_cmd_result=true
    else
        last_cmd_result=false
    fi

    update_git_status

    update_command_status $last_cmd_result

    output_command_execute_after $last_cmd_result
}

setopt PROMPT_SUBST

TMOUT=1
TRAPALRM() {
    if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ]; then
        zle reset-prompt
    fi
}

PROMPT='$(git_cambios_remotos)$(git_problema)$(directory)$(git_status)$(git_stash_count)$(node_version)$(command_status)'
