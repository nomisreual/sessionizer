{pkgs ? import <nixpkgs> {}}: let
  PROJECTS =
    if pkgs.stdenv.isLinux
    then "/home/simon/Projects"
    else "/Users/simon/Projects";
in
  pkgs.writeShellApplication {
    name = "sessionizer";
    runtimeInputs = with pkgs; [findutils fzf fd tmux];
    text = ''
      if [[ -v TMUX ]]; then
        selected=$(fd . -t d -d 1 ${PROJECTS} | fzf --tmux)
      else
        selected=$(fd . -t d -d 1 ${PROJECTS} | fzf --height 40% --layout reverse --border)
      fi

      # full paths
      clean_path=$(realpath "$selected")

      # select name for session
      selected_name=$(basename "$selected")

      # sanitize session name
      selected_name=''${selected_name//[^a-zA-Z0-9_.-]/_}

      if [[ -v TMUX ]]; then
        if tmux has-session -t="$selected_name" 2>/dev/null; then
          tmux switch-client -t "$selected_name"
          clear
        else
          tmux new-session -A -s "$selected_name" -c "$clean_path" -d
          tmux switch-client -t "$selected_name"
          clear
        fi
      else
        tmux new-session -A -s "$selected_name" -c "$clean_path"
        clear
      fi
    '';
  }
