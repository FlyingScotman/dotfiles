-- =============================================================================
-- lua/config/options.lua — All vim.opt settings
-- =============================================================================
-- Diagnostics are configured in lsp.lua (their natural home).
-- =============================================================================

local opt = vim.opt

-- ── Line Numbers ──
opt.number = true
opt.relativenumber = true

-- ── Tabs and Indentation ──
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- ── Search ──
-- CHANGE: hlsearch set to true (was false).
-- With hlsearch=false the <Esc> → nohlsearch mapping did nothing.
-- Now: matches highlight while searching, <Esc> clears them.
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- ── Display ──
opt.termguicolors = true
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.colorcolumn = "88"
opt.wrap = false
opt.cursorline = true
opt.breakindent = true
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.inccommand = "split"         -- Live preview of :s substitutions

-- ── Confirm ──
opt.confirm = true

-- ── File Handling ──
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undodir"

-- ── Splits ──
opt.splitright = true
opt.splitbelow = true

-- ── Clipboard ──
-- CHANGE: removed global unnamedplus clipboard sync.
-- Previously every yank went to system clipboard automatically, making the
-- explicit <leader>y mapping redundant and polluting the system clipboard
-- with every delete/change. Now:
--   default yank/delete → unnamed register (internal)
--   <leader>y           → system clipboard (intentional)
--   <leader>p           → paste without overwriting register
-- This is the more common "power user" approach.

-- ── Performance ──
-- CHANGE: updatetime bumped from 250 to 400.
-- 250ms was aggressive for CursorHold events (LSP doc highlights, etc.)
-- on Windows where each event can be costly. 400 is still responsive.
opt.updatetime = 400
opt.timeoutlen = 300

-- ── Completion ──
opt.completeopt = { "menuone", "noselect" }

-- ── Encoding ──
opt.fileencoding = "utf-8"

-- ── Mouse ──
opt.mouse = "a"
