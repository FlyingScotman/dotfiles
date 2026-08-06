local offline = vim.g.neovim_offline == true
local data_dir = vim.fn.stdpath("data")
local manual_root = data_dir .. "/site/pack/manual"
local lazy_path

if offline then
  lazy_path = manual_root .. "/start/lazy.nvim"
else
  lazy_path = data_dir .. "/lazy/lazy.nvim"
  if not vim.uv.fs_stat(lazy_path) then
    local result = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=stable",
      "https://github.com/folke/lazy.nvim.git",
      lazy_path,
    })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to install lazy.nvim:\n", "ErrorMsg" },
        { result, "WarningMsg" },
      }, true, {})
      return
    end
  end
end

if not vim.uv.fs_stat(lazy_path) then
  vim.schedule(function()
    vim.notify(
      "Offline mode: lazy.nvim is missing at " .. lazy_path,
      vim.log.levels.ERROR
    )
  end)
  return
end

vim.opt.rtp:prepend(lazy_path)

local missing = {}
local treesitter_build = nil
if not offline then
  treesitter_build = ":TSUpdate"
end

local function manual_dir(name)
  for _, kind in ipairs({ "opt", "start" }) do
    local path = string.format("%s/%s/%s", manual_root, kind, name)
    if vim.uv.fs_stat(path) then
      return path
    end
  end
end

local function plugin(repo, opts)
  opts = opts or {}
  local name = opts.name or repo:match("/([^/]+)$")
  local spec = vim.tbl_deep_extend("force", { repo }, opts)

  if offline then
    local dir = manual_dir(name)
    if dir then
      spec.dir = dir
    else
      spec.enabled = false
      missing[#missing + 1] = name
    end
  end

  return spec
end

local specs = {
  plugin("catppuccin/nvim", { name = "catppuccin", priority = 1000 }),
  plugin("nvim-lualine/lualine.nvim"),
  plugin("nvim-tree/nvim-web-devicons"),
  plugin("nvim-lua/plenary.nvim"),
  plugin("nvim-telescope/telescope.nvim"),
  plugin("nvim-treesitter/nvim-treesitter", {
    branch = "master",
    build = treesitter_build,
  }),
  plugin("hrsh7th/nvim-cmp"),
  plugin("hrsh7th/cmp-nvim-lsp"),
  plugin("hrsh7th/cmp-buffer"),
  plugin("hrsh7th/cmp-path"),
  plugin("saadparwaiz1/cmp_luasnip"),
  plugin("L3MON4D3/LuaSnip"),
  plugin("lewis6991/gitsigns.nvim"),
  plugin("numToStr/Comment.nvim"),
  plugin("windwp/nvim-autopairs"),
  plugin("folke/which-key.nvim"),
  plugin("ggandor/leap.nvim"),
  plugin("akinsho/toggleterm.nvim"),
  plugin("folke/todo-comments.nvim"),
  plugin("stevearc/conform.nvim"),
  plugin("NMAC427/guess-indent.nvim"),
  plugin("ray-x/lsp_signature.nvim"),
  plugin("neovim/nvim-lspconfig"),
  plugin("mfussenegger/nvim-dap"),
  plugin("mfussenegger/nvim-dap-python"),
  plugin("rcarriga/nvim-dap-ui"),
  plugin("nvim-neotest/nvim-nio"),
  plugin("Vigemus/iron.nvim"),
  plugin("ThePrimeagen/harpoon", { branch = "master" }),
  plugin("mbbill/undotree"),
  plugin("tpope/vim-fugitive"),
  plugin("kylechui/nvim-surround"),
}

local ok, lazy = pcall(require, "lazy")
if not ok then
  vim.schedule(function()
    vim.notify("Unable to load lazy.nvim", vim.log.levels.ERROR)
  end)
  return
end

lazy.setup(specs, {
  defaults = { lazy = false },
  install = { missing = not offline, colorscheme = { "catppuccin" } },
  checker = { enabled = not offline },
  change_detection = { enabled = not offline, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

if offline and #missing > 0 then
  vim.schedule(function()
    vim.notify(
      "Offline mode: missing plugin directories:\n- " .. table.concat(missing, "\n- "),
      vim.log.levels.WARN
    )
  end)
end
