alias docker-prune='docker rm $(docker ps -a -f status=exited -f status=created -q) && docker rmi $(docker images -f dangling=true -q)'

function dockerenv () {
  local args=${@:-default}
  eval $(docker-machine env $args)
}

function docker-empty () {
  docker ps -aq | xargs --no-run-if-empty docker rm -f
}
