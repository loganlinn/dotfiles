{ nix-colors
, config
, pkgs
, lib
, ...
}:

{
  imports = [ ../astronvim.nix ];

  programs.neovim = {
    enable = true;

    defaultEditor = !config.services.emacs.defaultEditor;
    withNodeJs = true;
    withPython3 = true;
    vimAlias = true;
    viAlias = true;

    plugins = with pkgs.vimPlugins; [
      (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: with p; [
        # ada
        # agda
        # arduino
        # astro
        awk
        bash
        # bass
        # beancount
        # bibtex
        # bicep
        # blueprint
        c
        # c_sharp
        # cairo
        # capnp
        # chatito
        clojure
        # cmake
        # comment
        # commonlisp
        # cooklang
        # corn
        # cpon
        cpp
        css
        # cuda
        cue
        # d
        # dart
        # devicetree
        # dhall
        diff
        dockerfile
        # dot
        # ebnf
        # eex
        # elixir
        # elm
        # elsa
        # elvish
        embedded_template
        # erlang
        fennel
        # firrtl
        fish
        # foam
        # fortran
        # fsh
        # func
        # fusion
        # gdscript
        git_config
        git_rebase
        gitattributes
        gitcommit
        gitignore
        # gleam
        # glimmer
        # glsl
        go
        # godot_resource
        gomod
        gosum
        # gowork
        graphql
        # groovy
        # hack
        # hare
        # haskell
        # haskell_persistent
        hcl
        # heex
        # hjson
        # hlsl
        # hocon
        # hoon
        html
        htmldjango
        http
        # hurl
        ini
        # ispc
        janet_simple
        java
        javascript
        jq
        jsdoc
        json
        # json5
        # jsonc
        # jsonnet
        # julia
        # kdl
        # kotlin
        # lalrpop
        latex
        # ledger
        # llvm
        lua
        luadoc
        # luap
        # luau
        # m68k
        make
        markdown
        markdown_inline
        # matlab
        mermaid
        # meson
        # mlir
        # nickel
        # ninja
        nix
        # norg
        # objc
        # ocaml
        # ocaml_interface
        # ocamllex
        # odin
        org
        # pascal
        passwd
        pem
        perl
        # php
        # phpdoc
        # pioasm
        # po
        # poe_filter
        # pony
        # prisma
        # promql
        proto
        # prql
        # pug
        # puppet
        python
        # ql
        # qmldir
        # qmljs
        # query
        # r
        # racket
        rasi
        regex
        # rego
        # rnoweb
        # robot
        # ron
        # rst
        ruby
        rust
        # scala
        # scheme
        scss
        # slint
        # smali
        # smithy
        # solidity
        # sparql
        sql
        # squirrel
        starlark
        # supercollider
        # surface
        # svelte
        # swift
        sxhkdrc
        # systemtap
        # t32
        # tablegen
        # teal
        terraform
        # thrift
        # tiger
        # tlaplus
        # todotxt
        toml
        # tsx
        # turtle
        # twig
        typescript
        # ungrammar
        # usd
        # uxntal
        # v
        # vala
        # verilog
        # vhs
        vim
        # vimdoc
        # vue
        # wgsl
        # wgsl_bevy
        # wing
        yaml
        # yang
        yuck
        zig
      ]))
    ];

    extraPackages = with pkgs; [ gcc zig ];

    extraPython3Packages = ps: with ps; [ pynvim ];
  };

  my.astronvim.enable = true;

  # LSP servers
  home.packages = with pkgs; [
    deadnix
    gopls
    godef
    luarocks-nix
    nodePackages.bash-language-server
    lua-language-server
    rnix-lsp
    statix
  ];

  xdg.dataFile."nvim/runtime/colors/nix-colors.vim".source =
    let
      nixColorsLib = nix-colors.lib.contrib { inherit pkgs; };
      vimTheme = nixColorsLib.vimThemeFromScheme { scheme = config.colorScheme; };
    in
    vimTheme.outPath;
}
