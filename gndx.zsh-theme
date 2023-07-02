function real_time() {
    local color="%{$fg_no_bold[cyan]%}";
    local color_reset="%{$reset_color%}";
    echo "${color}$(date +%H:%M:%S)${color_reset}"
}

function directory() {
    local color="%{$fg_no_bold[white]%}";
    local directory="${PWD/#$HOME/~}";
    local color_reset="%{$reset_color%}";
    echo "📁${color}${directory}${color_reset} "
}

function node_version() {
    local color="%{$fg_no_bold[green]%}"
    local version=$(node --version);
    local color_reset="%{$reset_color%}";
    echo "${color}⬢ Node ${version}${color_reset} "
}

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_no_bold[red]%}[%{$fg_no_bold[yellow]%}";
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} ";
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg_no_bold[red]%}] 🚧";
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_no_bold[red]%}] ✅";

function update_git_status() {
    GIT_STATUS=$(git_prompt_info);
}

function git_status() {
    echo "${GIT_STATUS}${color_reset}"
}

function update_command_status() {
    local arrow="";
    local color_reset="%{$reset_color%}";
    local reset_font="%{$fg_no_bold[white]%}";
    if $1;
    then
        arrow="%{$fg_bold[yellow]%}⚡";
    else
        arrow="%{$fg_bold[red]%}⚡";
    fi
    COMMAND_STATUS="${arrow}${reset_font}${color_reset} ";
}

update_command_status true;

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
        color_cmd="%{$fg_no_bold[green]%}"
    else
        color_cmd="%{$fg_bold[red]%}"
    fi
    local color_reset="%{$reset_color%}"
    cmd="${color_cmd}${cmd}${color_reset}"

    local time="[$(date +%H:%M:%S)]"
    local color_time="%{$fg_no_bold[cyan]%}"
    time="${color_time}${time}${color_reset}"
}


precmd() {
    local last_cmd_return_code=$?;
    local last_cmd_result=true;
    if [ "$last_cmd_return_code" = "0" ];
    then
        last_cmd_result=true;
    else
        last_cmd_result=false;
    fi

    update_git_status;

    update_command_status $last_cmd_result;

    output_command_execute_after $last_cmd_result;
}

setopt PROMPT_SUBST;

TMOUT=1;
TRAPALRM() {
    if [ "$WIDGET" = "" ] || [ "$WIDGET" = "accept-line" ] ; then
        zle reset-prompt;
    fi
}

PROMPT='$(real_time) $(directory) $(git_status) $(node_version) $(command_status)'
