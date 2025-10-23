# BEGIN_AWS_SSO_CLI

# AWS SSO requires `bashcompinit` which needs to be enabled once and
# only once in your shell.  Hence we do not include the two lines:
#
# autoload -Uz +X compinit && compinit
# autoload -Uz +X bashcompinit && bashcompinit
#
# If you do not already have these lines, you must COPY the lines
# above, place it OUTSIDE of the BEGIN/END_AWS_SSO_CLI markers
# and of course uncomment it

__aws_sso_profile_complete() {
     local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    _multi_parts : "($(/nix/store/41lsb6h9ycmmnaxz15r06ckg076dbm1b-aws-sso-cli-2.0.3/bin/.aws-sso-wrapped ${=_args} list --csv Profile))"
}

aws-sso-profile() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    if [ -n "$AWS_PROFILE" ]; then
        echo "Unable to assume a role while AWS_PROFILE is set"
        return 1
    fi

    if [ -z "$1" ]; then
        echo "Usage: aws-sso-profile <profile>"
        return 1
    fi

    eval $(/nix/store/41lsb6h9ycmmnaxz15r06ckg076dbm1b-aws-sso-cli-2.0.3/bin/.aws-sso-wrapped ${=_args} eval -p "$1")
    if [ "$AWS_SSO_PROFILE" != "$1" ]; then
        return 1
    fi
}

aws-sso-clear() {
    local _args=${AWS_SSO_HELPER_ARGS:- -L error}
    if [ -z "$AWS_SSO_PROFILE" ]; then
        echo "AWS_SSO_PROFILE is not set"
        return 1
    fi
    eval $(/nix/store/41lsb6h9ycmmnaxz15r06ckg076dbm1b-aws-sso-cli-2.0.3/bin/.aws-sso-wrapped ${=_args} eval -c)
}

compdef __aws_sso_profile_complete aws-sso-profile
complete -C /nix/store/41lsb6h9ycmmnaxz15r06ckg076dbm1b-aws-sso-cli-2.0.3/bin/.aws-sso-wrapped aws-sso

# END_AWS_SSO_CLI
