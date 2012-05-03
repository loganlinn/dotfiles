# GRC colorizes nifty unix tools all over the place
if $(which grc &>/dev/null)
then
  if $(which brew &>/dev/null)
  then
    source `brew --prefix`/etc/grc.bashrc
  fi
fi
