# GRC colorizes nifty unix tools all over the place
if $(which -s grc)
then
  if $(which -s brew)
  then
    source `brew --prefix`/etc/grc.bashrc
  fi
fi
