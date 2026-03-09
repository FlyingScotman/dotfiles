-- ============================================================
--  lua/plugins/treesitter.lua
--
--  Treesitter parses your source code into a concrete syntax tree
--  in real time. This enables accurate syntax highlighting,
--  smarter indentation, and lets other plugins understand code
--  structure (rather than relying on fragile regex patterns).
--
--  WHY lazy = false HERE:
--  We previously used event = { "BufReadPre", "BufNewFile" } to
--  lazy-load this plugin. That caused a race condition:
--    1. You open a file → BufReadPre fires → lazy.nvim starts loading
--       treesitter → BUT treesitter's parsers need to be compiled first
--       (the build = ":TSUpdate" step) → config function runs before
--       build finishes → "module 'nvim-treesitter.configs' not found"
--
--  The fix: lazy = false loads treesitter at startup, before any
--  file is opened, so the build step and module loading are complete
--  by the time you open your first buffer.
--  Treesitter is lightweight enough that eager loading is fine.
-- ============================================================

return {
  {
    "nvim-treesitter/nvim-treesitter",

    -- lazy = false: load this plugin at startup, not on-demand.
    -- This prevents the race condition between build and config described above.
    lazy = false,

    -- build: runs a command after the plugin is installed OR updated.
    -- ":TSUpdate" is a Treesitter command that downloads and compiles
    -- parser binaries for each language in ensure_installed.
    -- Parsers are written in C and compiled locally for your CPU —
    -- that's why this extra step exists (unlike pure-Lua plugins).
    build = ":TSUpdate",

    -- config: the function that runs after the plugin is loaded.
    -- This is where we call the plugin's own setup() with our options.
    config = function()

      -- require("nvim-treesitter.configs") loads the configuration module
      -- that ships inside the treesitter plugin itself.
      
      -- This line is inserted by Claude
      local ok, configs = pcall(require, "nvim-treesitter.configs")
      if not ok then return end


      configs.setup({

        -- ensure_installed: language parsers to automatically install.
        -- These are downloaded and compiled on first launch.
        -- "all" would install every available parser (~100 languages),
        -- but listing them explicitly keeps things lean.
        ensure_installed = {
          "python",    -- the main language you're working in
          "lua",       -- for editing your Neovim config
          "bash",      -- shell scripts
          "vim",       -- vimscript files
          "vimdoc",    -- :help documentation pages
          "markdown",  -- README files, notes
          "json",      -- config files, API responses
          "toml",      -- pyproject.toml, Cargo.toml etc.
          "yaml",      -- docker-compose, GitHub Actions etc.
        },

        -- auto_install: if you open a file whose parser isn't installed
        -- yet, treesitter will install it automatically in the background.
        auto_install = true,

        -- highlight.enable: replace Neovim's default regex-based syntax
        -- highlighting with treesitter's parse-tree-based highlighting.
        -- Treesitter understands nesting, scope, and context. For Python
        -- this means f-strings, decorators, and nested comprehensions all
        -- highlight correctly — regex-based highlighting often gets these wrong.
        highlight = {
          enable = true,

          -- additional_vim_regex_highlighting: run the OLD regex highlighting
          -- in addition to treesitter. Usually set to false because mixing
          -- both systems can cause colours to fight each other. Set to
          -- { "python" } only if you notice specific highlighting gaps.
          additional_vim_regex_highlighting = false,
        },

        -- indent.enable: use treesitter to handle the `=` indentation operator.
        -- `=` in normal mode re-indents a selection. With this on, it uses
        -- treesitter's understanding of the code structure instead of Neovim's
        -- built-in indentation rules (which are regex-based and less accurate).
        indent = {
          enable = true,
        },

      })
    end,
  },
}
