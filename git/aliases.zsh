alias gl='git pull --prune'
alias glo='gl && git pull origin'
alias gfo='git fetch --all'
alias glr='git pull --rebase'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset %Cblue%an%Creset: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative -32"
alias gp='git push -u'
alias gpf='git force-push'
alias glrp='glr && gp'
# Remove `+` and `-` from start of diff lines; just rely upon color.
alias gd='git diff --color'
alias gdc='git diff --color --cached'
alias gc='git commit --verbose'
alias gcf='git commit --fixup --verbose'
alias gca='git commit --all --verbose'
alias gcaf='git commit --all --fixup --verbose'
alias gcb='git-copy-branch-name'
alias gcm='git commit --amend'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias grm="git status | grep deleted | awk '{\$1=\$2=\"\"; print \$0}' | \
           perl -pe 's/^[ \t]*//' | sed 's/ /\\\\ /g' | xargs git rm"
alias gw="git show"
alias gsu="git stash -u"
alias gsp="git stash pop"
alias gsw="git stash show -p"

gb() {
  local branches branch
  branches=$(git branch) &&
  branch=$(echo "$branches" | fzf-tmux -d 15 +m) &&
  git checkout $(echo "$branch" | sed "s/.* //")
}
