-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Make Ctrl+Delete delete the previous word in insert mode, like most editors.
map("i", "<C-Delete>", "<C-w>", {
  desc = "Delete previous word",
})

-- Press Escape to leave terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], {
  desc = "Exit terminal mode",
})

-- Comment/uncomment current line
map("n", "<C-/>", "gcc", {
  remap = true,
  desc = "Comment line",
})

-- Comment/uncomment selected lines
map("v", "<C-/>", "gc", {
  remap = true,
  desc = "Comment selection",
})

-- Some terminals send Ctrl+/ as Ctrl+_
map("n", "<C-_>", "gcc", {
  remap = true,
  desc = "Comment line",
})

map("v", "<C-_>", "gc", {
  remap = true,
  desc = "Comment selection",
})

-- Prefer an exact LSP definition, then fall back to tags or workspace grep.
map("n", "gd", function()
  require("config.goto_definition").goto_definition()
end, {
  desc = "Goto Definition (LSP, tags, or grep)",
})

-- Toggle floating terminal with Alt+F12
map({ "n", "t" }, "<F60>", function()
  Snacks.terminal()
end, {
  desc = "Toggle terminal",
})
