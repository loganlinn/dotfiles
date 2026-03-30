#!/usr/bin/env bash

# kagi-summarize.bash - Bash library for the Kagi Universal Summarizer API
# Source this file; do not execute directly.
#
# Requirements: curl, jq, trurl
# Optional: gum (rich logging/formatting; falls back to plain stderr)
#
# Auth: KAGI_API_TOKEN env var or --api-token flag
#
# Env vars: KAGI_API_TOKEN, KAGI_SUMMARIZE_ENGINE, KAGI_SUMMARIZE_TYPE,
#           KAGI_SUMMARIZE_LANG, KAGI_SUMMARIZE_CACHE, KAGI_SUMMARIZE_RAW,
#           KAGI_SUMMARIZE_QUIET
#
# Usage:
#   source kagi-summarize.bash
#
#   # Summarize a URL
#   kagi_summarize --url "https://example.com/article"
#
#   # Summarize text from a file (or - for stdin)
#   kagi_summarize --file paper.pdf
#   curl -s https://example.com | kagi_summarize --file -
#
#   # Options
#   kagi_summarize --url "..." --engine muriel --type takeaway --lang DE
#   kagi_summarize --url "..." --no-cache --raw
#   kagi_summarize --api-token "tok_xxx" --url "..."

[[ "${BASH_SOURCE[0]}" == "$0" ]] && {
  echo >&2 "This is a library. Source it: source ${BASH_SOURCE[0]}"
  exit 1
}

# ---------------------------------------------------------------------------
# logging (graceful degradation without gum)
# ---------------------------------------------------------------------------

if hash gum &>/dev/null; then
  _kagi_log() { gum log "$@"; }
  _kagi_fmt() { gum format "$@"; }
else
  _kagi_log() {
    local level=""
    while [[ $# -gt 0 ]]; do
      case "$1" in
      --level)
        level="$2"
        shift 2
        ;;
      *) break ;;
      esac
    done
    [[ -n "$level" ]] && level="${level^^}: "
    echo >&2 "${level}$*"
  }
  _kagi_fmt() { cat; }
fi

# ---------------------------------------------------------------------------
# dependencies
# ---------------------------------------------------------------------------

_kagi_require() {
  local missing=()
  for cmd in curl jq trurl; do
    hash "$cmd" &>/dev/null || missing+=("$cmd")
  done
  if ((${#missing[@]})); then
    _kagi_log --level error "missing dependencies: ${missing[*]}"
    return 1
  fi
}
_kagi_require || return 1

# ---------------------------------------------------------------------------
# constants
# ---------------------------------------------------------------------------

readonly KAGI_API_BASE="https://kagi.com/api/v0"
readonly _KAGI_ENGINES="cecil agnes daphne muriel"
readonly _KAGI_SUMMARY_TYPES="summary takeaway"
readonly _KAGI_LANGUAGES="BG CS DA DE EL EN ES ET FI FR HU ID IT JA KO LT LV NB NL PL PT RO RU SK SL SV TR UK ZH ZH-HANT"

# ---------------------------------------------------------------------------
# internal helpers
# ---------------------------------------------------------------------------

_kagi_token() {
  if [[ -z "${KAGI_API_TOKEN:-}" ]]; then
    _kagi_log --level error "KAGI_API_TOKEN is not set"
    _kagi_log --level info "set KAGI_API_TOKEN or use --api-token <token>"
    _kagi_log --level info "get a token at https://kagi.com/settings?p=api"
    return 1
  fi
  printf '%s' "$KAGI_API_TOKEN"
}

_kagi_in_list() {
  local needle="$1" haystack="$2"
  [[ " $haystack " == *" $needle "* ]]
}

# POST JSON to the API, return raw response body.
# Args: $1=json_body
_kagi_post() {
  local body="$1" token
  token=$(_kagi_token) || return 1

  curl -sfS \
    --max-time 120 \
    -H "Authorization: Bot $token" \
    -H "Content-Type: application/json" \
    -d "$body" \
    "$KAGI_API_BASE/summarize" 2>&1
}

# GET with query params.
# Args: url (already built with trurl)
_kagi_get() {
  local url="$1" token
  token=$(_kagi_token) || return 1

  curl -sfS \
    --max-time 120 \
    -H "Authorization: Bot $token" \
    "$url" 2>&1
}

# Extract and display errors from API response JSON.
# Returns 0 if response is OK, 1 if error.
_kagi_check_response() {
  local resp="$1"

  local errors
  # Single jq pass: validate JSON and extract errors
  errors=$(jq -r '
		if .error then [.error] | flatten | .[] | objects | .msg // .
		elif .errors then [.errors] | flatten | .[].msg // empty
		else empty end
	' <<<"$resp" 2>/dev/null) || {
    _kagi_log --level error "request failed: $resp"
    return 1
  }

  if [[ -n "$errors" ]]; then
    while IFS= read -r line; do
      _kagi_log --level error "$line"
    done <<<"$errors"
    return 1
  fi
}

# ---------------------------------------------------------------------------
# public API
# ---------------------------------------------------------------------------

# kagi_summarize - Summarize a URL or text via the Kagi Summarizer API
#
# Options:
#   --api-token <token>  API token (overrides $KAGI_API_TOKEN)
#   --url <url>          URL to summarize
#   --file <path|->      File to summarize (- for stdin)
#   --text <string>      Inline text to summarize
#   --engine <engine>    cecil (default), agnes, daphne, muriel
#   --type <type>        summary (default) or takeaway
#   --lang <code>        Target language (e.g. EN, DE, JA)
#   --no-cache           Disable caching (for sensitive content)
#   --raw                Output raw JSON instead of formatted text
#   --quiet              Suppress progress output
kagi_summarize() {
  local api_token="" url="" text="" file=""
  local engine="" summary_type="" lang="" cache="" raw=false quiet=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
    --api-token)
      [[ $# -lt 2 ]] && {
        _kagi_log --level error "--api-token requires a value"
        return 1
      }
      api_token="$2"
      shift 2
      ;;
    --url)
      [[ $# -lt 2 ]] && {
        _kagi_log --level error "--url requires a value"
        return 1
      }
      url="$2"
      shift 2
      ;;
    --file)
      [[ $# -lt 2 ]] && {
        _kagi_log --level error "--file requires a value"
        return 1
      }
      file="$2"
      shift 2
      ;;
    --text)
      [[ $# -lt 2 ]] && {
        _kagi_log --level error "--text requires a value"
        return 1
      }
      text="$2"
      shift 2
      ;;
    --engine)
      [[ $# -lt 2 ]] && {
        _kagi_log --level error "--engine requires a value"
        return 1
      }
      engine="$2"
      shift 2
      ;;
    --type)
      [[ $# -lt 2 ]] && {
        _kagi_log --level error "--type requires a value"
        return 1
      }
      summary_type="$2"
      shift 2
      ;;
    --lang)
      [[ $# -lt 2 ]] && {
        _kagi_log --level error "--lang requires a value"
        return 1
      }
      lang="$2"
      shift 2
      ;;
    --no-cache)
      cache="false"
      shift
      ;;
    --raw)
      raw=true
      shift
      ;;
    --quiet)
      quiet=true
      shift
      ;;
    *)
      _kagi_log --level error "unknown option: $1"
      return 1
      ;;
    esac
  done

  # --- resolve defaults: env → flags (flag wins) ---

  [[ -n "$api_token" ]] && KAGI_API_TOKEN="$api_token"
  engine="${engine:-${KAGI_SUMMARIZE_ENGINE:-}}"
  summary_type="${summary_type:-${KAGI_SUMMARIZE_TYPE:-}}"
  lang="${lang:-${KAGI_SUMMARIZE_LANG:-}}"
  cache="${cache:-${KAGI_SUMMARIZE_CACHE:-true}}"
  $raw || raw=${KAGI_SUMMARIZE_RAW:-false}
  $quiet || quiet=${KAGI_SUMMARIZE_QUIET:-false}

  # --- input validation ---

  local input_count=0
  [[ -n "$url" ]] && ((++input_count))
  [[ -n "$file" ]] && ((++input_count))
  [[ -n "$text" ]] && ((++input_count))

  if ((input_count == 0)); then
    _kagi_log --level error "one of --url, --file, or --text is required"
    return 1
  fi
  if ((input_count > 1)); then
    _kagi_log --level error "--url, --file, and --text are mutually exclusive"
    return 1
  fi

  if [[ -n "$engine" ]] && ! _kagi_in_list "$engine" "$_KAGI_ENGINES"; then
    _kagi_log --level error "invalid engine: $engine (expected: $_KAGI_ENGINES)"
    return 1
  fi
  if [[ -n "$summary_type" ]] && ! _kagi_in_list "$summary_type" "$_KAGI_SUMMARY_TYPES"; then
    _kagi_log --level error "invalid type: $summary_type (expected: $_KAGI_SUMMARY_TYPES)"
    return 1
  fi
  if [[ -n "$lang" ]] && ! _kagi_in_list "$lang" "$_KAGI_LANGUAGES"; then
    _kagi_log --level error "invalid language: $lang"
    _kagi_log --level info "valid: $_KAGI_LANGUAGES"
    return 1
  fi

  # --- read file/stdin into text ---

  if [[ -n "$file" ]]; then
    if [[ "$file" == "-" ]]; then
      text=$(cat)
    elif [[ -f "$file" ]]; then
      text=$(<"$file")
    else
      _kagi_log --level error "file not found: $file"
      return 1
    fi
    if [[ -z "$text" ]]; then
      _kagi_log --level error "empty input from ${file}"
      return 1
    fi
  fi

  # --- validate url with trurl ---

  if [[ -n "$url" ]]; then
    local scheme
    scheme=$(trurl --get '{scheme}' "$url" 2>/dev/null) || {
      _kagi_log --level error "invalid URL: $url"
      return 1
    }
    if [[ "$scheme" != "http" && "$scheme" != "https" ]]; then
      _kagi_log --level error "unsupported scheme: $scheme (expected http or https)"
      return 1
    fi
  fi

  # --- build request ---

  local resp
  if [[ -n "$url" ]]; then
    # GET with query params via trurl
    local args=("$KAGI_API_BASE/summarize")
    args+=(--replace-append "url=$url")
    [[ -n "$engine" ]] && args+=(--replace-append "engine=${engine}")
    [[ -n "$summary_type" ]] && args+=(--replace-append "summary_type=${summary_type}")
    [[ -n "$lang" ]] && args+=(--replace-append "target_language=${lang}")
    [[ "$cache" == "false" ]] && args+=(--replace-append "cache=false")

    local request_url
    request_url=$(trurl "${args[@]}")

    $quiet || _kagi_log --level info "summarizing $(trurl --get '{host}' "$url")..."
    resp=$(_kagi_get "$request_url") || return 1
  else
    # POST with JSON body
    local payload
    payload=$(jq -nc \
      --arg text "$text" \
      --arg engine "${engine:-}" \
      --arg summary_type "${summary_type:-}" \
      --arg lang "$lang" \
      --argjson cache "$cache" \
      '{text: $text, cache: $cache}
        + (if $engine != "" then {engine: $engine} else {} end)
        + (if $summary_type != "" then {summary_type: $summary_type} else {} end)
        + (if $lang != "" then {target_language: $lang} else {} end)')

    $quiet || _kagi_log --level info "summarizing text (${#text} chars)..."
    resp=$(_kagi_post "$payload") || return 1
  fi

  # --- handle response ---

  _kagi_check_response "$resp" || return 1

  if $raw; then
    jq . <<<"$resp"
    return 0
  fi

  local output tokens ms
  read -r tokens ms < <(jq -r '[(.data.tokens // "?"), (.meta.ms // "?")] | join(" ")' <<<"$resp")
  output=$(jq -r '.data.output // empty' <<<"$resp")

  if [[ -z "$output" ]]; then
    _kagi_log --level error "empty response from API"
    jq . <<<"$resp" >&2
    return 1
  fi

  _kagi_fmt -- "$output"
  $quiet || _kagi_log --level debug "${tokens} tokens, ${ms}ms"
}
