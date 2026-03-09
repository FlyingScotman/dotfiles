-- ============================================================
--  lua/plugins/lsp.lua — Language Server Protocol (Neovim 0.11+)
--
--  Neovim 0.11 introduced a BUILT-IN LSP configuration system.
--  You no longer need `require('lspconfig').X.setup()` — Neovim
--  can configure and start language servers natively.
--
--  The new API:
--    vim.lsp.config("server_name", { ...settings... })
--      → defines HOW to configure a server (capabilities, settings)
--      → equivalent to the old lspconfig.X.setup({})
--
--    vim.lsp.enable("server_name")
--      → tells Neovim to actually START that server when relevant
--        filetypes are opened
--
--  We still keep nvim-lspconfig as a dependency because it ships
--  the server *definitions* (what command to run, what filetypes
--  trigger it, default root detection). Without lspconfig installed,
--  Neovim wouldn't know e.g. that "pyright" is started with the
--  command `pyright-langserver --stdio` for *.py files.
--  We just no longer call require('lspconfig') ourselves.
--
--  We also add Mason — a package manager that installs LSP servers,
--  linters, and formatters from inside Neovim automatically.
-- ============================================================

return {

  -- ── Mason: automatic server installation ───────────────────
  {
    "williamboman/mason.nvim",

    -- lazy = false: load at startup, not lazily.
    -- Mason needs to be ready before LSP servers are started.
    lazy = false,

    config = function()
      require("mason").setup({
        ui = {
          border = "rounded",
          icons = {
            package_installed   = "✓",  -- server is installed and ready
            package_pending     = "➜",  -- currently installing
            package_uninstalled = "✗",  -- not yet installed
          },
        },
      })
    end,
  },

  -- ── Mason-lspconfig: bridge between Mason and Neovim LSP ───
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,

    -- dependencies tells lazy.nvim: load these plugins FIRST.
    -- mason-lspconfig needs mason already set up to find installed servers.
    dependencies = { "williamboman/mason.nvim" },

    config = function()
      require("mason-lspconfig").setup({

        -- ensure_installed: Mason will automatically install these
        -- language servers if they are not already present.
        -- No more manual `npm install -g pyright`.
        ensure_installed = {
          "pyright",    -- Python: type checking, completion, go-to-def
          "lua_ls",     -- Lua: for editing your Neovim config files
        },

        -- automatic_installation: if you open a file whose language
        -- has a known server not yet installed, Mason installs it.
        automatic_installation = true,
      })
    end,
  },

  -- ── nvim-lspconfig: server definitions ─────────────────────
  {
    "neovim/nvim-lspconfig",

    -- Load when a file buffer is opened (not at startup)
    event = { "BufReadPre", "BufNewFile" },

    -- Must load after mason-lspconfig so servers are installed
    -- before we try to enable them.
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },

    config = function()

      -- ── LSP keymaps via LspAttach autocmd ──────────────────
      --
      -- vim.api.nvim_create_autocmd(event, opts) registers a function
      -- to run whenever a specific event fires inside Neovim.
      --
      -- "LspAttach" is an event that fires every time an LSP server
      -- successfully connects to a buffer. We use it to define keymaps
      -- that should only exist in LSP-active buffers.
      --
      -- This replaces the old `on_attach` function pattern. Instead of
      -- threading on_attach through every server's setup(), we register
      -- one autocmd and it fires for ALL servers automatically.
      vim.api.nvim_create_autocmd("LspAttach", {

        -- augroup: a named group for this autocmd.
        -- nvim_create_augroup() creates or retrieves the group.
        -- { clear = true } removes any previously registered autocmds
        -- in this group before adding new ones — prevents duplicates
        -- if your config is reloaded during a session.
        group = vim.api.nvim_create_augroup("UserLspKeys", { clear = true }),

        callback = function(args)
          -- args.buf is the buffer number the LSP just attached to.
          -- Passing buffer = bufnr to keymap.set makes the mapping
          -- local to this buffer only — it won't exist in other buffers.
          local bufnr = args.buf

          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, {
              buffer = bufnr,
              desc = "LSP: " .. desc,
            })
          end

          -- gd → jump to where the symbol under the cursor is defined.
          -- Works across files — opens the file containing the definition.
          map("gd", vim.lsp.buf.definition, "Go to definition")

          -- K → floating window with type signature and docstring.
          -- Press K again to enter the window and scroll it.
          map("K", vim.lsp.buf.hover, "Hover docs")

          -- <leader>rn → semantic rename: renames the symbol everywhere
          -- in the project, respecting scope (not a dumb find-replace).
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")

          -- <leader>ca → code actions: context-aware quick fixes.
          -- e.g. "Add missing import", "Convert to f-string", "Ignore error"
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")

          -- gr → list all references to the symbol under cursor.
          -- Opens a picker showing every file/line that uses this symbol.
          map("gr", vim.lsp.buf.references, "Go to references")

          -- ]d / [d → jump forward/backward through diagnostics in this file.
          map("]d", vim.diagnostic.goto_next, "Next diagnostic")
          map("[d", vim.diagnostic.goto_prev, "Prev diagnostic")

          -- <leader>d → open the full diagnostic message in a float.
          -- Useful when the inline virtual text is truncated.
          map("<leader>d", vim.diagnostic.open_float, "Show diagnostic")
        end,
      })

      -- ── Server configurations (Neovim 0.11 native API) ─────
      --
      -- vim.lsp.config("name", opts) stores the settings for a server.
      -- This does NOT start the server — it just saves the config for
      -- when Neovim decides to start it.
      --
      -- vim.lsp.enable("name") tells Neovim to start that server
      -- automatically when a matching filetype is opened.

      -- Python: pyright
      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              -- "basic" catches common errors without being too strict.
              -- Options: "off" | "basic" | "strict"
              typeCheckingMode = "basic",

              -- automatically find packages installed in your active venv
              autoSearchPaths = true,

              -- infer types from library source code even without type stubs
              useLibraryCodeForTypes = true,
            },
          },
        },
      })

      -- Lua: lua_ls (useful when editing this Neovim config)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            -- Tell lua_ls that `vim` is a known global variable so it
            -- doesn't flag every vim.opt / vim.keymap line as an error.
            diagnostics = {
              globals = { "vim" },
            },
            -- Point lua_ls at Neovim's Lua API definitions for accurate
            -- completion of vim.* functions.
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              -- Suppress the noisy "configure work environment?" prompt.
              checkThirdParty = false,
            },
            telemetry = { enable = false },
          },
        },
      })

      -- Enable both servers.
      -- Neovim will start the right one when you open a matching filetype.
      -- vim.lsp.enable() accepts a string or a table of strings.
      vim.lsp.enable({ "pyright", "lua_ls" })

      -- ── Diagnostic display ──────────────────────────────────
      vim.diagnostic.config({
        -- Show error messages as ghost text to the right of the line.
        -- prefix "●" makes them easier to spot visually.
        virtual_text = {
          prefix = "●",
        },

        -- Show a symbol in the sign column (left of line numbers).
        signs = true,

        -- Draw a squiggly underline under the problematic code.
        underline = true,

        -- Only refresh diagnostics when leaving insert mode, not mid-keystroke.
        -- Avoids showing errors for half-written code.
        update_in_insert = false,

        -- Show errors first, then warnings, then hints.
        severity_sort = true,

        -- Configuration for the floating diagnostic popup (<leader>d).
        float = {
          border = "rounded",
          source = "always",  -- always show which server reported this error
        },
      })

    end,
  },
}
