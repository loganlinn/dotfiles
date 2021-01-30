# dnt
export HOMEBREW_NO_ANALYTICS=1

# resolve symlink so that Brewfile.lock.json written relativeto real file
export HOMEBREW_BUNDLE_FILE=$(realpath $HOME/.Brewfile)
