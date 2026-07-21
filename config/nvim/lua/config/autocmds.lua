-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Wrap only in prose buffers.
--
-- LazyVim's `wrap_spell` autocmd covers markdown/text/etc, but it never fires for
-- buffers with no detected filetype (agent prompt scratch files are often extensionless),
-- and it never turns wrap back *off* if a buffer's filetype later changes. Replace it.
pcall(vim.api.nvim_del_augroup_by_name, "lazyvim_wrap_spell")

local prose = {
  [""] = true, -- no filetype detected (extensionless scratch/prompt files)
  gitcommit = true,
  markdown = true,
  plaintex = true,
  text = true,
  typst = true,
}

vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("wrap_prose", { clear = true }),
  callback = function(ev)
    -- only touch normal file buffers, leave help/quickfix/terminal alone
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local ft = vim.bo[ev.buf].filetype
    local is_prose = prose[ft] or false
    vim.opt_local.wrap = is_prose
    vim.opt_local.linebreak = is_prose
    vim.opt_local.breakindent = is_prose
    -- spell only for real prose filetypes; extensionless files are too often not prose
    vim.opt_local.spell = is_prose and ft ~= ""
  end,
})
