-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

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

-- Toggle floating terminal with Alt+F12
map({ "n", "t" }, "<F60>", function()
  Snacks.terminal()
end, {
  desc = "Toggle terminal",
})
