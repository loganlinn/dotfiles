{lib, ...}:
with lib; {
  toChromeCommandLine = {
    userDataDir ? null,
    profile ? null,
    appId ? null,
    incognito ? false,
    url ? null,
  }:
    escapeShellArgs ([]
      ++ optional (userDataDir != null) "--user-data-dir=${userDataDir}"
      ++ optional (profile != null) "--profile-directory=${profile}"
      ++ optional (appId != null) "--app-id=${appId}"
      ++ optional incognito "--incognito"
      ++ optional (url != null) url);
}
