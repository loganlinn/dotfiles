-- A lexical analyzer for simple shell-like syntaxes
-- Converted from Python's shlex module (cpython 3.14)

local M = {}

-- Helper: Create a string reader (like Python's StringIO)
local function StringReader(str)
  local pos = 1
  return {
    read = function(self, n)
      if pos > #str then
        return nil
      end
      local result = str:sub(pos, pos + (n or 1) - 1)
      pos = pos + (n or 1)
      return result ~= "" and result or nil
    end,
    readline = function(self)
      local start = pos
      local newline_pos = str:find("\n", start, true)
      if newline_pos then
        pos = newline_pos + 1
        return str:sub(start, newline_pos)
      else
        pos = #str + 1
        return str:sub(start)
      end
    end,
    close = function(self) end,
  }
end

-- Helper: Check if character is in string
local function contains(str, char)
  return str:find(char, 1, true) ~= nil
end

-- Shlex class
local Shlex = {}
Shlex.__index = Shlex

function Shlex.new(instream, infile, posix, punctuation_chars)
  local self = setmetatable({}, Shlex)

  -- Handle string input
  if type(instream) == "string" then
    instream = StringReader(instream)
  end

  self.instream = instream or io.stdin
  self.infile = infile
  self.posix = posix or false

  if self.posix then
    self.eof = nil
  else
    self.eof = ""
  end

  self.commenters = "#"
  self.wordchars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

  if self.posix then
    self.wordchars = self.wordchars
      .. "ßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ"
  end

  self.whitespace = " \t\r\n"
  self.whitespace_split = false
  self.quotes = "'\""
  self.escape = "\\"
  self.escapedquotes = '"'
  self.state = " "
  self.pushback = {}
  self.lineno = 1
  self.debug = 0
  self.token = ""
  self.filestack = {}
  self.source = nil

  -- Handle punctuation_chars
  if punctuation_chars == nil or punctuation_chars == false then
    punctuation_chars = ""
  elseif punctuation_chars == true then
    punctuation_chars = "();<>|&"
  end

  self._punctuation_chars = punctuation_chars

  if punctuation_chars ~= "" then
    self._pushback_chars = {}
    self.wordchars = self.wordchars .. "~-./*?="

    -- Remove punctuation chars from wordchars
    for i = 1, #punctuation_chars do
      local char = punctuation_chars:sub(i, i)
      self.wordchars = self.wordchars:gsub(char:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1"), "")
    end
  end

  return self
end

function Shlex:push_token(tok)
  if self.debug >= 1 then
    print("shlex: pushing token " .. ("%q"):format(tok))
  end
  table.insert(self.pushback, 1, tok)
end

function Shlex:push_source(newstream, newfile)
  if type(newstream) == "string" then
    newstream = StringReader(newstream)
  end

  table.insert(self.filestack, 1, { self.infile, self.instream, self.lineno })
  self.infile = newfile
  self.instream = newstream
  self.lineno = 1

  if self.debug > 0 then
    if newfile then
      print("shlex: pushing to file " .. newfile)
    else
      print("shlex: pushing to stream")
    end
  end
end

function Shlex:pop_source()
  self.instream:close()
  local entry = table.remove(self.filestack, 1)
  self.infile = entry[1]
  self.instream = entry[2]
  self.lineno = entry[3]

  if self.debug > 0 then
    print(("shlex: popping to stream, line %d"):format(self.lineno))
  end

  self.state = " "
end

function Shlex:get_token()
  -- Check pushback stack
  if #self.pushback > 0 then
    local tok = table.remove(self.pushback, 1)
    if self.debug >= 1 then
      print("shlex: popping token " .. ("%q"):format(tok))
    end
    return tok
  end

  -- Get a raw token
  local raw = self:read_token()

  -- Handle inclusions
  if self.source then
    while raw == self.source do
      local spec = self:sourcehook(self:read_token())
      if spec then
        self:push_source(spec[2], spec[1])
      end
      raw = self:get_token()
    end
  end

  -- Handle EOF
  while raw == self.eof do
    if #self.filestack == 0 then
      return self.eof
    else
      self:pop_source()
      raw = self:get_token()
    end
  end

  if self.debug >= 1 then
    if raw ~= self.eof then
      print("shlex: token=" .. ("%q"):format(raw))
    else
      print("shlex: token=EOF")
    end
  end

  return raw
end

function Shlex:read_token()
  local quoted = false
  local escapedstate = " "

  while true do
    local nextchar

    -- Get next character
    if self._punctuation_chars ~= "" and #self._pushback_chars > 0 then
      nextchar = table.remove(self._pushback_chars)
    else
      nextchar = self.instream:read(1)
    end

    if nextchar == "\n" then
      self.lineno = self.lineno + 1
    end

    if self.debug >= 3 then
      print(("shlex: in state %q I see character: %q"):format(self.state or "nil", nextchar or "nil"))
    end

    if self.state == nil then
      self.token = ""
      break
    elseif self.state == " " then
      if not nextchar then
        self.state = nil
        break
      elseif contains(self.whitespace, nextchar) then
        if self.debug >= 2 then
          print("shlex: I see whitespace in whitespace state")
        end
        if self.token ~= "" or (self.posix and quoted) then
          break
        else
          -- continue
        end
      elseif contains(self.commenters, nextchar) then
        self.instream:readline()
        self.lineno = self.lineno + 1
      elseif self.posix and contains(self.escape, nextchar) then
        escapedstate = "a"
        self.state = nextchar
      elseif contains(self.wordchars, nextchar) then
        self.token = nextchar
        self.state = "a"
      elseif contains(self._punctuation_chars, nextchar) then
        self.token = nextchar
        self.state = "c"
      elseif contains(self.quotes, nextchar) then
        if not self.posix then
          self.token = nextchar
        end
        self.state = nextchar
      elseif self.whitespace_split then
        self.token = nextchar
        self.state = "a"
      else
        self.token = nextchar
        if self.token ~= "" or (self.posix and quoted) then
          break
        else
          -- continue
        end
      end
    elseif contains(self.quotes, self.state) then
      quoted = true
      if not nextchar then
        if self.debug >= 2 then
          print("shlex: I see EOF in quotes state")
        end
        error("No closing quotation")
      end
      if nextchar == self.state then
        if not self.posix then
          self.token = self.token .. nextchar
          self.state = " "
          break
        else
          self.state = "a"
        end
      elseif self.posix and contains(self.escape, nextchar) and contains(self.escapedquotes, self.state) then
        escapedstate = self.state
        self.state = nextchar
      else
        self.token = self.token .. nextchar
      end
    elseif contains(self.escape, self.state) then
      if not nextchar then
        if self.debug >= 2 then
          print("shlex: I see EOF in escape state")
        end
        error("No escaped character")
      end

      -- In posix shells, only the quote itself or escape char may be escaped
      if contains(self.quotes, escapedstate) and nextchar ~= self.state and nextchar ~= escapedstate then
        self.token = self.token .. self.state
      end

      self.token = self.token .. nextchar
      self.state = escapedstate
    elseif self.state == "a" or self.state == "c" then
      if not nextchar then
        self.state = nil
        break
      elseif contains(self.whitespace, nextchar) then
        if self.debug >= 2 then
          print("shlex: I see whitespace in word state")
        end
        self.state = " "
        if self.token ~= "" or (self.posix and quoted) then
          break
        else
          -- continue
        end
      elseif contains(self.commenters, nextchar) then
        self.instream:readline()
        self.lineno = self.lineno + 1
        if self.posix then
          self.state = " "
          if self.token ~= "" or (self.posix and quoted) then
            break
          else
            -- continue
          end
        end
      elseif self.state == "c" then
        if contains(self._punctuation_chars, nextchar) then
          self.token = self.token .. nextchar
        else
          if not contains(self.whitespace, nextchar) then
            table.insert(self._pushback_chars, nextchar)
          end
          self.state = " "
          break
        end
      elseif self.posix and contains(self.quotes, nextchar) then
        self.state = nextchar
      elseif self.posix and contains(self.escape, nextchar) then
        escapedstate = "a"
        self.state = nextchar
      elseif
        contains(self.wordchars, nextchar)
        or contains(self.quotes, nextchar)
        or (self.whitespace_split and not contains(self._punctuation_chars, nextchar))
      then
        self.token = self.token .. nextchar
      else
        if self._punctuation_chars ~= "" then
          table.insert(self._pushback_chars, nextchar)
        else
          table.insert(self.pushback, 1, nextchar)
        end
        if self.debug >= 2 then
          print("shlex: I see punctuation in word state")
        end
        self.state = " "
        if self.token ~= "" or (self.posix and quoted) then
          break
        else
          -- continue
        end
      end
    end
  end

  local result = self.token
  self.token = ""

  if self.posix and not quoted and result == "" then
    result = nil
  end

  if self.debug > 1 then
    if result then
      print("shlex: raw token=" .. ("%q"):format(result))
    else
      print("shlex: raw token=EOF")
    end
  end

  return result
end

function Shlex:sourcehook(newfile)
  -- Remove surrounding quotes
  if newfile:sub(1, 1) == '"' then
    newfile = newfile:sub(2, -2)
  end

  -- Handle relative paths (cpp-like semantics)
  if type(self.infile) == "string" and newfile:sub(1, 1) ~= "/" then
    local dir = self.infile:match("(.*/)")
    if dir then
      newfile = dir .. newfile
    end
  end

  local file = io.open(newfile, "r")
  return { newfile, file }
end

function Shlex:error_leader(infile, lineno)
  infile = infile or self.infile
  lineno = lineno or self.lineno
  return ('"%s", line %d: '):format(infile, lineno)
end

-- Iterator support
function Shlex:__call()
  local token = self:get_token()
  if token == self.eof then
    return nil
  end
  return token
end

-- Module-level functions

function M.split(s, comments, posix)
  if s == nil then
    error("s argument must not be nil")
  end

  comments = comments == nil and false or comments
  posix = posix == nil and true or posix

  local lex = Shlex.new(s, nil, posix)
  lex.whitespace_split = true

  if not comments then
    lex.commenters = ""
  end

  local result = {}
  while true do
    local token = lex:get_token()
    if token == lex.eof then
      break
    end
    table.insert(result, token)
  end

  return result
end

function M.quote(s)
  if not s or s == "" then
    return "''"
  end

  if type(s) ~= "string" then
    error(("expected string object, got %s"):format(type(s)))
  end

  -- Check if string only contains safe characters
  local safe_pattern = "^[%%+,%-./0-9:=@A-Z_a-z]*$"
  if s:match(safe_pattern) then
    return s
  end

  -- Use single quotes and escape embedded single quotes
  return "'" .. s:gsub("'", "'\"'\"'") .. "'"
end

function M.join(split_command)
  local quoted = {}
  for _, arg in ipairs(split_command) do
    table.insert(quoted, M.quote(arg))
  end
  return table.concat(quoted, " ")
end

-- Export the class and functions
M.Shlex = Shlex
return M
