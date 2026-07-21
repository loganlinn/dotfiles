#!/usr/bin/env bash

set -euo pipefail
[[ -z ${TRACE-} ]] || set -x

list_org_members_and_teams() {
  local slug=${1:-'{owner}/{repo}'}
  local owner=${slug%%/*}
  local repo=${slug#*/}
  gh api graphql -F owner="$owner" -F name="$repo" -f query='
    query($name: String!, $owner: String!) {
      repository(owner: $owner, name: $name) {
        owner {
          ... on Organization {
            login
            teams(first: 100) {
              nodes {
                slug
              }
            }
            membersWithRole(first: 100) {
              nodes {
                login
              }
            }
          }
        }
      }
    }
  ' | jq -r '
      ( .data.repository.owner // null )
      | .login // null as $org
      | (.teams.nodes // [] | map("@\($org)/\(.slug)")) as $teams
      | (.membersWithRole.nodes // [] | map(.login))    as $users
      | $teams + $users
      | sort_by(ascii_downcase)
      | .[]'
}

list_org_members_and_teams "$@"
