function aoe {
  local profile=$1
  shift
  echo aws-okta exec "$profile" -- $*
}
alias prod='aws-okta exec main --'
alias danger-prod='aws-okta exec DANGER-main --'
alias danger-login='aws-okta login DANGER-main'
