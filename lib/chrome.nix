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
      ++ optional (!isNull userDataDir) "--user-data-dir=${userDataDir}"
      ++ optional (!isNull profile) "--profile-directory=${profile}"
      ++ optional (!isNull appId) "--app-id=${appId}"
      ++ optional incognito "--incognito"
      ++ optional (!isNull url) url);
}
