#!/usr/bin/env bash
# gh-user-lists — work with a GitHub user's star lists via the GraphQL API.
# shellcheck disable=SC2016  # GraphQL variables ($user, $list, etc.) intentionally unexpanded
set -euo pipefail

readonly PROG=${0##*/}

usage() {
  cat <<EOF
Work with a GitHub user's star lists via the GraphQL API.

Usage: $PROG <command> [<args>]

Commands:
  list    [<user>]                                              List a user's star lists
  get     [<user>/]<slug>                                       List repositories in a star list
  create  [--private] [-d <desc>] <name>                        Create a new star list
  edit    <slug> [-d <desc>] [--private | --no-private] <name>  Update a star list
  delete  [-y] <slug>                                           Delete a star list
  add     <owner>/<name> <slug> [<slug>...]                     Add a repository to star lists

If <user> is omitted, the authenticated user is used.
Run \`$PROG <command> --help\` for command-specific options.

Options:
  -h, --help                                                    Show this help
EOF
}

usage_list() {
  cat <<EOF
List a user's star lists.

Usage: $PROG list [<user>]

If <user> is omitted, the authenticated user is used.

Options:
  -h, --help             Show this help
EOF
}

usage_get() {
  cat <<EOF
List repositories in a star list.

Usage: $PROG get [<user>/]<slug>

If <user> is omitted, the authenticated user is used.

Options:
  -h, --help             Show this help
EOF
}

usage_create() {
  cat <<EOF
Create a new star list.

Usage: $PROG create [--private] [-d <desc>] <name>

Options:
  -d, --desc <desc>      Description of the list
      --private          Make the list private
  -h, --help             Show this help
EOF
}

usage_edit() {
  cat <<EOF
Update a star list's name, description, or visibility.

Usage: $PROG edit <slug> [-d <desc>] [--private | --no-private] <name>

Options:
  -d, --desc <desc>      New description
      --private          Make the list private
      --no-private       Make the list public
  -h, --help             Show this help
EOF
}

usage_delete() {
  cat <<EOF
Delete a star list. Prompts for confirmation unless -y is given;
-y is required in non-interactive contexts.

Usage: $PROG delete [-y] <slug>

Options:
  -y, --yes              Skip confirmation prompt
  -h, --help             Show this help
EOF
}

usage_add() {
  cat <<EOF
Add a repository to one or more star lists.

Usage: $PROG add <owner>/<name> <slug> [<slug>...]

GitHub's API replaces a repository's full list membership on each mutation,
so existing memberships are scanned and unioned with the requested slugs.
Lists with more than 100 items are not fully scanned; in that case a
warning is printed and memberships in those lists may be lost.

Options:
  -h, --help             Show this help
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

# resolve_list_id <user> <slug> → list node id (empty if not found)
resolve_list_id() {
  local user=$1 slug=$2
  gh api graphql \
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
    | head -n1
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
  list_id=$(resolve_list_id "$user" "$slug")
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

cmd_create() {
  local is_private=false
  local desc="" desc_set=false
  local name=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help) usage_create; return 0 ;;
      --private) is_private=true; shift ;;
      -d|--desc) desc=${2:-}; desc_set=true; shift 2 ;;
      --desc=*) desc=${1#--desc=}; desc_set=true; shift ;;
      --) shift; break ;;
      -*) echo >&2 "$PROG create: unknown option '$1'"; return 2 ;;
      *)
        if [ -z "$name" ]; then
          name=$1
        else
          echo >&2 "$PROG create: unexpected arg '$1'"
          return 2
        fi
        shift
        ;;
    esac
  done

  if [ -z "$name" ]; then
    echo >&2 "$PROG create: NAME required (try --help)"
    return 2
  fi

  local args=(-f name="$name" -F isPrivate="$is_private")
  if $desc_set; then
    args+=(-f description="$desc")
  fi

  gh api graphql "${args[@]}" \
    -f query='
      mutation($name: String!, $description: String, $isPrivate: Boolean) {
        createUserList(input: { name: $name, description: $description, isPrivate: $isPrivate }) {
          list { id slug name description isPrivate }
        }
      }' \
    | jq '.data.createUserList.list'
}

cmd_edit() {
  local desc="" desc_set=false
  local is_private="" priv_set=false
  local positional=()

  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help) usage_edit; return 0 ;;
      --private) is_private=true; priv_set=true; shift ;;
      --no-private) is_private=false; priv_set=true; shift ;;
      -d|--desc) desc=${2:-}; desc_set=true; shift 2 ;;
      --desc=*) desc=${1#--desc=}; desc_set=true; shift ;;
      --) shift; while [ $# -gt 0 ]; do positional+=("$1"); shift; done ;;
      -*) echo >&2 "$PROG edit: unknown option '$1'"; return 2 ;;
      *) positional+=("$1"); shift ;;
    esac
  done

  if [ ${#positional[@]} -ne 2 ]; then
    echo >&2 "$PROG edit: SLUG and NAME required (try --help)"
    return 2
  fi
  local slug=${positional[0]}
  local name=${positional[1]}

  local user list_id
  user=$(resolve_user "")
  list_id=$(resolve_list_id "$user" "$slug")
  if [ -z "$list_id" ]; then
    echo >&2 "$PROG edit: no list with slug '$slug' for user '$user'"
    return 1
  fi

  local args=(-f listId="$list_id" -f name="$name")
  if $desc_set; then args+=(-f description="$desc"); fi
  if $priv_set; then args+=(-F isPrivate="$is_private"); fi

  gh api graphql "${args[@]}" \
    -f query='
      mutation($listId: ID!, $name: String, $description: String, $isPrivate: Boolean) {
        updateUserList(input: { listId: $listId, name: $name, description: $description, isPrivate: $isPrivate }) {
          list { id slug name description isPrivate }
        }
      }' \
    | jq '.data.updateUserList.list'
}

cmd_delete() {
  local assume_yes=false
  local slug=""

  while [ $# -gt 0 ]; do
    case "$1" in
      -h|--help) usage_delete; return 0 ;;
      -y|--yes) assume_yes=true; shift ;;
      --) shift; break ;;
      -*) echo >&2 "$PROG delete: unknown option '$1'"; return 2 ;;
      *)
        if [ -z "$slug" ]; then
          slug=$1
        else
          echo >&2 "$PROG delete: unexpected arg '$1'"
          return 2
        fi
        shift
        ;;
    esac
  done

  if [ -z "$slug" ]; then
    echo >&2 "$PROG delete: SLUG required (try --help)"
    return 2
  fi

  local user list_id
  user=$(resolve_user "")
  list_id=$(resolve_list_id "$user" "$slug")
  if [ -z "$list_id" ]; then
    echo >&2 "$PROG delete: no list with slug '$slug' for user '$user'"
    return 1
  fi

  if ! $assume_yes; then
    if [ ! -t 0 ] || [ ! -t 2 ]; then
      echo >&2 "$PROG delete: refusing to delete in non-interactive mode without -y/--yes"
      return 2
    fi
    local ans=""
    read -r -p "Delete list '$slug' ($list_id)? [y/N] " ans
    case "$ans" in
      [yY]|[yY][eE][sS]) ;;
      *) echo >&2 "Aborted."; return 1 ;;
    esac
  fi

  gh api graphql \
    -f listId="$list_id" \
    -f query='
      mutation($listId: ID!) {
        deleteUserList(input: { listId: $listId }) {
          user { login }
        }
      }' >/dev/null

  echo >&2 "$PROG: deleted list '$slug'"
}

cmd_add() {
  case "${1:-}" in
    -h|--help) usage_add; return 0 ;;
  esac

  local repo=${1:-}
  if [ -z "$repo" ]; then
    echo >&2 "$PROG add: OWNER/NAME required (try --help)"
    return 2
  fi
  shift

  if [ $# -eq 0 ]; then
    echo >&2 "$PROG add: at least one SLUG required (try --help)"
    return 2
  fi

  local owner name
  case "$repo" in
    */*) owner=${repo%%/*}; name=${repo#*/} ;;
    *)
      echo >&2 "$PROG add: expected OWNER/NAME, got '$repo'"
      return 2
      ;;
  esac

  local slugs_json
  slugs_json=$(printf '%s\n' "$@" | jq -R . | jq -s .)

  local repo_id
  repo_id=$(gh api graphql \
    -f owner="$owner" -f name="$name" \
    -f query='
      query($owner: String!, $name: String!) {
        repository(owner: $owner, name: $name) { id }
      }' \
    | jq -r '.data.repository.id // ""')
  if [ -z "$repo_id" ]; then
    echo >&2 "$PROG add: repository $owner/$name not found"
    return 1
  fi

  local user
  user=$(resolve_user "")

  local lists_json
  lists_json=$(gh api graphql --paginate \
    -f user="$user" \
    -f query='
      query($user: String!, $endCursor: String) {
        user(login: $user) {
          lists(first: 100, after: $endCursor) {
            pageInfo { hasNextPage endCursor }
            nodes {
              id
              slug
              items(first: 100) {
                pageInfo { hasNextPage }
                nodes { ... on Repository { id } }
              }
            }
          }
        }
      }' \
    | jq -s '[.[].data.user.lists.nodes[]]')

  local missing
  missing=$(jq -n --argjson lists "$lists_json" --argjson slugs "$slugs_json" \
    '($lists | map(.slug)) as $known | [$slugs[] | select(IN($known[]) | not)]')
  if [ "$(jq 'length' <<<"$missing")" -gt 0 ]; then
    echo >&2 "$PROG add: unknown slugs: $(jq -r 'join(", ")' <<<"$missing")"
    return 1
  fi

  local truncated
  truncated=$(jq '[.[] | select(.items.pageInfo.hasNextPage) | .slug]' <<<"$lists_json")
  if [ "$(jq 'length' <<<"$truncated")" -gt 0 ]; then
    echo >&2 "$PROG add: warning: lists with >100 items not fully scanned; existing memberships in these may be lost: $(jq -r 'join(", ")' <<<"$truncated")"
  fi

  local body
  body=$(jq -n \
    --arg itemId "$repo_id" \
    --argjson lists "$lists_json" \
    --argjson slugs "$slugs_json" '
      ($lists | map(select(.slug as $s | $slugs | index($s))) | map(.id)) as $requested
      | ($lists | map(select(.items.nodes | map(.id) | index($itemId))) | map(.id)) as $current
      | ($requested + $current | unique) as $listIds
      | {
          query: "mutation($itemId: ID!, $listIds: [ID!]!) { updateUserListsForItem(input: { itemId: $itemId, listIds: $listIds }) { lists { id slug name } } }",
          variables: { itemId: $itemId, listIds: $listIds }
        }
    ')

  gh api graphql --input - <<<"$body" \
    | jq '.data.updateUserListsForItem.lists'
}

main() {
  local cmd=${1:-}
  case "$cmd" in
    -h|--help|"") usage ;;
    list)   shift; cmd_list   "$@" ;;
    get)    shift; cmd_get    "$@" ;;
    create) shift; cmd_create "$@" ;;
    edit)   shift; cmd_edit   "$@" ;;
    delete) shift; cmd_delete "$@" ;;
    add)    shift; cmd_add    "$@" ;;
    *)
      echo >&2 "$PROG: unknown command '$cmd' (try --help)"
      return 2
      ;;
  esac
}

main "$@"
