set shell := ["bash", "-e", "-u", "-o", "pipefail", "-c"]
set unstable := true
set dotenv-load := true
set positional-arguments := true

gpg := require("gpg")
gpgconf := require("gpgconf")
gnupg_home := env_var_or_default("GNUPGHOME", home_dir() / ".gnupg")

op := require("op")
op_vault := "Private"
op_tags := "gpg"

[script]
@init:
    mkdir -p "{{gnupg_home}}"
    chmod 700 "{{gnupg_home}}"
    just restart

# Restart GPG agent
restart: stop start

# Stop GPG agent
stop:
    {{gpgconf}} --kill gpg-agent

alias kill := stop

# Start GPG agent
start:
    {{gpgconf}} --launch gpg-agent

alias launch := start

# Generates GPG key and stores in 1Password
[script]
create $user_id="" $algo="rsa4096" $expire="never":
    logerr() { >&2 echo -e "{{style('error')}}$*{{NORMAL}}"; }
    logwrn() { >&2 echo -e "{{style('warning')}}$*{{NORMAL}}"; }
    logcmd() { >&2 echo -e "{{style('command')}}$*{{NORMAL}}"; }
    logvar() { >&2 echo -e "{{BLUE}}${1}{{NORMAL}}={{GREEN}}'${!1}'{{NORMAL}}" || true; }

    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    [[ -n $user_id ]] || user_id=$(printf "%s <%s>" "$(git config --get user.name)" "$(git config --get user.email)")
    logvar user_id
    logvar algo
    logvar expire

    unset -v passphrase
    echo -n "passphrase: "
    IFS= read -rs passphrase
    echo
    [[ -n $passphrase ]] || logwrn "GPG key will not have passphrase!"

    passphrase_file=${tmpdir}/passphrase
    touch "$passphrase_file"
    chmod 600 "$passphrase_file"
    cat >"$passphrase_file" <<<"$passphrase"
    chmod 400 "$passphrase_file"
    logvar passphrase_file

    mkdir -p "${tmpdir}/gnupg"
    chmod 700 "${tmpdir}/gnupg"

    _gpg() { {{gpg}} --homedir="${tmpdir}/gnupg" "$@"; }
    _gpg_with_passphrase() { _gpg --batch --pinentry-mode=loopback --passphrase-file="$passphrase_file" "$@"; }

    _gpg_with_passphrase --quick-generate-key "${user_id}" "${algo}" cert "${expire}"

    key_id=$(_gpg --list-keys --keyid-format=long --with-colons "${user_id}" | awk -F: '$1 == "pub" { print $5 }')
    logvar key_id

    fingerprint=$(_gpg --fingerprint --with-colons  "${user_id}" | awk -F: '$1 == "fpr" { print $10 }' | head -n1)
    logvar fingerprint

    _gpg_with_passphrase --quick-add-key "${fingerprint}" "${algo}" sign "${expire}"
    _gpg_with_passphrase --quick-add-key "${fingerprint}" "${algo}" encr "${expire}"
    _gpg_with_passphrase --quick-add-key "${fingerprint}" "${algo}" auth "${expire}"

    item=$(
      {{op}} item create \
        --format=json \
        --title="GPG: ${user_id}" \
        --vault="{{op_vault}}" \
        --tags='{{op_tags}}' \
        --category=password \
        - \
        'password'="$passphrase" \
        'GPG.user-id[text]'="${user_id}" \
        'GPG.key-id[text]'="${key_id}" \
        'GPG.fingerprint[text]'="${fingerprint}" \
        'GPG.public-key[text]'="$(_gpg --export --armor "${fingerprint}")" \
        'GPG.private-key[password]'="$(_gpg_with_passphrase --export-secret-keys --armor "${fingerprint}")" \
        'GPG.private-subkeys[password]'="$(_gpg_with_passphrase --export-secret-subkeys --armor "${fingerprint}")"
    )
    op_item_id="$(jq -r '.id' <<<"$item")" \
    op_item_title="$(jq -r '.title' <<<"$item")" \
    op_item_vault="$(jq -r '.vault.name' <<<"$item")"
    logvar op_item_id
    logvar op_item_title
    logvar op_item_vault

op-list:
  {{op}} item list --format=json --vault="{{op_vault}}" --tags="{{op_tags}}" "$@" | jq . -C
