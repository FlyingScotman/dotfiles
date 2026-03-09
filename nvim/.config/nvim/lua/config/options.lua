-- ============================================================
--  lua/config/options.lua — Editor settings
--
--  In Vimscript you wrote:  set number
--  In Lua you write:        vim.opt.number = true
--
--  `vim` is a global table that Neovim injects into every Lua
--  file. It gives you access to everything Neovim exposes:
--    vim.opt   → editor options  (replaces `set`)
--    vim.g     → global variables (replaces `let g:`)
--    vim.api   → Neovim API functions
--    vim.cmd   → runs a raw Vimscript command
--    vim.fn    → calls Vimscript functions
--
--  vim.opt returns an "option object". You set it with = and
--  you can also use :append(), :remove(), :prepend() on list
--  options. For most simple options, just use = true / false
--  or = some_value.
-- ============================================================

local opt = vim.opt  -- local alias so we can write `opt.x` instead of `vim.opt.x`
                     -- `local` means the variable only exists in this file

-- ── Line numbers ─────────────────────────────────────────────
opt.number         = true   -- show the absolute line number on the current line
opt.relativenumber = true   -- show relative numbers on every other line
                             -- together these give you the "hybrid" number mode
                             -- you had with `set number relativenumber`

-- ── Search behaviour ─────────────────────────────────────────
opt.ignorecase = true   -- searches are case-insensitive by default
opt.smartcase  = true   -- BUT if you type any capital letter, become case-sensitive
                         -- so /hello matches Hello, but /Hello only matches Hello
opt.incsearch  = true   -- highlight matches as you type the search pattern
                         -- (this is on by default in Neovim but explicit is fine)

-- ── Clipboard ────────────────────────────────────────────────
opt.clipboard = "unnamedplus"  -- yank/paste uses the system clipboard automatically
                                -- "unnamedplus" is the + register, which is the
                                -- X11/Wayland primary clipboard on Linux, and the
                                -- normal clipboard on macOS/Windows

-- ── Scrolling ────────────────────────────────────────────────
opt.scrolloff = 8   -- always keep at least 8 lines visible above and below the
                     -- cursor. When you get near the bottom, the buffer scrolls
                     -- so the cursor never sits right at the edge.

-- ── Indentation ──────────────────────────────────────────────
opt.expandtab   = true  -- pressing Tab inserts spaces, not a real tab character
opt.tabstop     = 2     -- a real tab character (if one exists) displays as 2 spaces
opt.shiftwidth  = 2     -- >> and << indent/dedent by 2 spaces
opt.softtabstop = 2     -- Tab key in insert mode moves 2 spaces (matches shiftwidth)
                         -- having all three set to the same value keeps behaviour
                         -- consistent and predictable
