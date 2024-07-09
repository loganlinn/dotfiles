#Requires AutoHotkey v2.0
#SingleInstance Force
#MaxThreadsPerHotkey 1

;; ----------------------------------------------------------------------------
;; Functions
;; ----------------------------------------------------------------------------

WinActivateOrRun(win, runTarget, runParams*) {
  if WinExist(win) {
    WinActivate(win)
  } else {
    Run(runTarget, runParams*)
  }
}

IsURL(s) {
  return IsSet(s) and (InStr(s, "://") > 0)
}

OpenClipboardURL() {
  url := A_Clipboard
  if IsUrl(url) {
    Run(url)
    return true
  }
  return false
}

;; ----------------------------------------------------------------------------
;; Hotkeys
;; ----------------------------------------------------------------------------

#Enter:: Run("wt.exe")
#+Enter:: Run("firefox.exe -new-tab about:newtab")
#+o:: OpenClipboardURL