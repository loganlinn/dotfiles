# A color scheme based on [doom-one-theme.el][],
# an emacs theme based on [Atom One Dark][] (ported by @hlissner),
# that has been memetically ported to nix-land by @loganlinn.
#
# This nix configuration is to be used with the [nix-colors flake](https://github.com/Misterio77/nix-colors).
#
# [doom-one-theme.el](https://github.com/doomemacs/themes/blob/e4f0b006a516a35f53df2dce2ec116876c5cd7f9/themes/doom-one-theme.el)
# [Atom One Dark](https://github.com/atom/one-dark-ui)
{
  name = "doom-one";
  slug = "doom-one";
  palette = rec {
    # https://github.com/chriskempson/base16/blob/main/styling.md
    base00 = bg-alt; # Default background
    base01 = bg; # Lighter Background (Used for status bars, line number and folding marks)
    base02 = muted-blue; # Selection Background
    base03 = comments; # Comments, Invisibles, Line Highlighting
    base04 = base6; # Dark foreground (used for status bars)
    base05 = fg; # Default foregrund, caret, delimiters, operators
    base06 = base7; # Light foreground
    base07 = base8; # Light background
    base08 = red; # Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
    base09 = violet; # Integers, Boolean, Constants, XML Attributes, Markup Link Url
    base0A = blue; # Classes, Markup Bold, Search Text Background
    base0B = green; # Strings, Inherited Class, Markup Code, Diff Inserted
    base0C = dark-cyan; # Support, Regular Expressions, Escape Characters, Markup Quotes
    base0D = teal; # Functions, Methods, Attribute IDs, Headings
    base0E = orange; # Keywords, Storage, Selector, Markup Italic, Diff Changed
    base0F = yellow; # Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>

    # named colors
    bg = "282c34";
    fg = "bbc2cf";
    bg-alt = "21242b";
    fg-alt = "5b6268";
    base0 = "1b2229";
    base1 = "1c1f24";
    base2 = "202328";
    base3 = "23272e";
    base4 = "3f444a";
    base5 = "5b6268";
    base6 = "73797e";
    base7 = "9ca0a4";
    base8 = "dfdfdf";
    grey = "3f444a";
    red = "ff6c6b";
    orange = "da8548";
    green = "98be65";
    teal = "4db5bd";
    yellow = "ecbe7b";
    blue = "51afef";
    dark-blue = "2257a0";
    magenta = "c678dd";
    violet = "a9a1e1";
    cyan = "46d9ff";
    dark-cyan = "5699af";
    muted-blue = "387aa7";
    highlight = blue;
    vertical-bar = base1;
    builtin = magenta;
    comments = base5;
    doc-comments = base5;
    constants = violet;
    functions = magenta;
    keywords = blue;
    methods = cyan;
    operators = blue;
    type = yellow;
    strings = green;
    variables = magenta;
    numbers = orange;
    region = bg-alt;
    error = red;
    warning = yellow;
    success = green;
    vc-modified = orange;
    vc-added = green;
    vc-deleted = red;
  };
}
