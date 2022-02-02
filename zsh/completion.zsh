zmodload -i zsh/complist

WORDCHARS=''

unsetopt menu_complete   # do not autoselect the first completion entry
unsetopt flowcontrol     # disable output flow control via start/stop characters (i.e. ^S, ^Q)
setopt auto_menu         # show completion menu on successive tab press
setopt complete_in_word  # do not move cursor to end of word if completion is started
setopt always_to_end     # always move cursor to end of word when completion is inserted
setopt extendedglob
setopt local_options
setopt completealiases

# case insensitive (all), partial-word and substring completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|=*' 'l:|=* r:|=*'

# Complete . and .. special directories
zstyle ':completion:*' special-dirs true

zstyle ':completion:*' list-colors ''
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

if [[ "$OSTYPE" = solaris* ]]; then
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm"
else
  zstyle ':completion:*:*:*:*:processes' command "ps -u $USERNAME -o pid,user,comm -w -w"
fi

# disable named-directories autocompletion
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories

# Use caching so that commands like apt and dpkg complete are useable
zstyle ':completion:*' use-cache yes
zstyle ':completion:*' cache-path $ZSH_CACHE_DIR

# Don't complete uninteresting users
zstyle ':completion:*:*:*:users' ignored-patterns \
        adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
        clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
        gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
        ldap lp mail mailman mailnull man messagebus  mldonkey mysql nagios \
        named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
        operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
        rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
        usbmux uucp vcsa wwwrun xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# automatically load bash completion functions
autoload -U +X bashcompinit && bashcompinit

################################################################################

autoload -Uz compinit

# use a separate file to determine when to regenerate, as compinit doesn't always need to modify the compdump
local zcompf="${ZDOTDIR:-$HOME}/.zcompdump"
local zcompf_a="${zcompf}.augur"
if [[ -e "$zcompf_a" && -f "$zcompf_a"(#qN.md-1) ]]; then
    compinit -C -d "$zcompf"
else
    compinit -d "$zcompf"
    touch "$zcompf_a"
fi

# if zcompdump exists (and is non-zero), and is older than the .zwc file, then regenerate
if [[ -s "$zcompf" && (! -s "${zcompf}.zwc" || "$zcompf" -nt "${zcompf}.zwc") ]]; then
    # since file is mapped, it might be mapped right now (current shells), so rename it then make a new one
    [[ -e "$zcompf.zwc" ]] && mv -f "$zcompf.zwc" "$zcompf.zwc.old"
    # compile it mapped, so multiple shells can share it (total mem reduction)
    # run in background
    { zcompile -M "$zcompf" && command rm -f "$zcompf.zwc.old" }&!
fi 

################################################################################

# kitty hyperlinked grep [[https://sw.kovidgoyal.net/kitty/kittens/hyperlinked_grep]]
compdef _rg hg

# babashka tasks [[https://book.babashka.org/#_zsh]]
_bb_tasks() {
    local matches=(`bb tasks |tail -n +3 |cut -f1 -d ' '`)
    compadd -a matches
    # _files # autocomplete filenames as well
}

compdef _bb_tasks bb
