Never use absolute paths in shared (host/platform agnostic) config files, i.e. `/Users/logan/...` should be `~/...` or `$HOME/...`, depending on the context (tilde expansion is not supported everywhere and should be verified first.).

## Kitty

If I ask you about Kitty (terminal), always ground your knowledge of Kitty's capabilities and best practices using their documentation and source code (never rely on your knowledge alone). A clone of Kitty's source code (https://github.com/kovidgoyal/kitty) should exist at ~/src/github.com/kovidgoyal/kitty. If it does not exist, ask me to clone it first. 

