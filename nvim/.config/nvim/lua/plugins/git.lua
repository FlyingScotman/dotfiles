-- ============================================================
--  lua/plugins/git.lua — Git integration
--
--  Two complementary plugins:
--
--  vim-fugitive (tpope):
--    A full Git wrapper. Run any git command from inside Neovim.
--    :Git status, :Git log, :Git blame, :Git diff, etc.
--    Also adds Gbrowse, Gread, Gwrite for file-level operations.
--
--  gitsigns.nvim:
--    Shows git diff markers in the sign column (the thin strip
--    left of line numbers). At a glance you can see which lines
--    are added (+), changed (~), or deleted (-) vs HEAD.
--    Also provides hunk navigation and staging at the hunk level.
-- ============================================================

return {
  -- vim-fugitive needs no Lua config — its commands are available
  -- as soon as the plugin loads.
  { "tpope/vim-fugitive" },

  {
    "lewis6991/gitsigns.nvim",

    -- Load gitsigns when a file buffer is opened.
    event = { "BufReadPre", "BufNewFile" },

    config = function()
      require("gitsigns").setup({

        -- ── Sign column symbols ───────────────────────────────
        -- These are the characters shown in the gutter next to changed lines.
        signs = {
          add          = { text = "│" },  -- new line added (not in HEAD)
          change       = { text = "│" },  -- line modified compared to HEAD
          delete       = { text = "_" },  -- line deleted (shown at the deletion point)
          topdelete    = { text = "‾" },  -- deletion at the very top of the file
          changedelete = { text = "~" },  -- line was changed AND the next line deleted
        },

        -- Show blame information at the end of the current line.
        -- Tells you who last changed this line and when.
        current_line_blame = false,  -- set to true to always show; false = toggle manually

        -- ── Keymaps for hunk operations ───────────────────────
        -- on_attach runs when gitsigns attaches to a buffer (a buffer with a git file).
        -- We define hunk-level keymaps here for the same reason as LSP keymaps:
        -- they should only exist in git-tracked buffers.
        on_attach = function(bufnr)
          local gs  = package.loaded.gitsigns
          -- package.loaded is Lua's module cache — it holds already-required modules.
          -- This is equivalent to require("gitsigns") but avoids a second require call.

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          -- ]h / [h → jump to next/previous hunk (a changed section of lines)
          map("n", "]h", gs.next_hunk, "Next git hunk")
          map("n", "[h", gs.prev_hunk, "Prev git hunk")

          -- <leader>hs → stage just the current hunk (not the whole file)
          map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")

          -- <leader>hr → reset (undo) the current hunk to what HEAD has
          map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")

          -- <leader>hb → show full git blame for the current line in a popup
          map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")

          -- <leader>hd → open a diff view of the current file vs HEAD
          map("n", "<leader>hd", gs.diffthis, "Diff this file")

          -- <leader>tb → toggle the inline blame annotation on/off
          map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle line blame")
        end,

      })
    end,
  },
}
