-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Keep Windows Terminal's configured cursor shape. Some plugins temporarily
-- change 'guicursor', which otherwise leaves a different shape behind.
vim.api.nvim_create_autocmd("OptionSet", {
  pattern = "guicursor",
  callback = function()
    vim.cmd("noautocmd set guicursor=")
  end,
  desc = "Preserve the terminal cursor shape",
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
