---@alias keysym.arrow "left"|"right"|"down"|"up"
---@alias keysym.cursor "tab"|"space"|"home"|"end"|"delete"|"forwarddelete"|"pageup"|"pagedown"
---@alias keysym.function "f1"|"f2"|"f3"|"f4"|"f5"|"f6"|"f7"|"f8"|"f9"|"f10"|"f11"|"f12"|"f13"|"f14"|"f15"|"f16"|"f17"|"f18"|"f19"|"f20"
---@alias keysym.keypad "pad."|"pad*"|"pad+"|"pad/"|"pad-"|"pad="|"pad0"|"pad1"|"pad2"|"pad3"|"pad4"|"pad5"|"pad6"|"pad7"|"pad8"|"pad9"|"padclear"|"padenter"
---@alias keysym.modifier "shift"|"rightshift"|"cmd"|"rightcmd"|"alt"|"rightalt"|"ctrl"|"rightctrl"|"capslock"|"fn"|"return"|"escape"
---@alias keysym.alpha "a"|"b"|"c"|"d"|"e"|"f"|"g"|"h"|"i"|"j"|"k"|"l"|"m"|"n"|"o"|"p"|"q"|"r"|"s"|"t"|"u"|"v"|"w"|"x"|"y"|"z"
---@alias keysym.numeric "0"|"1"|"2"|"3"|"4"|"5"|"6"|"7"|"8"|"9"
---@alias keysym.other "["|"]"|"\"|";"|"'"|","|"."|"/"|"-"|"="|"'"
---@alias keysym.key
---|keysym.alpha
---|keysym.arrow
---|keysym.cursor
---|keysym.function
---|keysym.keypad
---|keysym.numeric
---|keysym.other
---@alias keysym keysym.modifier|keysym.key
---@alias keyspec [keysym.modifier[], keysym.key]

local keysym = {}
do
	local idmap = function(...)
		local m = {}
		for i = 1, select("#", ...) do
			local e = select(i, ...)
			m[e] = e
		end
		return m
	end

	---@type table<keysym.modifier, keysym.modifier>
	keysym.modifier = idmap(
		"shift",
		"rightshift",
		"cmd",
		"rightcmd",
		"alt",
		"rightalt",
		"ctrl",
		"rightctrl",
		"capslock",
		"fn",
		"return",
		"escape"
	)
	---@type table<string, keysym>
	keysym.alias = {}
end
-- local kbd = {}
-- do
--      setmetatable(kbd, {
--          __call = function(...)
--              return kbd.parse(...)
--          end,
--      })
--      function kbd.mod.parse(mod)
--          if mod == "C" then
--              return keysym.modifier.ctrl
--          elseif mod == "S" then
--              return kbd.mod.key.SHIFT
--          elseif mod == "A" then
--              return kbd.mod.key.ALT
--          elseif mod == "M" then
--              return kbd.mod.key.META
--          elseif mod == "H" then
--              return kbd.mod.key.HYPER
--          end
--      end

--      function kbd.parse(keyseq_text)
--          local keyspecs = {}
--          for keys_text in string.gmatch(keyseq_text, "[^%s]+") do
--              local mods = {}
--              for key_text in string.gmatch(keyseq_text, "[^-]+") do
--                  table.insert(mods, key_text)
--              end
--              local key = table.remove(mods, #mods)
--              table.insert(keyspecs, { mods, key })
--          end
--          return keyspecs
--      end
-- end
