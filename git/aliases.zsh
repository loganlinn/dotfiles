# Use `hub` as our git wrapper:
#   http://defunkt.github.com/hub/
hub_path=$(which hub 2>/dev/null)
if [[ -f $hub_path ]]
then
  alias git=$hub_path
fi

# The rest of my fun git aliases
alias gl='git pull --prune'
alias glo='gl && git pull origin'
alias glr='git pull --rebase'
alias glg="git log --graph --pretty=format:'%Cred%h%Creset %Cblue%an%Creset: %s - %Creset %C(yellow)%d%Creset %Cgreen(%cr)%Creset' --abbrev-commit --date=relative"
alias gp='git push -u origin HEAD'
alias glrp='glr && gp'
alias gph='git push heroku HEAD'
alias gd='git diff'
alias gdc='git diff --cached'
alias gc='git commit --verbose'
alias gca='git commit --all --verbose'
alias gcm='git commit --amend'
alias gco='git checkout'
alias gb='git branch'
alias gs='git status -sb' # upgrade your git if -sb breaks for you. it's fun.
alias grm="git status | grep deleted | awk '{\$1=\$2=\"\"; print \$0}' | \
           perl -pe 's/^[ \t]*//' | sed 's/ /\\\\ /g' | xargs git rm"
alias gdt='git dt'
alias gstash='git stash -u'
alias gw="git show"
alias gss="git stash"
alias gsp="git stash pop"
