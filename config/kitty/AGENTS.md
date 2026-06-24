This directory has files that are symlinked from `${KITTY_CONFIG_DIRECTORY:-${XDG_CONFIG_HOME:-$HOME/.config}/kitty}`.
These symlinks are formalized in kitty home-manager config.
When creating new files here that should be exposed in kitty config dir:

1. update the appropriate nix configuration so that symlink is created on activation.
2. if the new file is part of changes that affect files that are already symlinked,
   manually create the symlink so the user does not need to apply nix for the changes to work as intended.
