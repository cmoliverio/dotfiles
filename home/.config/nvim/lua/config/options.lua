-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.guicursor = ""
vim.opt.clipboard = "unnamedplus"

-- Never silently replace an open buffer when another editor or process
-- changes its file.  `checktime` in autocmds.lua will surface Neovim's prompt.
vim.opt.autoread = false
