# GRC colorizes nifty unix tools all over the place
[[ "$(uname)" == 'Darwin' ]] || exit

if $(grc &>/dev/null) && $(brew &>/dev/null)
then
  source `brew --prefix`/etc/grc.bashrc
fi
