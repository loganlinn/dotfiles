alias gl='git pull --prune'
alias glo='gl && git pull origin'
alias gfo='git fetch origin'
alias glr='git pull --rebase'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset %Cblue%an%Creset: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push -u origin HEAD'
alias gpf='git force-push'
alias glrp='glr && gp'
# Remove `+` and `-` from start of diff lines; just rely upon color.
alias gd='git diff --quiet || git diff --color | sed -E "s/^([^-+ ]*)[-+ ]/\\1/" | less -r'
alias gdc='git diff --color --cached | sed -E "s/^([^-+ ]*)[-+ ]/\\1/" | less -r'
alias gc='git commit --verbose --no-verify'
alias gcf='git commit --fixup --verbose --no-verify'
alias gca='git commit --all --verbose --no-verify'
alias gcaf='git commit --all --fixup --verbose --no-verify'
alias gcb='git-copy-branch-name'
alias gcm='git commit --amend --no-verify'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gb='git switch'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias grm="git status | grep deleted | awk '{\$1=\$2=\"\"; print \$0}' | \
           perl -pe 's/^[ \t]*//' | sed 's/ /\\\\ /g' | xargs git rm"
alias gw="git show"
alias gss="git stash -u"
alias gsp="git stash pop"
alias gsw="git stash show -p"
