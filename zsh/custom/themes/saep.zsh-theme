#!/usr/bin/env zsh

# Based on the bira oh my zsh theme

local return_code="%(?..%{$fg[red]%} %? %{$reset_color%})"

if [[ $UID -eq 0 ]]; then
    local user_host='%{$terminfo[bold]$fg[red]%}%n@%m %{$reset_color%}'
    local user_symbol='#'
elif [[ -z $SSH_CONNECTION ]]; then
    local user_host=' '
    local user_symbol='$'
else
    local user_host='%{$fg[blue]%}%n%{$reset_color%}@%{$terminfo[bold]$fg[blue]%}%m %{$reset_color%}'
    local user_symbol='$'
fi

local current_dir='%{$terminfo[bold]$fg[white]%}%~ %{$reset_color%}'
local git_branch='$(git_prompt_info)'
local rvm_ruby='$(ruby_prompt_info)'
local venv_prompt='$(virtualenv_prompt_info)'

ZSH_THEME_RVM_PROMPT_OPTIONS="i v g"

PROMPT="╭─${user_host}${current_dir}${rvm_ruby}${git_branch}${venv_prompt}
╰─%B${return_code}${user_symbol}%b "

# RPROMPT messes up emacs term, so simply disable it
unset RPROMPT

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"

ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="› %{$reset_color%}"

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="%{$fg[green]%}‹"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="› %{$reset_color%}"
ZSH_THEME_VIRTUALENV_PREFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX
ZSH_THEME_VIRTUALENV_SUFFIX=$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX
