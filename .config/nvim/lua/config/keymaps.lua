-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Cmd+Shift+K -> open Lazygit via Snacks
-- iTerm2 must be configured to send the escape sequence <Esc>[108~ for Cmd+Shift+K:
--   Settings -> Profiles -> Keys -> Key Mappings -> + -> press Cmd+Shift+K
--   Action: "Send Escape Sequence", Esc+: [108~
vim.keymap.set("n", "<Esc>[108~", function() Snacks.lazygit() end, { desc = "Open Lazygit" })
vim.keymap.set("t", "<Esc>[108~", function() Snacks.lazygit() end, { desc = "Open Lazygit" })

-- -- Also map <D-S-k> for Neovide / GUI Neovim where Cmd is delivered natively
-- vim.keymap.set("n", "<D-S-k>", function() Snacks.lazygit() end, { desc = "Open Lazygit" })
-- vim.keymap.set("t", "<D-S-k>", function() Snacks.lazygit() end, { desc = "Open Lazygit" })
