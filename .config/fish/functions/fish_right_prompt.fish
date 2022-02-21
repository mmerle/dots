function fish_right_prompt
    set -g __fish_git_prompt_showupstream verbose
    set -g __fish_git_prompt_char_upstream_ahead ' ↑'
    set -g __fish_git_prompt_char_upstream_behind ' ↓'
    set -g __fish_git_prompt_char_upstream_diverged ' ↕'
    set -g __fish_git_prompt_char_upstream_equal
    set -g __fish_git_prompt_char_upstream_prefix
    printf '%s %s' (set_color yellow; fish_git_prompt;)
end

# disable default vi mode indicator
function fish_mode_prompt
end
