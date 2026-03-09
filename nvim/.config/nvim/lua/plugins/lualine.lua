-- ============================================================
--  lua/plugins/lualine.lua — Statusline
--
--  lualine replaces Neovim's default statusline with a clean,
--  configurable, fast statusline written in Lua.
--
--  The statusline is the bar at the bottom of each window showing
--  info like: current mode, filename, git branch, diagnostics,
--  file type, cursor position, etc.
-- ============================================================

return {
  {
    "nvim-lualine/lualine.nvim",

    -- Load immediately at startup — the statusline should always be visible.
    -- (No lazy loading here; event = "VimEnter" would also work.)
    lazy = false,

    config = function()
      require("lualine").setup({

        options = {
          -- theme controls the colours of the statusline.
          -- "auto" adapts to whatever colorscheme you're using.
          -- Other options: "gruvbox", "tokyonight", "catppuccin", etc.
          theme = "auto",

          -- component_separators: the thin separator between items
          -- within a section. Using Powerline-style glyphs looks nice
          -- but requires a Nerd Font. If you don't have one, use "|" and "".
          component_separators = { left = "", right = "" },

          -- section_separators: the thick separator between sections.
          -- Set both to "" for a flat look without special characters.
          section_separators   = { left = "", right = "" },
        },

        -- The statusline is split into sections: a, b, c on the left;
        -- x, y, z on the right.
        --
        --   [a][b][c]                    [x][y][z]
        --   mode | branch | filename     filetype | progress | location
        sections = {
          lualine_a = { "mode" },          -- current mode (NORMAL, INSERT, VISUAL...)
          lualine_b = { "branch", "diff" },-- git branch name + +/-/~ change counts
          lualine_c = {
            {
              "filename",
              path = 1,  -- 0 = just filename, 1 = relative path, 2 = absolute path
            },
            "diagnostics",  -- shows error/warning/hint counts from LSP
          },
          lualine_x = { "filetype" },      -- e.g. "python", "lua", "markdown"
          lualine_y = { "progress" },      -- percentage through file (e.g. "42%")
          lualine_z = { "location" },      -- line:column (e.g. "24:7")
        },

      })
    end,
  },
}
