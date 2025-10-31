{pkgs ? import <nixpkgs> {}}:
pkgs.writeShellApplication {
  name = "sessionizer";
  runtimeInputs = with pkgs; [findutils fzf fd bat tmux];
  text = builtins.readFile ./src/sessionizer.sh;
}
