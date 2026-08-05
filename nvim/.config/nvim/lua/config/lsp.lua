-- =============================================================================
-- lua/config/lsp.lua — LSP configuration (Neovim 0.11+ native API)
-- =============================================================================
--
-- Keymap convention (kickstart style):
--   gr*  — all LSP navigation/actions grouped under "gr" prefix
--     grd = go to definition
--     gri = go to implementation
--     grr = find references
--     grD = go to declaration
--     grt = go to type definition
--     grn = rename symbol
--     gra = code action
--   gO   = document symbols
--   gW   = workspace symbols
--   K    = hover documentation
--   <C-s>= signature help (insert mode)
-- =============================================================================

local paths = require("config.paths")

-- ── Capabilities (nvim-cmp integration) ──────────────────────────────────────
local ok_cmp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp then
  vim.lsp.config("*", {
    capabilities = cmp_nvim_lsp.default_capabilities(),
  })
end

-- ── LspAttach: keymaps when any LSP server attaches ──────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
  callback = function(ev)
    local bufnr = ev.buf
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    -- Disable hover for ruff (let pyright handle it)
    if client and client.name == "ruff" then
      client.server_capabilities.hoverProvider = false
    end

    local function bmap(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    -- ── Navigation (kickstart: gr* prefix, Telescope-powered) ──
    local ok_tb, tb = pcall(require, "telescope.builtin")

    if ok_tb then
      bmap("n", "grd", tb.lsp_definitions, "[G]oto [D]efinition")
      bmap("n", "gri", tb.lsp_implementations, "[G]oto [I]mplementation")
      bmap("n", "grr", tb.lsp_references, "[G]oto [R]eferences")
      bmap("n", "grt", tb.lsp_type_definitions, "[G]oto [T]ype Definition")
      bmap("n", "gO", tb.lsp_document_symbols, "Open Document Symbols")
      bmap("n", "gW", tb.lsp_dynamic_workspace_symbols, "Open Workspace Symbols")
    else
      bmap("n", "grd", vim.lsp.buf.definition, "[G]oto [D]efinition")
      bmap("n", "gri", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
      bmap("n", "grr", vim.lsp.buf.references, "[G]oto [R]eferences")
    end

    bmap("n", "grD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

    -- Familiar Vim and VS Code/Zed aliases alongside Neovim 0.11 defaults.
    bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
    bmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
    bmap("n", "gr", vim.lsp.buf.references, "Go to references")
    bmap("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
    bmap("n", "<F12>", vim.lsp.buf.definition, "Go to definition")
    bmap("n", "<S-F12>", vim.lsp.buf.references, "Go to references")

    -- ── Code actions (kickstart: gr* prefix) ──
    bmap("n", "grn", vim.lsp.buf.rename, "[R]e[n]ame")
    bmap("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
    bmap({ "n", "v" }, "gra", vim.lsp.buf.code_action, "[G]oto Code [A]ction")

    -- ── Documentation ──
    bmap("n", "K", vim.lsp.buf.hover, "Hover documentation")
    bmap("i", "<C-s>", vim.lsp.buf.signature_help, "Signature help")

    -- ── Diagnostics ──
    bmap("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
    bmap("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Prev diagnostic")
    bmap("n", "]e", function()
      vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
    end, "Next error")
    bmap("n", "[e", function()
      vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
    end, "Prev error")
    bmap("n", "<F8>", function() vim.diagnostic.jump({ count = 1 }) end, "Next problem")
    bmap("n", "<S-F8>", function() vim.diagnostic.jump({ count = -1 }) end, "Prev problem")
    bmap("n", "gl", vim.diagnostic.open_float, "Show line diagnostic")
    bmap("n", "<leader>q", vim.diagnostic.setloclist, "Diagnostics to loclist")

    -- ── Toggle inlay hints (kickstart: <leader>th) ──
    if client and client:supports_method("textDocument/inlayHint", bufnr) then
      bmap("n", "<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = bufnr })
      end, "[T]oggle Inlay [H]ints")
    end

    -- ── Document highlight (highlight symbol under cursor) ──
    if client and client:supports_method("textDocument/documentHighlight", bufnr) then
      local hl_augroup = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = bufnr,
        group = hl_augroup,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = bufnr,
        group = hl_augroup,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("LspDetach-" .. bufnr, { clear = true }),
        callback = function()
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "LspDocumentHighlight", buffer = bufnr })
        end,
      })
    end
  end,
})

-- ── Diagnostic display ───────────────────────────────────────────────────────
vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 4 },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = "󰠠 ",
      [vim.diagnostic.severity.INFO]  = " ",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = true },
  jump = { float = true },
})

-- ── Server configurations ────────────────────────────────────────────────────

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        venvPath = ".",
        venv = ".venv",
        autoImportCompletions = true,
        diagnosticMode = "workspace",
      },
    },
  },
})

vim.lsp.config("ruff", {
  -- Ruff has path handling problems on the work machine's mapped network drive
  -- and on UNC shares. Not calling on_dir prevents the client from starting.
  root_dir = function(bufnr, on_dir)
    local filename = vim.api.nvim_buf_get_name(bufnr)
    if paths.is_network_path(filename) then
      return
    end

    local root = vim.fs.root(filename, { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" })
    on_dir(root or vim.fs.dirname(filename))
  end,
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = { vim.env.VIMRUNTIME }, checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("rust_analyzer", {})

-- ── Enable servers ───────────────────────────────────────────────────────────
vim.lsp.enable({ "pyright", "ruff", "lua_ls", "rust_analyzer" })
