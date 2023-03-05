with builtins;

head (match "([a-zA-Z0-9]+)\n" (
  if pathExists "/etc/hostname"
  then readFile "/etc/hostname"
  else getEnv "HOST"
))
