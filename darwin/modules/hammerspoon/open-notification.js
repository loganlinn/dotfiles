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

    // Does not work pre-Sequoia
    const mainGroup = notificationCenter.windows
      .at(0)
      .groups.at(0)
      .groups.at(0)
      .scrollAreas.at(0)
      .groups();

    let groups = mainGroup.groups.whose({
      subrole: "AXNotificationCenterAlert",
    });

    let targetGroup;
    if (groups.length === 0) {
      if (alertAndBannerSet.includes(mainGroup.subrole())) {
        targetGroup = mainGroup;
      } else {
        return;
      }
    } else {
      targetGroup = groups[0];
    }

    const actions = targetGroup.actions();
    let showActionExists = false;

    for (let action of actions) {
      if (showActionSet.includes(action.description())) {
        action.perform();
        showActionExists = true;
        break;
      }
    }

    if (!showActionExists) {
      targetGroup.actions.byName("AXPress").perform();
    }
  } catch (error) {
    const notification = Application.currentApplication();
    notification.includeStandardAdditions = true;
    notification.displayNotification(error.message, {
      withTitle: `Error $${error.number}`,
    });
  }
})();
