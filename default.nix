{pkgs ? import <nixpkgs> {}}: let
  PROJECTS = "/home/simon/Projects";
in
  pkgs.writeShellApplication {
    name = "sessionizer";
    runtimeInputs = with pkgs; [findutils fzf fd tmux];
    text = ''
      selected=$(fd . -t d -d 1 ${PROJECTS} | fzf)
      exists=$(tmux list-sessions | grep -c "$selected")

      if [[ -v TMUX ]]; then
        if [ "$exists" -eq 1 ]; then
          echo "Switching to existing session."
          tmux switch-client -t "$selected"
        else
          echo "Creating new session and switching to it."
          tmux new-session -A -s "$selected" -c "$selected" -d
          tmux switch-client -t "$selected"
        fi
      else
        echo "Create and attach to new session."
        tmux new-session -A -s "$selected" -c "$selected"
      fi
    '';
  }
