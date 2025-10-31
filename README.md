TMUX Sessionizer
================

Simple script for spinning up new tmux sessions or attaching to existing ones.

## Usage

Set `$PROJECT_ROOT` to the directory containing your projects. If not set, *sessionizer* falls back to `$HOME`.

## Next

- [ ] Exit 1 if no appropriate ENV is set.
- [ ] Set up unit tests.

After that, a tagged release is the goal.

## Installation

If you are using flakes to manage your NixOS installation, you can add the provided flake to your
inputs:

```nix
{
  description = "Your Configuration";

  inputs = {
    ...
    sessionizer = {
      url = "github:nomisreual/sessionizer";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ...
  };
  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: {
    # your configuration
  };
}
```

You can then add `sessionizer` to your packages (don't forget to add `inputs` to the respective module):

```nix
# configuration.nix
{
  environment.systemPackages = with pkgs; [
    ...

    inputs.sessionizer.packages."YOUR_ARCHITECTURE".default
    ...
  ];
}
# home.nix
{
  home.packages = with pkgs; [
    ...

    inputs.sessionizer.packages."YOUR_ARCHITECTURE".default
    ...
  ];
}
```

After rebuilding, you have *sessionizer* at your fingertips and it gets updated whenever you update your flake.

### Installation outside of Nix

You can also run it as a script (the actual bash script can be found in *src/*). Note: you probably want to add a shebang if used as a script directly.

Also make sure that all runtime dependencies are installed on your system. Currently these are:

- bash (the nix packaged version uses bash > 5.0.0, not tested on older versions):
- bat
- find (should probably be installed already)
- fd
- fzf
- tmux

