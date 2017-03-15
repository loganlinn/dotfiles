alias d='docker $*'
alias d-c='docker-compose $*'

function docker-prune() {
  docker ps -a -f status=exited -f status=created -q | xargs --no-run-if-empty docker em
  docker images -f dangling=true -q | xargs --no-run-if-empty docker rmi
}

function dockerenv () {
  local args=${@:-default}
  eval $(docker-machine env $args)
}

function docker-empty () {
  docker ps -aq | xargs --no-run-if-empty docker rm -f
}
