-- ============================================================
--  lua/config/keymaps.lua — Key mappings
--
--  In Vimscript you wrote:  nnoremap <key> <action>
--  In Lua you write:        vim.keymap.set(mode, lhs, rhs, opts)
--
--  Arguments:
--    mode  → "n" normal  |  "i" insert  |  "v" visual  |  "x" visual-block
--            can also be a table of modes: {"n","v"}
--    lhs   → the key combination you press  (left-hand side)
--    rhs   → what it does                   (right-hand side)
--    opts  → a Lua table {} of options:
--              noremap = true   prevents recursive remapping (was the "nore" in nnoremap)
--              silent  = true   suppresses the command from appearing in the cmdline
--              expr    = true   evaluates rhs as an expression (for <expr> mappings)
--              desc    = "..."  human-readable description (shows in which-key etc.)
--
--  noremap = true is the default when you use vim.keymap.set(), so you don't
--  need to write it explicitly — it's already safe from recursive remapping.
-- ============================================================

-- Convenience alias
local map = vim.keymap.set

-- ── Leader key ───────────────────────────────────────────────
-- The leader key must be set BEFORE any mappings that use <leader>,
-- otherwise those mappings bind to the old leader (backslash by default).
-- vim.g is the global variable table — equivalent to `let g:mapleader = " "`
vim.g.mapleader = " "   -- Spacebar as leader key

-- ── Insert mode escape ───────────────────────────────────────
-- Type "jk" quickly in insert mode to return to normal mode.
-- Much faster than reaching for the physical Escape key.
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- ── Smart j/k movement ───────────────────────────────────────
-- The <expr> option means the rhs is evaluated as a Lua expression each
-- time the key is pressed, rather than being a fixed string.
--
-- vim.v.count is a Neovim variable that holds how many times you prefixed
-- the motion — e.g. pressing "5j" sets vim.v.count to 5.
--
-- Logic:
--   if you pressed a number prefix (count > 0) → use regular `j`/`k`
--     because "5j" should jump exactly 5 real lines (useful with relativenumber)
--   otherwise (no prefix) → use `gj`/`gk`
--     which moves through *visual* lines, so wrapped long lines feel natural
map("n", "j", function()
  return vim.v.count > 0 and "j" or "gj"
end, { expr = true, desc = "Down (smart wrap)" })

map("n", "k", function()
  return vim.v.count > 0 and "k" or "gk"
end, { expr = true, desc = "Up (smart wrap)" })

-- ── Centred search navigation ────────────────────────────────
-- After jumping to the next/prev search result, `zz` recentres the screen
-- so the match is in the middle of the window — easier on the eyes.
-- The string "nzz" means: do `n` (next match), then `zz` (centre screen).
map("n", "n", "nzz", { desc = "Next match (centred)" })
map("n", "N", "Nzz", { desc = "Prev match (centred)" })

-- ── Consistent Y behaviour ───────────────────────────────────
-- By default `Y` yanks the whole line (same as `yy`), which is inconsistent
-- with `D` (delete to end of line) and `C` (change to end of line).
-- This remaps Y to `y$` — yank from cursor to end of line.
map("n", "Y", "y$", { desc = "Yank to end of line" })

-- ── Window navigation ────────────────────────────────────────
-- Ctrl+h/j/k/l jumps between splits without the extra <C-w> prefix.
-- <C-w>h is the built-in: "window → move left". We're just shortening it.
map("n", "<C-h>", "<C-w>h", { desc = "Move to left split" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to split below" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to split above" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right split" })

-- ── Clear search highlight ────────────────────────────────────
-- After a search, Neovim keeps the matches highlighted.
-- Pressing Escape in normal mode clears them with :noh (no highlight).
-- <CR> is the Enter key — required to execute the : command.
map("n", "<Esc>", ":noh<CR>", { silent = true, desc = "Clear search highlight" })

-- ── VSCode detection (preserved from your init.vim) ──────────
-- vim.g.vscode is set to 1 when running inside the VSCode Neovim extension.
-- You can gate VSCode-specific mappings inside this if block.
if vim.g.vscode then
  -- VSCode-specific mappings would go here
else
  -- Pure Neovim mappings would go here
  -- (most of the above already apply only in pure Neovim contexts)
end
