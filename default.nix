{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "sessionizer";
  runtimeInputs = with pkgs; [findutils fzf fd tmux];
  text = builtins.readFile ./src/sessionizer.sh;
}
