# Writable NixVim plugins

Home Manager keeps `init.lua` in the Nix store and links `~/.config/nvim/lua`
and `~/.config/nvim/plugin/local-plugins.lua` to the writable sources here. Edit
[`plugin/local-plugins.lua`](plugin/local-plugins.lua) to configure additional
plugins, then restart Neovim. These edits do not require another Nix rebuild.

Neovim automatically sources `plugin/*.lua` after `init.lua`. The configuration
uses NixVim's existing [lz.n](https://github.com/lumen-oss/lz.n#plugin-spec)
loader. Use command, key, or filetype triggers and put `require(...).setup(...)`
in an `after` hook to defer initialization. The older `lua/plugins` directory
belongs to the separate LazyVim configuration; NixVim does not import it.

Furball loads directly from `~/src/github.com/loganlinn/furball.nvim` when a
Furball command runs. Startup only registers command triggers: it does not load
Furball's modules, contact Kitty, clone repositories, or check for updates.
The entry is disabled on hosts without that checkout. Source edits take effect
in the next Neovim process. Run `:Furball` to open the tree and `:FurballPlan` to
preview edits; writing the tree applies them.

For another local checkout, add an lz.n spec with its own `load` function as in
the Furball entry. For plugins installed under
`~/.local/share/nvim/site/pack/local/opt/<name>`, omit `load`: lz.n defaults to
Neovim's `:packadd <name>`. Install or update those plugins explicitly outside
editor startup. Nix-managed plugins can continue using the NixVim modules.
