require("hs.ipc") -- enables `hc` CLI

local config = {
  keys = {
    g = { app = "Claude" },
    s = { app = "Slack" },
    m = { app = "Messages" },
    o = { app = "Obsidian" },
    e = { app = "Finder" },
    p = { app = "1Password" },
    f1 = { app = "System Information" },
    f2 = { app = "Console" },
    f4 = { app = "Activity Monitor" },
  },
}

local pathlib = {}

--- Expands tilde.
---@param path string
---@return string
function pathlib.expand(path)
  if path:sub(1, 1) == "~" then
    path = os.getenv("HOME") .. path:sub(2)
  end
  return path
end

function pathlib.join(dir, base)
  if dir:sub(-1) ~= "/" and base:sub(1, 1) ~= "/" then
    dir = dir .. "/"
  end
  return dir .. base
end

---@param iter string[]|function
---param name string
---@return string|nil
function pathlib.search(iter, name)
  if type(iter) ~= "function" then
    iter = ipairs(iter)
  end
  for _, path in iter do
    local pathname = pathlib.join(path, name)
    if hs.fs.attributes(pathname, "inode") then
      return pathname
    end
  end
end

function pathlib.findNixApp(name)
  return pathlib.search({
    "/Applications/Nix Apps",
    "/Applications/Nix Apps",
    "/Applications/Home Manager Apps",
  }, name .. ".app")
end

local function activateWezterm()
  local app = hs.application.get("com.github.wez.wezterm")
  if app then
    return app:activate()
  end
  local path = pathlib.findNixApp("WezTerm")
  if path then
    return hs.application.launchOrFocus(path)
  end
end

local function bindKey(key, opts)
  local pressFn = opts.pressFn
  if opts.app then
    assert(not opts.pressFn)
    pressFn = function()
      hs.application.launchOrFocus(opts.app)
    end
  end
  hs.hotkey.bind(opts.mods or { "alt" }, opts.key or key, opts.message, pressFn, opts.releaseFn, opts.repeatFn)
end

hs.hotkey.bind({ "alt", "ctrl" }, "r", hs.reload)
hs.hotkey.bind({ "alt" }, "return", activateWezterm)
for key, opts in pairs(config.keys) do
  bindKey(key, opts)
end
hs.alert.show("✅ Hammerspoon")
