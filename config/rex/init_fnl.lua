-- Generated from config/rex-fnl/init.fnl by "mise run rex:build". Do not edit.
local sex = require("sex")
sex.setup()
require("actions")
do
  rex.bind("ctrl+shift+space>space", "sex_pick")
  rex.bind("ctrl+shift+space>l", "sex_last")
  rex.bind("ctrl+shift+space>a", "sex_activity")
  rex.bind("ctrl+shift+space>r>s", "rename_session_from_pane")
  rex.bind("ctrl+shift+space>r>t", "rename_tab_from_branch")
  rex.bind("ctrl+shift+space>z", "new_zoxide_session")
end
local fingers = require("plugins.rex-fingers.lua.rex-fingers")
fingers.setup({binary = (os.getenv("HOME") .. "/.local/share/mise/shims/rex-fingers"), alphabet = "abdefghjkloprstuvwxyz", hint_style = "30;42"})
do
  rex.bind("ctrl+shift+e", "rex_fingers", {main_action = ":open:", patterns = "url,markdown-url,path,quoted-path,file-line"})
  rex.bind("ctrl+shift+o>e", "rex_fingers", {main_action = ":open:", patterns = "url,markdown-url"})
  rex.bind("ctrl+shift+o>f", "rex_fingers", {main_action = ":open:", patterns = "path,quoted-path,file-line"})
  rex.bind("ctrl+shift+o>i", "rex_fingers", {main_action = ":open:", patterns = "path,quoted-path,file-line"})
  rex.bind("ctrl+shift+o>n", "rex_fingers", {main_action = ":open:", patterns = "file-line"})
  rex.bind("ctrl+shift+p>shift+e", "rex_fingers", {main_action = ":open:", patterns = "url,markdown-url"})
  rex.bind("ctrl+shift+p>shift+f", "rex_fingers", {main_action = ":open:", patterns = "path,quoted-path,file-line"})
end
do
  rex.bind("ctrl+shift+f", "rex_fingers", {main_action = ":paste:", patterns = "path,quoted-path,file-line"})
  rex.bind("ctrl+shift+p>a", "rex_fingers", {main_action = ":paste:", patterns = "ip,ipv6"})
  rex.bind("ctrl+shift+p>e", "rex_fingers", {main_action = ":paste:", patterns = "url,markdown-url"})
  rex.bind("ctrl+shift+p>f", "rex_fingers", {main_action = ":paste:", patterns = "path,quoted-path,file-line"})
  rex.bind("ctrl+shift+p>h", "rex_fingers", {main_action = ":paste:", patterns = "sha"})
  rex.bind("ctrl+shift+p>i", "rex_fingers", {main_action = ":paste:", patterns = "ip,ipv6"})
  rex.bind("ctrl+shift+p>n", "rex_fingers", {main_action = ":paste:", patterns = "file-line"})
  rex.bind("ctrl+shift+p>p", "rex_fingers", {main_action = ":paste:", patterns = "digit"})
  rex.bind("ctrl+shift+p>u", "rex_fingers", {main_action = ":paste:", patterns = "uuid"})
  rex.bind("ctrl+shift+p>v", "rex_fingers", {main_action = ":paste:", patterns = "semver"})
  rex.bind("ctrl+shift+p>y", "rex_fingers", {main_action = ":paste:", patterns = "url,markdown-url"})
end
do
  rex.bind("ctrl+shift+y>e", "rex_fingers", {main_action = ":copy:", patterns = "url,markdown-url"})
  rex.bind("ctrl+shift+y>f", "rex_fingers", {main_action = ":copy:", patterns = "path,quoted-path,file-line"})
  rex.bind("ctrl+shift+y>h", "rex_fingers", {main_action = ":copy:", patterns = "sha"})
  rex.bind("ctrl+shift+y>i", "rex_fingers", {main_action = ":copy:", patterns = "ip,ipv6"})
  rex.bind("ctrl+shift+y>n", "rex_fingers", {main_action = ":copy:", patterns = "file-line"})
  rex.bind("ctrl+shift+y>u", "rex_fingers", {main_action = ":copy:", patterns = "uuid"})
  rex.bind("ctrl+shift+y>v", "rex_fingers", {main_action = ":copy:", patterns = "semver"})
end
do
  rex.bind("ctrl+shift+y>c", "copy_last_command")
end
do
  rex.bind("cmd+shift+ctrl+[", "session.previous")
  rex.bind("cmd+shift+ctrl+]", "session.next")
end
do
  rex.bind("ctrl+shift+t", "client.tab.new")
  rex.bind("ctrl+shift+[", "client.tab.previous")
  rex.bind("ctrl+shift+]", "client.tab.next")
  rex.bind("ctrl+shift+.", "client.tab.move", {direction = "forward"})
  rex.bind("ctrl+shift+,", "client.tab.move", {direction = "backward"})
end
do
  rex.bind("cmd+1", "client.tab.goto", {index = 1})
  rex.bind("cmd+2", "client.tab.goto", {index = 2})
  rex.bind("cmd+3", "client.tab.goto", {index = 3})
  rex.bind("cmd+4", "client.tab.goto", {index = 4})
  rex.bind("cmd+5", "client.tab.goto", {index = 5})
  rex.bind("cmd+6", "client.tab.goto", {index = 6})
  rex.bind("cmd+7", "client.tab.goto", {index = 7})
  rex.bind("cmd+8", "client.tab.goto", {index = 8})
  rex.bind("cmd+9", "client.tab.goto", {index = 9})
  rex.bind("cmd+0", "client.tab.goto", {index = 10})
end
do
  rex.bind("ctrl+shift+1", "client.tab.goto", {index = 1})
  rex.bind("ctrl+shift+2", "client.tab.goto", {index = 2})
  rex.bind("ctrl+shift+3", "client.tab.goto", {index = 3})
  rex.bind("ctrl+shift+4", "client.tab.goto", {index = 4})
  rex.bind("ctrl+shift+5", "client.tab.goto", {index = 5})
  rex.bind("ctrl+shift+6", "client.tab.goto", {index = 6})
  rex.bind("ctrl+shift+7", "client.tab.goto", {index = 7})
  rex.bind("ctrl+shift+8", "client.tab.goto", {index = 8})
end
do
  rex.bind("ctrl+shift+f2", "client.palette.toggle")
  rex.bind("ctrl+shift+f5", "client.config.reload")
  rex.bind("shift+cmd+r", "client.config.reload")
  rex.bind("ctrl+shift+f11", "client.window.fullscreen.toggle")
  rex.bind("shift+cmd+-", "client.font.decrease")
  rex.bind("shift+cmd+0", "client.font.reset")
end
do
  rex.bind("ctrl+shift+c", "pane.copy")
  rex.bind("ctrl+shift+v", "pane.paste")
  rex.bind("ctrl+shift+w", "pane.close")
  rex.bind("ctrl+shift+z", "pane.zoom")
  rex.bind("ctrl+shift+backspace", "pane.balance")
  rex.bind("ctrl+shift+d>enter", "pane.move_to_new_tab")
  rex.bind("ctrl+shift+d>shift+t", "client.tab.move_to_new_window")
  rex.bind("ctrl+shift+enter", "pane.split.auto")
  rex.bind("cmd+enter", "pane.split.auto")
end
do
  rex.bind("ctrl+shift+h", "pane.focus", {direction = "left"})
  rex.bind("ctrl+shift+j", "pane.focus", {direction = "down"})
  rex.bind("ctrl+shift+k", "pane.focus", {direction = "up"})
  rex.bind("ctrl+shift+l", "pane.focus", {direction = "right"})
end
do
  rex.bind("cmd+left", "pane.split.left")
  rex.bind("cmd+down", "pane.split.down")
  rex.bind("cmd+up", "pane.split.up")
  rex.bind("cmd+right", "pane.split.right")
end
do
  rex.bind("ctrl+shift+left", "pane.resize", {direction = "right"})
  rex.bind("ctrl+shift+down", "pane.resize", {direction = "up"})
  rex.bind("ctrl+shift+up", "pane.resize", {direction = "down"})
  rex.bind("ctrl+shift+right", "pane.resize", {direction = "left"})
end
rex.bind("cmd+alt+shift+enter", "pane.new_floating")
rex.bind("cmd+alt+enter", "pane.float")
rex.bind("cmd+alt+m", "pane.minimize_floating")
return rex.bind("cmd+alt+shift+m", "pane.minimize_all_floating")
