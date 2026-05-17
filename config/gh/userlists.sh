#!/usr/bin/env bash
# gh-user-lists — work with a GitHub user's star lists via the GraphQL API.
# shellcheck disable=SC2016  # GraphQL variables ($user, $list, etc.) intentionally unexpanded
set -euo pipefail

readonly PROG=${0##*/}

usage() {
  cat <<EOF
Usage: $PROG <command> [args]

Commands:
  list [user]                     JSON array of user's lists ({id, name, slug})
  get  [<user>/]<slug>            JSON array of repos in the given list

If <user> is omitted, the authenticated user is used.

Options:
  -h, --help                      Show this help
EOF
}

usage_list() {
  cat <<EOF
Usage: $PROG list [user]

Output JSON array of the user's star lists.
Each element: { id, name, slug }.

If [user] is omitted, the authenticated user is used.
EOF
}

usage_get() {
  cat <<EOF
Usage: $PROG get [<user>/]<slug>

Output JSON array of repositories in the specified list.
Each element includes: nameWithOwner, url, description, stargazerCount,
isArchived, isFork, primaryLanguage.

If <user> is omitted, the authenticated user is used.
EOF
}

resolve_user() {
  local user=$1
  if [ -n "$user" ]; then
    printf '%s\n' "$user"
    return
  fi
  gh api graphql -f query='{ viewer { login } }' \
    | jq -r '.data.viewer.login'
}

cmd_list() {
  case "${1:-}" in
    -h|--help) usage_list; return 0 ;;
  esac

  local user
  user=$(resolve_user "${1:-}")

  gh api graphql \
    -f user="$user" \
    -f query='
      query($user: String!) {
        user(login: $user) {
          lists(first: 100) {
            nodes {
              id
              slug
              name
              description
              items { totalCount }
              isPrivate
              createdAt
              updatedAt
              lastAddedAt
            }
          }
        }
      }' \
    | jq '.data.user.lists.nodes'
}

cmd_get() {
  case "${1:-}" in
    -h|--help) usage_get; return 0 ;;
  esac

  local spec=${1:-}
  if [ -z "$spec" ]; then
    echo >&2 "$PROG get: [<user>/]<slug> required (try --help)"
    return 2
  fi

  local user slug
  case "$spec" in
    */*) user=${spec%%/*}; slug=${spec#*/} ;;
    *)   user=""; slug=$spec ;;
  esac

  if [ -z "$slug" ]; then
    echo >&2 "$PROG get: missing slug in '$spec'"
    return 2
  fi

  user=$(resolve_user "$user")

  local list_id
  list_id=$(gh api graphql \
    -f user="$user" \
    -f query='
      query($user: String!) {
        user(login: $user) {
          lists(first: 100) {
            nodes { id slug }
          }
        }
      }' \
    | jq -r --arg slug "$slug" \
        '.data.user.lists.nodes[] | select(.slug == $slug) | .id' \
    | head -n1)

  if [ -z "$list_id" ]; then
    echo >&2 "$PROG get: no list with slug '$slug' for user '$user'"
    return 1
  fi

  gh api graphql --paginate \
    -f id="$list_id" \
    -f query='
      query($id: ID!, $endCursor: String) {
        node(id: $id) {
          ... on UserList {
            items(first: 100, after: $endCursor) {
              pageInfo { hasNextPage endCursor }
              nodes {
                ... on Repository {
                  nameWithOwner
                  url
                  homepageUrl
                  description
                  stargazerCount
                  isArchived
                  isFork
                  pushedAt
                  latestRelease { name url tagName publishedAt }
                }
              }
            }
          }
        }
      }' \
    | jq -s '[.[].data.node.items.nodes[]]'
}

main() {
  local cmd=${1:-}
  case "$cmd" in
    -h|--help|"") usage ;;
    list) shift; cmd_list "$@" ;;
    get)  shift; cmd_get  "$@" ;;
    *)
      echo >&2 "$PROG: unknown command '$cmd' (try --help)"
      return 2
      ;;
  esac
}

main "$@"
