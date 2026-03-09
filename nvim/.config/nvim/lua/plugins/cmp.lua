-- ============================================================
--  lua/plugins/cmp.lua — Autocompletion
--
--  nvim-cmp is the completion engine. It doesn't know WHERE to
--  get suggestions from — that's handled by "sources":
--
--    cmp-nvim-lsp  → suggestions from the active language server
--    cmp-buffer    → words already present in open buffers
--    cmp-path      → filesystem paths (when you type ~/ or ./)
--    LuaSnip       → snippet expansion
--
--  Think of nvim-cmp as the UI and engine, and sources as the
--  data providers it queries for each keystroke.
-- ============================================================

return {
  {
    "hrsh7th/nvim-cmp",

    -- Load nvim-cmp when entering insert mode for the first time.
    -- "InsertEnter" is a Neovim event that fires when you press i/a/o etc.
    event = "InsertEnter",

    dependencies = {
      "hrsh7th/cmp-nvim-lsp",   -- LSP completion source
      "hrsh7th/cmp-buffer",     -- buffer words source
      "hrsh7th/cmp-path",       -- filesystem path source
      "L3MON4D3/LuaSnip",       -- snippet engine (required for snippet completion)
      "saadparwaiz1/cmp_luasnip", -- bridge: lets nvim-cmp use LuaSnip snippets
    },

    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({

        -- ── Snippet engine ───────────────────────────────────
        -- nvim-cmp requires a snippet engine to handle snippet-type completions.
        -- We tell it to use LuaSnip for expansion.
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
            -- args.body is the snippet text sent by the LSP or snippet source.
            -- luasnip.lsp_expand() parses and activates it.
          end,
        },

        -- ── Keymaps inside the completion menu ───────────────
        mapping = cmp.mapping.preset.insert({
          -- Ctrl+Space → manually trigger completion (if it hasn't appeared yet)
          ["<C-Space>"] = cmp.mapping.complete(),

          -- Ctrl+e → close/abort the completion menu
          ["<C-e>"] = cmp.mapping.abort(),

          -- Enter → confirm the currently highlighted suggestion
          -- select = false means: don't auto-select the first item;
          -- Enter only confirms if you've explicitly moved to an item.
          ["<CR>"] = cmp.mapping.confirm({ select = false }),

          -- Tab → move to the next suggestion OR expand/jump through a snippet
          -- This is a function because we need conditional logic:
          --   if menu is visible → move down
          --   if inside a snippet → jump to next placeholder
          --   otherwise → insert a regular Tab character
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()  -- fallback() passes the key through as normal
            end
          end, { "i", "s" }),  -- active in insert ("i") and snippet ("s") modes

          -- Shift+Tab → move up through suggestions or jump backward in snippet
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)   -- -1 means: jump to previous snippet placeholder
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- ── Completion sources ────────────────────────────────
        -- Sources are checked in order. Priority is determined by
        -- the order in this list (first = highest priority) unless
        -- you set explicit `priority` values.
        sources = cmp.config.sources({
          { name = "nvim_lsp" },  -- language server suggestions (highest priority)
          { name = "luasnip" },   -- snippet completions
          { name = "buffer" },    -- words from open buffers
          { name = "path" },      -- filesystem paths
        }),

        -- ── Completion menu appearance ────────────────────────
        formatting = {
          format = function(entry, vim_item)
            -- Show the source name next to each suggestion so you know
            -- where it came from (LSP, buffer, etc.)
            vim_item.menu = ({
              nvim_lsp = "[LSP]",
              luasnip  = "[Snip]",
              buffer   = "[Buf]",
              path     = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },

      })
    end,
  },
}
