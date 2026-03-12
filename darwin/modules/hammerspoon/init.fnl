(require :hs.ipc)

;; Generate type annotations
(hs.loadSpoon :EmmyLua)

(local log (hs.logger.new :init.fnl :info))

;; Auto-reload configuration when init file changes
(var config-watcher nil)
(set config-watcher (-> (hs.pathwatcher.new (.. hs.configdir :/init.fnl)
                                            (fn [paths flag-tables]
                                              (when config-watcher
                                                (hs.reload))))
                        (.start)))

;; Add config directory to package path
(pcall (fn []
         (local fs hs.fs)
         (local configdir (fs.pathToAbsolute hs.configdir))
         (local initdir (-> (fs.pathToAbsolute (.. configdir :/init.fnl))
                            (: :match "(.*/)")))
         (when (not= configdir initdir)
           (set package.path (.. initdir "/?.lua;" package.path))
           (log.i :Added initdir "to package.path"))))

;; Menubar setup
(local menubar (hs.menubar.new true :usr))

(menubar:setClickCallback (fn [mods]
                            (log.i "menubar clicked" (hs.inspect mods))))

;; AWS SSO timeout display
(fn refresh-menubar []
  (let [(stdout ok) (hs.execute (.. (os.getenv :HOME)
                                    :/.dotfiles/bin/aws-sso-timeout))]
    (when ok
      (local seconds (tonumber stdout))
      (var title "")
      (local hours (math.floor (/ seconds 3600)))
      (when (> hours 0)
        (set title (.. hours "h ")))
      (local minutes (math.floor (/ (math.fmod seconds 3600) 60)))
      (when (> minutes 0)
        (set title (.. title minutes :m)))
      (menubar:setTitle title))))

(-> (hs.timer.doEvery 60 refresh-menubar)
    (.start))

(refresh-menubar)

;; Key modifier constants
(local CTRL "⌃")
(local ALT "⌥")
(local SHIFT "⇧")
(local GUI "⌘")
(local MEH (.. CTRL SHIFT ALT))
(local HYPER (.. CTRL SHIFT ALT GUI))

;; Helper functions
(local execute-fn (partial partial hs.execute))
(local launch-or-focus hs.application.launchOrFocus)
(local launch-or-focus-fn (partial partial launch-or-focus))

(local launch-or-focus-wezterm
       (fn []
         (or (launch-or-focus :com.github.wez.wezterm) ; compiled from source
             (launch-or-focus :WezTerm))))

; signed release

;; Close notifications function with JavaScript
(local close-notifications (fn []
                             (log.i "Closing notifications")
                             (hs.osascript.javascript "
    function run() {
      const SystemEvents = Application(\"System Events\");

      const NotificationCenter =
        SystemEvents.processes.byName(\"NotificationCenter\");

      const isPreSequoia = (() => {
        const app = Application.currentApplication();
        app.includeStandardAdditions = true;
        const { systemVersion } = app.systemInfo();
        return parseFloat(systemVersion) < 15.0;
      })();

      const windows = NotificationCenter.windows;
      if (windows.length === 0) {
        return;
      }

      (isPreSequoia
        ? windows.at(0).groups.at(0).scrollAreas.at(0).uiElements.at(0).groups()
        : windows // \"Clear all\" hierarchy
            .at(0)
            .groups.at(0)
            .groups.at(0)
            .scrollAreas.at(0)
            .groups()
            .at(0)
            .uiElements()
            .concat(
              windows // \"Close\" hierarchy
                .at(0)
                .groups.at(0)
                .groups.at(0)
                .scrollAreas.at(0)
                .groups(),
            )
      ).forEach((group) => {
        const [closeAllAction, closeAction] = group.actions().reduce(
          (matches, action) => {
            switch (action.description()) {
              case \"Clear All\":
                return [action, matches[1]];
              case \"Close\":
                return [matches[0], action];
              default:
                return matches;
            }
          },
          [null, null],
        );
        (closeAllAction ?? closeAction)?.perform();
      });
    }")))

;; Modal modes setup with metatable
(local modes
       (setmetatable {}
                     {:__newindex (fn [self name mode]
                                    (log.i "Registering mode" name)
                                    (set mode.entered
                                         (or mode.entered
                                             (partial hs.alert (.. "+" name))))
                                    (set mode.exited
                                         (or mode.exited
                                             (partial hs.alert (.. "-" name))))
                                    (rawset self name mode))}))

;; Main modal mode configuration
(set modes.main (-> (hs.hotkey.modal.new HYPER :k)
                    (.bind ALT :return launch-or-focus-wezterm)
                    (.bind (.. SHIFT ALT) :return
                           (launch-or-focus-fn "Google Chrome"))
                    (.bind ALT :e (launch-or-focus-fn :Emacs))
                    (.bind ALT :i (launch-or-focus-fn :Linear))
                    (.bind ALT :m (launch-or-focus-fn :Messages))
                    (.bind ALT :o (launch-or-focus-fn :Finder))
                    (.bind ALT :p (launch-or-focus-fn :Claude))
                    (.bind ALT :s (launch-or-focus-fn :Slack))
                    (.bind HYPER :a
                           (execute-fn "zsh -lc 'aerospace reload-config'"))
                    (.bind HYPER :d hs.toggleConsole)
                    (.bind HYPER :l hs.caffeinate.lockScreen)
                    (.bind HYPER :r hs.reload)
                    (.bind HYPER :s hs.hints.windowHints)
                    (.bind HYPER :x close-notifications)
                    (.bind HYPER :F1
                           (fn []
                             (hs.execute "zsh -lc 'wezterm cli spawn --new-window e1s'")))
                    (.bind HYPER :F2 (fn [] (hs.alert :F2)))
                    (.bind HYPER :F3 (fn [] (hs.alert :F3)))
                    (.bind HYPER :F4 (fn [] (hs.alert :F4)))
                    (.bind HYPER :F5 (fn [] (hs.alert :F5)))
                    (.bind HYPER :F6 (fn [] (hs.alert :F6)))
                    (.bind HYPER :F7 (fn [] (hs.alert :F7)))
                    (.bind HYPER :F8 (fn [] (hs.alert :F8)))
                    (.bind HYPER :F9 (fn [] (hs.alert :F9)))
                    (.bind HYPER :k (fn [] (modes.main:exit))) ; toggles mode
                    (.enter)))

(hs.alert "✅ Hammerspoon")
