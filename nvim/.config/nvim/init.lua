-- Neovim 0.11+ configuration entry point.

vim.loader.enable()

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = false

vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_kite = 1
vim.g.gite_supported_languages = {}

-- Machine-specific settings live in an ignored file. The module is optional.
pcall(require, "config.local")

local offline_values = { ["1"] = true, ["true"] = true, ["yes"] = true, ["on"] = true }
local offline_env = (vim.env.NVIM_OFFLINE or ""):lower()
vim.g.neovim_offline = vim.g.neovim_offline == true or offline_values[offline_env] == true

-- Keep Neovim's non-interactive shell fast on Windows. ToggleTerm can use a
-- separate shell configured in local.lua.
if vim.fn.has("win32") == 1 then
  vim.opt.shell = "cmd.exe"
  vim.opt.shellcmdflag = "/c"
  vim.opt.shellquote = ""
  vim.opt.shellxquote = ""
end

vim.opt.foldenable = true
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99

require("config.options")
require("config.lazy")
require("config.plugins")
require("config.keymaps")
require("config.lsp")
require("config.autocmds")
