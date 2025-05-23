{colors, ...} @ colorScheme:
#
# https://github.com/chriskempson/base16/blob/main/styling.md
#
#     base00 - Default Background
#     base01 - Lighter Background (Used for status bars, line number and folding marks)
#     base02 - Selection Background
#     base03 - Comments, Invisibles, Line Highlighting
#     base04 - Dark Foreground (Used for status bars)
#     base05 - Default Foreground, Caret, Delimiters, Operators
#     base06 - Light Foreground (Not often used)
#     base07 - Light Background (Not often used)
#     base08 - Variables, XML Tags, Markup Link Text, Markup Lists, Diff Deleted
#     base09 - Integers, Boolean, Constants, XML Attributes, Markup Link Url
#     base0A - Classes, Markup Bold, Search Text Background
#     base0B - Strings, Inherited Class, Markup Code, Diff Inserted
#     base0C - Support, Regular Expressions, Escape Characters, Markup Quotes
#     base0D - Functions, Methods, Attribute IDs, Headings
#     base0E - Keywords, Storage, Selector, Markup Italic, Diff Changed
#     base0F - Deprecated, Opening/Closing Embedded Language Tags, e.g. <?php ?>
#
with colors; ''
  * {
    /* ${colorScheme.name or colorScheme.slug} */
    base00: #${base00};
    base01: #${base01};
    base02: #${base02};
    base03: #${base03};
    base04: #${base04};
    base05: #${base05};
    base06: #${base06};
    base07: #${base07};
    base08: #${base08};
    base09: #${base09};
    base0A: #${base0A};
    base0B: #${base0B};
    base0C: #${base0C};
    base0D: #${base0D};
    base0E: #${base0E};
    base0F: #${base0F};

    background:                  #${base00};
    alternate-background:        #${base01};
    border-color:                #${base01};
    selected-background:         #${base02};
    alternate-foreground:        #${base04};
    foreground:                  #${base05};
    light-foreground:            #${base06};
    light-background:            #${base07};
    red:                         #${base08};
    magenta:                     #${base09};
    blue:                        #${base0A};
    green:                       #${base0B};
    cyan:                        #${base0C};
    separatorcolor:              #${base04};
    selected-foreground:         #${base00};
    activebg:                    #${base03};
    activefg:                    #${base05};
    normal-foreground:           @foreground;
    normal-background:           @background;
    active-foreground:           @activefg;
    active-background:           @activebg;
    urgent-foreground:           @foreground;
    urgent-background:           @red;
    alternate-normal-foreground: @foreground;
    alternate-normal-background: @alternate-background;
    alternate-active-foreground: @activefg;
    alternate-active-background: @activebg;
    alternate-urgent-foreground: @background;
    alternate-urgent-background: @magenta;
    selected-normal-foreground:  @selected-foreground;
    selected-normal-background:  @selected-background;
    selected-active-foreground:  @selected-foreground;
    selected-active-background:  @selected-background;
    selected-urgent-foreground:  @background;
    selected-urgent-background:  @red;
  }
''
