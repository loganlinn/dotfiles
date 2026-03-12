#!/usr/bin/env osascript

const showActionSet = ["Show"];
const alertAndBannerSet = [
  "AXNotificationCenterAlert",
  "AXNotificationCenterBanner",
];

(function () {
  const systemEvents = Application("System Events");
  try {
    const notificationCenter =
      systemEvents.processes.byName("NotificationCenter");

    const isPreSequoia = (() => {
      const app = Application.currentApplication();
      app.includeStandardAdditions = true;
      const { systemVersion } = app.systemInfo();
      return parseFloat(systemVersion) < 15.0;
    })();

    const windows = notificationCenter.windows;

    if (windows.length === 0) return;

    (isPreSequoia
      ? windows.at(0).groups.at(0).scrollAreas.at(0).uiElements.at(0).groups()
      : windows
          .at(0)
          .groups.at(0)
          .groups.at(0)
          .scrollAreas.at(0)
          .groups()
          .at(0)
          .uiElements()
          .concat(
            // "Clear All" hierarchy
            windows.at(0).groups.at(0).groups.at(0).scrollAreas.at(0).groups(),
          )
    ) // "Close" hierarchy
      .forEach((group) => {
        const [closeAllAction, closeAction] = group.actions().reduce(
          (matches, action) => {
            switch (action.description()) {
              case "Clear All":
                return [action, matches[1]];
              case "Close":
                return [matches[0], action];
              default:
                return matches;
            }
          },
          [null, null],
        );
        (closeAllAction ?? closeAction)?.perform();
      });
  } catch (error) {
    const notification = Application.currentApplication();
    notification.includeStandardAdditions = true;
    notification.displayNotification(error.message, {
      withTitle: `Error $${error.number}`,
    });
  }
})();
