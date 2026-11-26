-- Custom Rex actions for init_fnl.lua, which requires this file and binds the keys.
-- A copy of the action code in init.lua: its rex.bind lines are in config/rex-fnl/init.fnl.

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

local function prompt_rename(session_id, window_id, value)
	local title = window_id and "Rename tab" or "Rename session"
	if rex.ui and rex.ui.input then
		local label, reason, detail = rex.ui.input({ title = title, value = value, confirm = "Rename" })
		if label == nil then
			if reason == "cancelled" or reason == "timeout" then return end
			error(detail or reason)
		end
		if not label:match("%S") then return end
		if window_id then
			assert(rex.session.set_window_label({ session_id = session_id, window_id = window_id, label = label }))
		else
			assert(rex.session.set_label({ session_id = session_id, label = label }))
		end
		return
	end

	-- Older Rex servers lack rex.ui.input; capture the target before the floating pane takes focus.
	local command = { "/bin/zsh", "-lc", [=[
		label=$(gum input --value="$1" --char-limit=128 --no-show-help) || exit
		[[ $label == *[^[:space:]]* ]] || exit 0
		if [[ -n $3 ]]; then
			exec rex window rename -s "$2" -- "$3" "$label"
		fi
		exec rex session rename -- "$2" "$label"
	]=], "rename", value, session_id, window_id or "" }
	assert(rex.session.new_layer({
		session_id = session_id, window_id = window_id, focus = true,
		bounds = { 0.2, 0.44, 0.6, 0.12 },
		layout = rex.layout.block({
			flavor = "com.superlogical.terminal.shell", label = title, options = { command = command },
		}),
	}))
end

rex.action({
	name = "rename_session_from_pane",
	title = "Rename Session from Focused Pane Directory",
	category = "Sessions",
	run = function(ctx)
		local label = session_name_for_path({ path = focused_pane_path(ctx) })
		prompt_rename(ctx.session_id, nil, label)
	end,
})

rex.action({
	name = "rename_tab_from_branch",
	title = "Rename Tab from Focused Pane Git Branch",
	category = "Tabs",
	run = function(ctx)
		local path = focused_pane_path(ctx)
		local result = assert(rex.exec({ "git", "-C", path, "branch", "--show-current" }))
		assert(result.ok, result.stderr)
		local branch = assert(result.stdout:match("^[^\r\n]+"), "Detached HEAD has no branch name")
		local pane = assert(rex.session.describe_block({ session_id = ctx.session_id, block_id = ctx.block_id }))
		prompt_rename(ctx.session_id, assert(pane.block.window_id, "Focused pane has no tab"), " " .. branch)
	end,
})

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
