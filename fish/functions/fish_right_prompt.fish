function fish_right_prompt
  set -g __fish_git_prompt_color $subtle
	echo (fish_git_prompt)
  switch $fish_bind_mode
    case default
      set_color $subtle
      echo -n ' [N]'
    case insert
      set_color $subtle
      echo -n ' [I]'
    case replace_one
      set_color $subtle
      echo -n ' [R]'
    case visual
      set_color $subtle
      echo -n ' [V]'
  end
end

function fish_mode_prompt
end