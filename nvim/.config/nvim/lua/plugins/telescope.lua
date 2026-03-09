-- ============================================================
--  lua/plugins/telescope.lua — Fuzzy Finder
--
--  Telescope is a highly interactive fuzzy finder. You type a
--  few characters and it instantly filters through files, text,
--  LSP symbols, git history, keymaps, etc.
--
--  The UI has three panels:
--    [prompt]   → where you type your search query
--    [results]  → filtered list of matches, updates in real time
--    [preview]  → shows a preview of the currently selected item
-- ============================================================

return {
  {
    "nvim-telescope/telescope.nvim",

    -- Load Telescope lazily — only when one of these commands is called.
    -- cmd = {...} means: load this plugin the first time any of these
    -- Vimscript commands are executed.
    cmd = "Telescope",

    -- dependencies: plugins that must be loaded BEFORE this one.
    -- Telescope requires plenary for its async utilities.
    dependencies = { "nvim-lua/plenary.nvim" },

    config = function()
      local telescope = require("telescope")
      local builtin   = require("telescope.builtin")
      -- `builtin` is the collection of built-in telescope pickers
      -- (file finder, grep, LSP, git, etc.)

      telescope.setup({
        defaults = {
          -- How results are sorted. "smart" prioritises frecency (frequency + recency).
          sorting_strategy = "ascending",

          -- Where the prompt (search box) appears.
          -- "top" puts it above the results list.
          layout_config = {
            prompt_position = "top",
          },

          -- Key mappings inside the Telescope popup.
          -- These only apply while Telescope is open.
          mappings = {
            i = {  -- insert mode (while typing in the prompt)
              -- Ctrl+j/k to move up and down the results list
              -- without leaving the prompt
              ["<C-j>"] = "move_selection_next",
              ["<C-k>"] = "move_selection_previous",

              -- Escape closes Telescope when in insert mode
              -- (default is to switch to normal mode first)
              ["<Esc>"] = "close",
            },
          },
        },
      })

      -- ── Keymaps to launch Telescope pickers ────────────────
      -- <leader>ff → "find files": fuzzy-search all files in the project
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: Find files" })

      -- <leader>fg → "find grep": search for text inside all files (ripgrep)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: Live grep" })

      -- <leader>fb → "find buffers": switch between open buffers
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: Buffers" })

      -- <leader>fh → "find help": search Neovim's :help documentation
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: Help tags" })

      -- <leader>fr → "find recent": recently opened files
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Telescope: Recent files" })

      -- <leader>fs → "find symbols": LSP symbols in current file
      vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Telescope: LSP symbols" })
    end,
  },
}
