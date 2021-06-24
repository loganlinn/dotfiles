#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Search NixOS Packages
# @raycast.mode silent
# @raycast.packageName Web Searches

# Optional parameters:
# @raycast.icon images/nix.png
# @raycast.argument1 { "type": "text", "placeholder": "query", "percentEncoded": true }
# @raycast.needsConfirmation false

# Documentation:
# @raycast.description Opens web search on search.nixos.org using default browser
# @raycast.author Logan Linn
# @raycast.authorURL loganlinn.com

open "https://search.nixos.org/packages?query=$1"
