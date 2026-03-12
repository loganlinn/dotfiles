--[[
  jq '.expiresAt' <~/.aws/sso/cache/*.json(om[1]) | xargs -I {} bash -c '
  seconds=$((($(date -d "{}" +%s) - $(date +%s))));
  hours=$((seconds / 3600));
  minutes=$(((seconds % 3600) / 60));
  if (( hours > 0 )); then
    echo -n "${hours}h";
  fi;
  if (( minutes > 0 )); then
    echo -n "${minutes}m";
  fi;
  '
]]
