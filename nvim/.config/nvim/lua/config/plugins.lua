-- =============================================================================
-- lua/config/plugins.lua — Plugin setup
-- =============================================================================
-- CHANGE SUMMARY:
--   • Colorscheme: now loaded via packadd in init.lua (moved to opt/)
--   • ToggleTerm: dynamic sizing + explicit Git Bash shell
--   • lsp_signature: wrapped in pcall (was a crash risk)
--   • NEW: nvim-dap + dap-python + dap-ui (debugger)
--   • NEW: iron.nvim (REPL / Jupyter-like cells)
--   • NEW: which-key groups for [R]EPL and [D]ebug
-- =============================================================================

-- ============================================================================
-- COLORSCHEME — Rose Pine
-- ============================================================================
-- CHANGE: the packadd is in init.lua. All colorschemes live in opt/ now.
-- This block only runs setup() for the active theme.

-- local ok_rose, rose = pcall(require, "rose-pine")
-- if ok_rose then
--   rose.setup({ variant = "moon", disable_background = false, styles = { italic = false } })
--   vim.cmd("colorscheme rose-pine")
-- end

local ok_colorscheme, colorscheme = pcall(require, "catppuccin")
if ok_colorscheme then
  colorscheme.setup({ variant = "nvim", disable_background = false, styles = { italic = false } })
  vim.cmd("colorscheme catppuccin")
end

-- ============================================================================
-- STATUS LINE — Lualine
-- ============================================================================

local ok_ll, lualine = pcall(require, "lualine")
if ok_ll then
  lualine.setup({
    options = {
      theme = "catppuccin",
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { { "filename", path = 1 } },
      lualine_x = { "filetype" },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  })
end

-- ============================================================================
-- TELESCOPE
-- ============================================================================

local ok_tele, telescope = pcall(require, "telescope")
if ok_tele then
  telescope.setup({
    defaults = {
      layout_config = { horizontal = { preview_width = 0.55 } },
      file_ignore_patterns = {
        "node_modules", ".git/", "__pycache__", "%.pyc",
        "%.egg%-info", "venv/", ".venv/", "dist/", "build/",
      },
      mappings = {
        i = {
          ["<C-k>"] = "move_selection_previous",
          ["<C-j>"] = "move_selection_next",
          ["<C-q>"] = "send_to_qflist",
          ["<Esc>"] = "close",
        },
      },
    },
    pickers = { find_files = { hidden = true } },
  })
  pcall(telescope.load_extension, "fzf")
  pcall(telescope.load_extension, "ui-select")
end

-- ============================================================================
-- TREESITTER
-- ============================================================================

local ok_ts, treesitter = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  treesitter.setup({
    ensure_installed = {},
    highlight = { enable = true, additional_vim_regex_highlighting = false },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<M-space>",
      },
    },
  })
end

-- ============================================================================
-- AUTOCOMPLETION — nvim-cmp
-- ============================================================================

local ok_cmp, cmp = pcall(require, "cmp")
local ok_snip, luasnip = pcall(require, "luasnip")
local ok_minuet, minuet = pcall(require, "minuet")

if ok_cmp then
  local mappings = cmp.mapping.preset.insert({
    ["<C-k>"] = cmp.mapping.select_prev_item(),
    ["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif ok_snip and luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),
  })
  local primary_sources = {
    { name = "nvim_lsp" },
    { name = "luasnip" },
  }

  if ok_minuet then
    mappings["<A-y>"] = minuet.make_cmp_map()
    table.insert(primary_sources, 1, { name = "minuet", group_index = 1, priority = 100 })
  end

  cmp.setup({
    snippet = {
      expand = function(args)
        if ok_snip then luasnip.lsp_expand(args.body) end
      end,
    },
    mapping = mappings,
    sources = cmp.config.sources(primary_sources, {
      { name = "buffer" },
      { name = "path" },
    }),
    performance = { fetching_timeout = 5000 },
    formatting = {
      format = function(entry, item)
        local source_names = {
          minuet = "[AI]",
          nvim_lsp = "[LSP]",
          luasnip = "[Snip]",
          buffer = "[Buf]",
          path = "[Path]",
        }
        item.menu = source_names[entry.source.name] or ""
        return item
      end,
    },
  })
end

-- ============================================================================
-- GIT SIGNS — full recommended keymaps (kickstart style)
-- ============================================================================

local ok_gs, gitsigns = pcall(require, "gitsigns")
if ok_gs then
  gitsigns.setup({
    signs = {
      add          = { text = "│" },
      change       = { text = "│" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
    },
    on_attach = function(bufnr)
      local gs = package.loaded.gitsigns
      local function bmap(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr
        vim.keymap.set(mode, l, r, opts)
      end

      -- Navigation
      bmap("n", "]c", function()
        if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
      end, { desc = "Next git hunk" })
      bmap("n", "[c", function()
        if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
      end, { desc = "Prev git hunk" })

      -- Hunk actions
      bmap("n", "<leader>hs", gs.stage_hunk, { desc = "Stage hunk" })
      bmap("n", "<leader>hr", gs.reset_hunk, { desc = "Reset hunk" })
      bmap("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
      bmap("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
      bmap("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
      bmap("n", "<leader>hi", gs.preview_hunk_inline, { desc = "Preview hunk inline" })
      bmap("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
      bmap("n", "<leader>hd", gs.diffthis, { desc = "Diff against index" })
      bmap("n", "<leader>hD", function() gs.diffthis("@") end, { desc = "Diff against last commit" })
      bmap("n", "<leader>hQ", function() gs.setqflist("all") end, { desc = "All hunks to qf" })
      bmap("n", "<leader>hq", gs.setqflist, { desc = "Hunks to qf" })

      -- Toggles
      bmap("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle inline blame" })
      bmap("n", "<leader>tw", gs.toggle_word_diff, { desc = "Toggle word diff" })

      -- Visual mode
      bmap("v", "<leader>hs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage selection" })
      bmap("v", "<leader>hr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset selection" })

      -- Text object
      bmap({ "o", "x" }, "ih", gs.select_hunk, { desc = "Select hunk" })
    end,
  })
end

-- ============================================================================
-- COMMENT / AUTOPAIRS / WHICH-KEY / LEAP / TOGGLETERM
-- ============================================================================

local ok_comment, comment = pcall(require, "Comment")
if ok_comment then comment.setup() end

local ok_ap, autopairs = pcall(require, "nvim-autopairs")
if ok_ap then
  autopairs.setup({ check_ts = true })
  if ok_cmp then
    local cmp_ap = require("nvim-autopairs.completion.cmp")
    cmp.event:on("confirm_done", cmp_ap.on_confirm_done())
  end
end

local ok_surround, surround = pcall(require, "nvim-surround")
if ok_surround then surround.setup({}) end

local ok_wk, wk = pcall(require, "which-key")
if ok_wk then
  wk.setup({
    delay = 300,
    icons = { mappings = vim.g.have_nerd_font },
    spec = {
      -- Kickstart groups
      { "<leader>s", group = "[S]earch", mode = { "n", "v" } },
      { "<leader>t", group = "[T]oggle" },
      { "<leader>h", group = "Git [H]unk", mode = { "n", "v" } },
      { "gr", group = "[G]oto LSP", mode = { "n" } },
      -- Extra groups
      { "<leader>g", group = "[G]it" },
      -- NEW: groups for debug and REPL
      { "<leader>d", group = "[D]ebug (DAP)" },
      { "<leader>r", group = "[R]EPL / Run" },
    },
  })
end

local ok_leap, leap = pcall(require, "leap")
if ok_leap then leap.setup({}) end

local ok_toggle, toggle = pcall(require, "toggleterm")
if ok_toggle then
  local terminal_shell = vim.g.toggleterm_shell
  if not terminal_shell or terminal_shell == "" then
    terminal_shell = vim.fn.exepath("bash")
    if terminal_shell == "" then terminal_shell = nil end
  end

  toggle.setup({
    open_mapping = [[<C-s>]],
    -- CHANGE: dynamic sizing — terminal gets 35% of screen height (horizontal)
    -- or 45% of screen width (vertical). Fixes the "can't resize" problem by
    -- starting at a reasonable size. Also see <C-Up>/<C-Down> in keymaps.lua.
    size = function(term)
      if term.direction == "horizontal" then
        return math.floor(vim.o.lines * 0.35)
      elseif term.direction == "vertical" then
        return math.floor(vim.o.columns * 0.45)
      end
      return 20
    end,
    -- Configure a machine-specific Git Bash path in config/local.lua when it
    -- is not discoverable through PATH.
    shell = terminal_shell,
    close_on_exit = false,
    direction = "horizontal",
    shade_terminals = true,
    shading_factor = 2,
    start_in_insert = true,
    insert_mappings = false,
    terminal_mappings = true,
    persist_size = true,
    float_opts = { border = "curved", winblend = 0 },
  })
end

-- ============================================================================
-- NEW PLUGINS (from kickstart, not in original setup)
-- ============================================================================

-- todo-comments: highlights TODO/FIXME/HACK in comments with colors
local ok_todo, todo_comments = pcall(require, "todo-comments")
if ok_todo then todo_comments.setup({ signs = false }) end

-- conform: auto-format on save
local ok_conform, conform = pcall(require, "conform")
if ok_conform then
  local paths = require("config.paths")
  conform.setup({
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then return nil end
      if vim.bo[bufnr].filetype == "python" and paths.is_network_buffer(bufnr) then
        return nil
      end
      return { timeout_ms = 500, lsp_format = "fallback" }
    end,
    formatters_by_ft = {
      python = { "ruff_format" },
      lua = { "stylua" },
    },
  })
end

-- guess-indent: auto-detect tab vs spaces
local ok_guess, guess_indent = pcall(require, "guess-indent")
if ok_guess then guess_indent.setup({}) end

-- CHANGE: wrapped in pcall (was bare require — would crash if plugin missing)
local ok_lspsig, lsp_signature = pcall(require, "lsp_signature")
if ok_lspsig then
  lsp_signature.setup({
    bind = true,
    floating_window = true,
    handler_opts = { border = "rounded" },
    toggle_key = "<C-k>",
  })
end

-- ============================================================================
-- DEBUG — nvim-dap + dap-python + dap-ui                               ← NEW
-- ============================================================================
-- Keymaps are in keymaps.lua (F5/F9/F10/F11 cluster + <leader>d* group).
--
-- Prerequisites:
--   pip install debugpy          (in your project venv or globally)
--
-- Plugins needed in pack/manual/start/:
--   nvim-dap, nvim-dap-python, nvim-dap-ui, nvim-nio

local ok_dap, dap = pcall(require, "dap")
local ok_dap_py, dap_python = pcall(require, "dap-python")
local ok_dapui, dapui = pcall(require, "dapui")

if ok_dap then
  -- Signs in the gutter for breakpoints
  vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError", linehl = "", numhl = "" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn", linehl = "", numhl = "" })
  vim.fn.sign_define("DapLogPoint", { text = "◇", texthl = "DiagnosticInfo", linehl = "", numhl = "" })
  vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticOk", linehl = "DiffAdd", numhl = "" })
  vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint", linehl = "", numhl = "" })
end

if ok_dap and ok_dap_py then
  -- dap-python will auto-detect debugpy in the current python environment.
  -- The argument is the python executable to use for launching debugpy.
  -- "python" uses whatever is on PATH (respects activated venvs).
  dap_python.setup("python")
  dap_python.test_runner = "pytest"
end

if ok_dap and ok_dapui then
  dapui.setup({
    -- Sensible layout: variables + stacks on left, REPL + console on bottom
    layouts = {
      {
        elements = {
          { id = "scopes", size = 0.4 },
          { id = "breakpoints", size = 0.15 },
          { id = "stacks", size = 0.25 },
          { id = "watches", size = 0.2 },
        },
        position = "left",
        size = 40,
      },
      {
        elements = {
          { id = "repl", size = 0.5 },
          { id = "console", size = 0.5 },
        },
        position = "bottom",
        size = 12,
      },
    },
  })

  -- Auto open/close dap-ui when debug session starts/ends
  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

-- ============================================================================
-- REPL — iron.nvim (Jupyter-like cell execution)                       ← NEW
-- ============================================================================
-- Workflow:
--   1. Write Python with  # %%  cell markers (same as VS Code / Jupyter)
--   2. <leader>rb sends the current cell to a live Python REPL
--   3. <leader>rl sends a single line, <leader>rv sends visual selection
--   4. <leader>rr opens/focuses the REPL (set in keymaps.lua via :IronRepl)
--
-- NOTE: iron requires keymaps to be defined inside iron.setup().
-- The <leader>r* bindings for iron commands (:IronRepl, :IronRestart, etc.)
-- and cell-marker navigation are in keymaps.lua.
--
-- Plugins needed in pack/manual/start/:
--   iron.nvim

local ok_iron, iron = pcall(require, "iron.core")
if ok_iron then
  local common = require("iron.fts.common")
  iron.setup({
    config = {
      -- Should the REPL be discarded when the associated buffer is closed?
      scratch_repl = true,
      repl_definition = {
        python = {
          -- Uses "python" from PATH — respects activated venvs.
          -- Change to { "ipython", "--no-autoindent" } if you prefer IPython.
          command = { "ipython", "--no-autoindent" },
          -- bracketed_paste avoids indentation issues when sending multi-line code
          format = common.bracketed_paste_python,
          -- These patterns tell iron where # %% cell boundaries are.
          -- Without this, send_code_block errors out.
          block_dividers = { "# %%", "#%%" },
          -- Needed for Python 3.13+ to avoid REPL auto-indent issues
          env = { PYTHON_BASIC_REPL = "1" },
        },
      },
      -- REPL opens as a vertical split on the right, 80 columns wide.
      -- Feels natural: code on left, REPL output on right.
      repl_open_cmd = require("iron.view").split.vertical.botright("50%"),
    },
    -- Iron creates these keymaps internally — this is the correct API.
    -- send_motion is an operator: press <leader>rc then a motion (e.g. ip for paragraph).
    -- send_code_block sends the # %% delimited cell.
    keymaps = {
      send_motion          = "<leader>rc",   -- operator: <leader>rc + motion
      visual_send          = "<leader>rv",   -- send visual selection
      send_file            = "<leader>rf",   -- send entire file
      send_line            = "<leader>rl",   -- send current line
      send_paragraph       = "<leader>rp",   -- send current paragraph
      send_code_block      = "<leader>rb",   -- send # %% cell
      send_code_block_and_move = "<leader>rB", -- send cell + jump to next
      send_until_cursor    = "<leader>ru",   -- send from top to cursor
      send_mark            = "<leader>rm",   -- send marked region
      mark_motion          = "<leader>rMc",  -- mark a motion
      mark_visual          = "<leader>rMv",  -- mark visual selection
      remove_mark          = "<leader>rMd",  -- remove mark
      interrupt            = "<leader>ri",   -- send SIGINT to REPL
      exit                 = "<leader>rq",   -- exit REPL
      clear                = "<leader>rx",   -- clear REPL screen
    },
    -- Highlight sent text briefly so you can see what was dispatched
    highlight = { italic = true },
    ignore_blank_lines = true,
  })
end
