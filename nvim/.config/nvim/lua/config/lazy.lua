-- ============================================================
--  lua/config/lazy.lua — Plugin manager bootstrap
--
--  We're replacing vim-plug with lazy.nvim.
--  lazy.nvim is the modern standard for Neovim plugin management.
--  It supports:
--    - lazy loading (plugins load only when needed → faster startup)
--    - automatic installation on first launch
--    - lockfile for reproducible plugin versions
--    - a nice UI (:Lazy) to update/manage plugins
--
--  HOW THE BOOTSTRAP WORKS:
--  lazy.nvim is itself a plugin, so we need to install it before we
--  can use it to install other plugins. The block below does this:
--    1. Figures out where lazy.nvim should live on disk (lazypath)
--    2. Checks if it's already installed (vim.loop.fs_stat)
--    3. If not, clones it from GitHub with `git clone`
--    4. Adds it to Neovim's runtime path so `require("lazy")` works
-- ============================================================

-- vim.fn.stdpath("data") returns Neovim's data directory:
--   Linux/macOS: ~/.local/share/nvim
--   Windows:     ~/AppData/Local/nvim-data
-- We'll store lazy.nvim inside that directory.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
--   `..` is Lua's string concatenation operator (like + in Python for strings)
--   result: ~/.local/share/nvim/lazy/lazy.nvim

-- Check if lazy.nvim is already installed by testing if that path exists.
-- vim.loop is LuaJIT's libuv bindings (async I/O). fs_stat() is like `stat()`
-- in C — it returns file metadata, or nil if the path doesn't exist.
if not vim.loop.fs_stat(lazypath) then
  -- Not installed yet — clone it from GitHub.
  -- vim.fn.system() runs a shell command and returns its output as a string.
  -- The argument is a Lua table (list) of the command + its arguments.
  -- This is safer than a raw string because it avoids shell injection.
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",       -- shallow clone: don't download file contents yet
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",          -- use the stable release branch
    lazypath,                   -- destination directory
  })
end

-- Add lazy.nvim to the runtime path so Lua's require() can find it.
-- vim.opt.rtp is the runtimepath option (the list of directories Neovim
-- searches for scripts, plugins, etc.)
-- :prepend() adds lazypath to the FRONT of that list so it's found first.
vim.opt.rtp:prepend(lazypath)

-- ============================================================
--  Plugin specification
--
--  require("lazy").setup({...}) initialises lazy.nvim and passes
--  it the list of plugins to manage. Each plugin entry can be:
--
--    "author/repo"                    → just install, no config
--    { "author/repo", ... }           → install with options
--    { import = "plugins.filename" }  → load from a separate file
--                                       in lua/plugins/filename.lua
--
--  The { import = ... } pattern is the recommended way to keep
--  things organised — each file in lua/plugins/ handles one plugin
--  or a logical group of plugins.
-- ============================================================

require("lazy").setup({

  -- ── Tpope essentials ───────────────────────────────────────
  -- These are simple plugins with no Lua config needed — just install.

  { "tpope/vim-surround" },
  -- Adds motions to add/change/delete surrounding characters.
  -- cs"'  → change surrounding " to '
  -- ds(   → delete surrounding ()
  -- ysiw" → surround current word with "

  { "tpope/vim-commentary" },
  -- gcc  → toggle comment on current line
  -- gc   → toggle comment on selected lines (visual mode)

  { "tpope/vim-repeat" },
  -- Makes the . (repeat last action) command work with plugin actions.
  -- Without this, . can't repeat surround or commentary operations.

  { "wellle/targets.vim" },
  -- Adds extra text objects. Examples:
  -- cin(  → change inside next ()  (even if cursor isn't inside it yet)
  -- da,   → delete an argument in a function call

  { "justinmk/vim-sneak" },
  -- s{char}{char} → jump to the next occurrence of two characters
  -- Faster than / search for short jumps. ; and , repeat forward/backward.

  -- ── Plenary (required by Telescope) ────────────────────────
  { "nvim-lua/plenary.nvim", lazy = true },
  -- plenary.nvim is a utility library that other plugins depend on.
  -- It's not a plugin you interact with directly.
  -- lazy = true means: don't load it at startup; load it when something needs it.

  -- ── LSP, Treesitter, Telescope, CMP, Git ───────────────────
  -- These plugins need real configuration, so we delegate each one
  -- to a separate file inside lua/plugins/.
  -- { import = "plugins.X" } tells lazy.nvim:
  --   "go read lua/plugins/X.lua and use whatever specs are returned there"

  { import = "plugins.treesitter" },  -- syntax highlighting & code understanding
  { import = "plugins.lsp" },         -- language server protocol (code intelligence)
  { import = "plugins.telescope" },   -- fuzzy finder
  { import = "plugins.cmp" },         -- autocompletion
  { import = "plugins.lualine" },     -- statusline
  { import = "plugins.git" },         -- git signs + fugitive
  { import = "plugins.dap" },         -- debugger

}, {
  -- ── lazy.nvim UI options ────────────────────────────────────
  -- This second table argument configures lazy.nvim itself (not the plugins).
  ui = {
    border = "rounded",  -- rounded borders on the :Lazy popup window
  },
  checker = {
    enabled = true,      -- automatically check for plugin updates in the background
    notify  = false,     -- but don't show a notification every time (check with :Lazy)
  },
})
