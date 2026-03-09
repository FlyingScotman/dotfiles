-- ============================================================
--  init.lua — Neovim entry point
--  This file is the first thing Neovim loads. Its only job is
--  to pull in the other modules we've organized in lua/.
--
--  require("config.options")  → tells Lua to load lua/config/options.lua
--  require("config.keymaps")  → tells Lua to load lua/config/keymaps.lua
--  require("config.lazy")     → tells Lua to load lua/config/lazy.lua
--                               (this bootstraps the plugin manager)
--
--  The string passed to require() maps to a file path:
--    "config.options"  →  lua/config/options.lua
--    dots become slashes in the path
-- ============================================================

require("config.options")   -- editor settings (numbers, tabs, clipboard, etc.)
require("config.keymaps")   -- all key mappings
require("config.lazy")      -- plugin manager bootstrap + plugin loading
