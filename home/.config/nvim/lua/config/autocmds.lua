-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Remove carriage returns from text pasted from Windows clipboards.
local default_paste = vim.paste

vim.paste = function(lines, phase)
  for index, line in ipairs(lines) do
    lines[index] = line:gsub("\r", "")
  end
  return default_paste(lines, phase)
end

-- Keep comments in the cool blue-gray palette, including while Vimade fades
-- inactive windows. The colorscheme's default comment color is too warm once
-- Vimade applies its foreground tint.
local function set_comment_highlights()
  local comment = { fg = "#59677d", italic = true }
  vim.api.nvim_set_hl(0, "Comment", comment)
  vim.api.nvim_set_hl(0, "@comment", comment)
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_comment_highlights,
  desc = "Keep comments cool blue-gray",
})
set_comment_highlights()

-- Keep Windows Terminal's configured cursor shape. Some plugins temporarily
-- change 'guicursor', which otherwise leaves a different shape behind.
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "guicursor",
  callback = function()
    vim.cmd("noautocmd set guicursor=")
  end,
  desc = "Preserve the terminal cursor shape",
})

-- Override LazyVim's Snacks picker mapping for definitions.  Calling the LSP
-- method directly keeps `gd` from opening a picker when no definition exists.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
      buffer = event.buf,
      desc = "Goto Definition",
    })
  end,
  desc = "Use LSP directly for go-to-definition",
})

local function copy_buffer_value(value, label)
  if value == "" then
    vim.notify("Current buffer has no filename", vim.log.levels.WARN)
    return
  end

  vim.fn.setreg("+", value)
  vim.notify(label .. " copied: " .. value)
end

vim.api.nvim_create_user_command("FilePath", function()
  copy_buffer_value(vim.fn.expand("%:p"), "File path")
end, {
  desc = "Copy the current file's absolute path",
})

vim.api.nvim_create_user_command("FileName", function()
  copy_buffer_value(vim.fn.expand("%:t"), "File name")
end, {
  desc = "Copy the current file's name",
})
