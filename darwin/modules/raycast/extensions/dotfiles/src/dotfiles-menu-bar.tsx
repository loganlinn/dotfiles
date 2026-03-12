import { useEffect, useState } from "react";
import { Icon, MenuBarExtra, open } from "@raycast/api";
import { getFavicon } from "@raycast/utils";

type Bookmark = { name: string; url: string };

const useBookmarks = () => {
  const [state, setState] = useState<{ unseen: Bookmark[]; seen: Bookmark[]; isLoading: boolean }>({
    unseen: [],
    seen: [],
    isLoading: true,
  });
  useEffect(() => {
    (async () => {
      setState({
        unseen: [{ name: "Raycast Teams", url: "https://raycast.com/teams" }],
        seen: [
          { name: "Raycast Store", url: "https://raycast.com/store" },
          { name: "Twitter", url: "https://twitter.com" },
        ],
        isLoading: false,
      });
    })();
  }, []);
  return state;
};

export default function Command() {
  const { unseen: unseenBookmarks, seen: seenBookmarks, isLoading } = useBookmarks();

  return (
    <MenuBarExtra icon={Icon.Bookmark} isLoading={isLoading}>
      <MenuBarExtra.Item title="New" />
      {unseenBookmarks.map((bookmark) => (
        <MenuBarExtra.Item
          key={bookmark.url}
          icon={getFavicon(bookmark.url)}
          title={bookmark.name}
          onAction={() => open(bookmark.url)}
        />
      ))}
      <MenuBarExtra.Separator />
      <MenuBarExtra.Item title="Seen" />
      {seenBookmarks.map((bookmark) => (
        <MenuBarExtra.Item
          key={bookmark.url}
          icon={getFavicon(bookmark.url)}
          title={bookmark.name}
          onAction={() => open(bookmark.url)}
        />
      ))}
    </MenuBarExtra>
  );
}
