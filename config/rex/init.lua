-- https://github.com/rtuszik/sex
require("sex").setup()
rex.bind("ctrl+shift+space>space", "sex_pick")
rex.bind("ctrl+shift+space>l", "sex_last")
rex.bind("ctrl+shift+space>a", "sex_activity")

local function slug_for_remote(url)
	local path
	if url:match("^%a[%w+.-]*://") then
		path = url:match("^%a[%w+.-]*://[^/]*(/[^?#]*)")
	else
		-- Git also accepts scp-style remotes, including bracketed IPv6 hosts.
		path = url:match("^[^/]*%]:/*(.*)$") or url:match("^[^/:]+:/*(.*)$") or url
	end
	local owner, repo = (path or ""):match("^/*([^/]+)/+([^/]+)")
	if not owner or owner == "." or owner == ".." then return end
	repo = repo:gsub("%.git$", "")
	if repo ~= "" and repo ~= "." and repo ~= ".." then return owner .. "/" .. repo end
end

local function session_name_for_path(args)
	local path = assert(args.path, "Missing directory")
	assert(path:sub(1, 1) == "/", "Expected an absolute directory")
	local remotes = assert(rex.exec({ "git", "-C", path, "remote", "-v" }))
	if remotes.ok then
		local first
		for line in remotes.stdout:gmatch("[^\n]+") do
			local name, url = line:match("^(%S+)\t(.+) %(fetch%)$")
			if url then
				local slug = slug_for_remote(url)
				if slug and name == "origin" then return slug end
				first = first or slug
			end
		end
		if first then return first end
	end
	path = path:gsub("/+$", "")
	return path:match("([^/]+/[^/]+)$") or path:match("([^/]+)$") or "/"
end

rex.action({
	name = "open_directory_session",
	title = "New Session in Directory",
	category = "Sessions",
	args = { path = "string" },
	run = function(_, args)
		local session = assert(rex.call("session.create", {
			label = session_name_for_path(args),
			initial_windows = {{ layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell", options = { cwd = args.path },
			}) }},
		}))
		rex.client.queue("session.select", { session_id = session.session_id })
	end,
})

local function focused_pane_path(ctx)
	local block = { session_id = ctx.session_id, block_id = assert(ctx.block_id, "No focused pane") }
	local terminal = "com.superlogical.terminal"
	local process = assert(rex.block.call(terminal, "process", block))
	local cwd = process.foreground and process.foreground.cwd
	if cwd and cwd ~= "" then return cwd end

	local pwd = assert(rex.block.call(terminal, "pwd", block)).pwd
	assert(pwd and pwd ~= "", "Focused pane has no working directory")
	local encoded = pwd:match("^file://[^/]*(/.*)$")
	if encoded then return (encoded:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)) end
	return pwd
end

rex.action({
	name = "rename_session_from_pane",
	title = "Rename Session from Focused Pane Directory",
	category = "Sessions",
	run = function(ctx)
		local label = session_name_for_path({ path = focused_pane_path(ctx) })
		assert(rex.session.set_label({ session_id = ctx.session_id, label = label }))
	end,
})
rex.bind("ctrl+shift+space>r", "rename_session_from_pane")

rex.action({
	name = "new_zoxide_session",
	title = "New Session from Directory",
	category = "Sessions",
	run = function(ctx)
		local command = { "/bin/zsh", "-lc", [[
			dir=$(zoxide query -i) || exit
			[ -d "$dir" ] || exit 1
				exec rex -C "$1" do open_directory_session "path=$dir"
		]], "zoxide-picker", ctx.client_id }
		assert(rex.session.new_layer({
			focus = true,
			bounds = { 0.1, 0.1, 0.8, 0.8 },
			layout = rex.layout.block({
				flavor = "com.superlogical.terminal.shell",
				label = "Pick directory",
				options = { command = command },
			}),
		}))
	end,
})
rex.bind("ctrl+shift+space>z", "new_zoxide_session")

-- https://github.com/xeind/rex-fingers
require("plugins.rex-fingers.lua.rex-fingers").setup({
	binary = os.getenv("HOME") .. "/.local/share/mise/shims/rex-fingers",
	alphabet = "abdefghjkloprstuvwxyz", -- Plugin hint letters in Kitty's alphabetical order.
	hint_style = "30;42",
})

local function hint(key, patterns, action)
	rex.bind("ctrl+shift+" .. key, "rex_fingers", { patterns = patterns, main_action = action })
end

local paths = "path,quoted-path,file-line"
local urls = "url,markdown-url"
hint("e", urls .. "," .. paths, ":open:")
hint("f", paths, ":paste:")
hint("o>e", urls, ":open:")
hint("o>f", paths, ":open:")
hint("o>i", paths, ":open:")
hint("o>n", "file-line", ":open:")
hint("p>a", "ip,ipv6", ":paste:")
hint("p>e", urls, ":paste:")
hint("p>f", paths, ":paste:")
hint("p>h", "sha", ":paste:")
hint("p>i", "ip,ipv6", ":paste:")
hint("p>n", "file-line", ":paste:")
hint("p>p", "digit", ":paste:")
hint("p>shift+e", urls, ":open:")
hint("p>shift+f", paths, ":open:")
hint("p>u", "uuid", ":paste:")
hint("p>v", "semver", ":paste:")
hint("p>y", urls, ":paste:")
hint("y>e", urls, ":copy:")
hint("y>f", paths, ":copy:")
hint("y>h", "sha", ":copy:")
hint("y>i", "ip,ipv6", ":copy:")
hint("y>n", "file-line", ":copy:")
hint("y>u", "uuid", ":copy:")
hint("y>v", "semver", ":copy:")

local function last_command(text)
	-- shortcut: match Starship's blank line, context line and input line until Rex exposes prompt marks.
	text = "\n\n" .. text
	local pending, first, last
	for boundary, input in text:gmatch("()\n\n[^\n]+\n([^\n]+)") do
		local line = " " .. input:gsub("❮", "❯") .. " "
		local _, arrow_end = line:find(" ❯ ", 1, true)
		if arrow_end then
			if pending then first, last = pending, boundary end
			pending = line:find("%S", arrow_end + 1) and boundary + 2
		end
	end
	if not first then error("No completed command found between Starship prompts", 0) end
	return text:sub(first, last)
end

rex.action({
	name = "copy_last_command",
	title = "Copy Last Command and Output",
	run = function(ctx)
		local terminal = "com.superlogical.terminal"
		local page = assert(rex.block.call(terminal, "format", {
			session_id = ctx.session_id, block_id = assert(ctx.block_id, "No focused pane"),
			format = "text", trim = true, unwrap = true, max_bytes = 983040,
		}))
		local parts, offset = { page.content }, #page.content
		local id = page.id
		while id and not page.eof do
			page = assert(rex.block.call(terminal, "blob_read", {
				session_id = ctx.session_id, block_id = ctx.block_id, id = id, offset = offset,
			}))
			parts[#parts + 1] = page.data
			offset = offset + #page.data
		end
		local copied = assert(rex.exec({ "pbcopy" }, {
			env = { LC_CTYPE = "UTF-8" }, stdin = last_command(table.concat(parts)),
		}))
		if not copied.ok then error(copied.stderr, 0) end
	end,
})
rex.bind("ctrl+shift+y>c", "copy_last_command")

----

rex.bind("cmd+shift+ctrl+[", "session.previous")
rex.bind("cmd+shift+ctrl+]", "session.next")
-- rex.bind("cmd+shift+ctrl+1", "session.select", { index = 1 })
-- rex.bind("cmd+shift+ctrl+2", "session.select", { index = 2 })
-- rex.bind("cmd+shift+ctrl+3", "session.select", { index = 3 })
-- rex.bind("cmd+shift+ctrl+4", "session.select", { index = 4 })
-- rex.bind("cmd+shift+ctrl+5", "session.select", { index = 5 })
-- rex.bind("cmd+shift+ctrl+6", "session.select", { index = 6 })
-- rex.bind("cmd+shift+ctrl+7", "session.select", { index = 7 })
-- rex.bind("cmd+shift+ctrl+8", "session.select", { index = 8 })
-- rex.bind("cmd+shift+ctrl+9", "session.select", { index = 9 })
-- rex.bind("cmd+shift+ctrl+0", "session.select", { index = 10 })
--
rex.bind("ctrl+shift+t", "client.tab.new")
rex.bind("ctrl+shift+[", "client.tab.previous")
rex.bind("ctrl+shift+]", "client.tab.next")
rex.bind("ctrl+shift+.", "client.tab.move", { direction = "forward" })
rex.bind("ctrl+shift+,", "client.tab.move", { direction = "backward" })
rex.bind("cmd+1", "client.tab.goto", { index = 1 })
rex.bind("cmd+2", "client.tab.goto", { index = 2 })
rex.bind("cmd+3", "client.tab.goto", { index = 3 })
rex.bind("cmd+4", "client.tab.goto", { index = 4 })
rex.bind("cmd+5", "client.tab.goto", { index = 5 })
rex.bind("cmd+6", "client.tab.goto", { index = 6 })
rex.bind("cmd+7", "client.tab.goto", { index = 7 })
rex.bind("cmd+8", "client.tab.goto", { index = 8 })
rex.bind("cmd+9", "client.tab.goto", { index = 9 })
rex.bind("cmd+0", "client.tab.goto", { index = 10 })
rex.bind("ctrl+shift+f2", "client.palette.toggle")
rex.bind("ctrl+shift+f5", "client.config.reload")
rex.bind("ctrl+shift+f11", "client.window.fullscreen.toggle")
rex.bind("ctrl+shift+1", "client.tab.goto", { index = 1 })
rex.bind("ctrl+shift+2", "client.tab.goto", { index = 2 })
rex.bind("ctrl+shift+3", "client.tab.goto", { index = 3 })
rex.bind("ctrl+shift+4", "client.tab.goto", { index = 4 })
rex.bind("ctrl+shift+5", "client.tab.goto", { index = 5 })
rex.bind("ctrl+shift+6", "client.tab.goto", { index = 6 })
rex.bind("ctrl+shift+7", "client.tab.goto", { index = 7 })
rex.bind("ctrl+shift+8", "client.tab.goto", { index = 8 })
rex.bind("shift+cmd+r", "client.config.reload")
rex.bind("shift+cmd+-", "client.font.decrease")
rex.bind("shift+cmd+0", "client.font.reset")

rex.bind("ctrl+shift+c", "pane.copy")
rex.bind("ctrl+shift+v", "pane.paste")
rex.bind("ctrl+shift+w", "pane.close")
rex.bind("ctrl+shift+h", "pane.focus", { direction = "left" })
rex.bind("ctrl+shift+j", "pane.focus", { direction = "down" })
rex.bind("ctrl+shift+k", "pane.focus", { direction = "up" })
rex.bind("ctrl+shift+l", "pane.focus", { direction = "right" })
rex.bind("ctrl+shift+z", "pane.zoom")
rex.bind("ctrl+shift+enter", "pane.split.auto")
rex.bind("cmd+enter", "pane.split.auto")
rex.bind("cmd+left", "pane.split.left")
rex.bind("cmd+down", "pane.split.down")
rex.bind("cmd+up", "pane.split.up")
rex.bind("cmd+right", "pane.split.right")

rex.bind("cmd+alt+shift+enter", "pane.new_floating")
rex.bind("cmd+alt+enter", "pane.float")
rex.bind("cmd+alt+m", "pane.minimize_floating")
rex.bind("cmd+alt+shift+m", "pane.minimize_all_floating")

rex.bind("ctrl+shift+backspace", "pane.balance")
rex.bind("ctrl+shift+left", "pane.resize", { direction = "right" })
rex.bind("ctrl+shift+down", "pane.resize", { direction = "up" })
rex.bind("ctrl+shift+up", "pane.resize", { direction = "down" })
rex.bind("ctrl+shift+right", "pane.resize", { direction = "left" })

rex.bind("ctrl+shift+d>enter", "pane.move_to_new_tab")
rex.bind("ctrl+shift+d>shift+t", "client.tab.move_to_new_window")

-- -- kitty keyboard mode WIN, named win here: Rex mode names are lowercase (--on-unknown=beep: other keys do nothing). Escape leaves it by default.
-- rex.bind("ctrl+shift+q", "client.mode.enter", { name = "win" })
-- rex.bind("win/ctrl+shift+q", "client.mode.exit")
-- rex.bind("win/ctrl+c", "client.mode.exit")
-- rex.bind("win/ctrl+g", "client.mode.exit")
-- rex.bind("win/q", "client.mode.exit")
-- rex.bind("win/h", "pane.focus", { direction = "left" })
-- rex.bind("win/j", "pane.focus", { direction = "down" })
-- rex.bind("win/k", "pane.focus", { direction = "up" })
-- rex.bind("win/l", "pane.focus", { direction = "right" })
-- rex.bind("win/shift+h", "pane.move", { direction = "left" })
-- rex.bind("win/shift+j", "pane.move", { direction = "down" })
-- rex.bind("win/shift+k", "pane.move", { direction = "up" })
-- rex.bind("win/shift+l", "pane.move", { direction = "right" })
-- rex.bind("win/b", "pane.move", { direction = "down" })
-- rex.bind("win/s", "pane.resize", { amount = 2, direction = "up" })
-- rex.bind("win/ctrl+h", "pane.resize", { amount = 4, direction = "left" })
-- rex.bind("win/ctrl+j", "pane.resize", { amount = 2, direction = "down" })
-- rex.bind("win/ctrl+k", "pane.resize", { amount = 2, direction = "up" })
-- rex.bind("win/ctrl+l", "pane.resize", { amount = 4, direction = "right" })
-- rex.bind("win/ctrl+x", "pane.close")
-- rex.bind("win/x", "pane.close")
-- rex.mode("win", { exclusive = true })
