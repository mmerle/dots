function fish_right_prompt
  set -g __fish_git_prompt_showupstream verbose
  set -g __fish_git_prompt_char_upstream_ahead ' ↑'
  set -g __fish_git_prompt_char_upstream_behind ' ↓'
  set -g __fish_git_prompt_char_upstream_diverged ' ↕'
  set -g __fish_git_prompt_char_upstream_equal
  set -g __fish_git_prompt_char_upstream_prefix
  printf '%s %s' (set_color yellow; fish_git_prompt; set_color normal) (mode_indicator)
end

function mode_indicator
  switch $fish_bind_mode
    case default
      echo '[N]'
    case insert
      echo '[I]'
    case visual
      echo '[V]'
    case replace_one
      echo '[R]'
  end
  set_color normal
end

# disable default vi mode indicator
function fish_mode_prompt
end