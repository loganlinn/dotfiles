local prototype = {
  deref = function(self)
    if self.__fn then
      local ok, val = pcall(self.__fn)
      if ok then
        self.__val = val
      else
        self.__err = val
      end
      self.__fn = nil
    end
    if self.__err then
      error(self.__err, 2)
    end
    return self.__val
  end,
  realized = function(self)
    return self.__fn == nil
  end,
}

local metatable = {
  __index = prototype,
  __call = prototype.deref,
}

return function(fn)
  return setmetatable({ __fn = fn, __val = nil, __err = nil }, metatable)
end
