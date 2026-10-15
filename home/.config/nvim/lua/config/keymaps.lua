-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- Scroll the window and move the cursor by one line.
map("n", "<C-e>", "<C-e>j", {
  desc = "Scroll down and move cursor",
})

map("n", "<C-y>", "<C-y>k", {
  desc = "Scroll up and move cursor",
})

-- Make Ctrl+Delete delete the previous word in insert mode, like most editors.
map("i", "<C-Delete>", "<C-w>", {
  desc = "Delete previous word",
})

-- Press Escape to leave terminal mode
map("t", "<Esc>", [[<C-\><C-n>]], {
  desc = "Exit terminal mode",
})

-- Hold Ctrl+Shift+Arrow to continuously resize the active split.
-- LazyVim binds the Ctrl+Arrow variants by default; reserve resizing for the
-- Shift-modified keys instead.
for _, key in ipairs({ "<C-Left>", "<C-Right>", "<C-Up>", "<C-Down>" }) do
  pcall(vim.keymap.del, "n", key)
end

map("n", "<C-S-Left>", "<cmd>vertical resize -2<cr>", {
  desc = "Shrink split width",
})
map("n", "<C-S-Right>", "<cmd>vertical resize +2<cr>", {
  desc = "Grow split width",
})
map("n", "<C-S-Up>", "<cmd>resize +2<cr>", {
  desc = "Grow split height",
})
map("n", "<C-S-Down>", "<cmd>resize -2<cr>", {
  desc = "Shrink split height",
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

-- Reserve s for surround commands without invoking Vim's substitute command.
map({ "n", "x" }, "s", "<Nop>", {
  desc = "Surround prefix",
})

-- Toggle floating terminal with Alt+F12
map({ "n", "t" }, "<F60>", function()
  Snacks.terminal()
end, {
  desc = "Toggle terminal",
})
