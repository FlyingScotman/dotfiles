-- =============================================================================
-- lua/config/keymaps.lua — ALL keymaps
-- =============================================================================
--
-- Keymap conventions (kickstart.nvim style):
--   <leader>s*  — Search/Telescope
--   <leader>h*  — Git hunk actions (gitsigns, set in plugins.lua)
--   <leader>t*  — Toggle (inlay hints, inline blame, etc.)
--   gr*         — LSP actions (definition, references, rename, etc.)
--   <leader>f   — Format (single key, not a prefix group)
--   <leader>r*  — Run / REPL (iron.nvim)              ← NEW
--   <F5>-<F11>  — Debug (DAP)                         ← NEW
--
-- Plugin-specific keymaps use pcall so missing plugins won't crash.
-- LspAttach keymaps live in lsp.lua. Filetype keymaps live in autocmds.lua.
-- Insert-mode cmp/telescope mappings live in plugins.lua (part of setup()).
-- =============================================================================

local map = vim.keymap.set

-- ============================================================================
-- GENERAL EDITING
-- ============================================================================

map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
map("n", "Q", "<nop>", { desc = "Disabled: ex mode" })
map("n", "J", "mzJ`z", { desc = "Join line, keep cursor" })
map("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", { desc = "Clear search highlights" })

-- ============================================================================
-- MOVEMENT — Center cursor after scrolling / searching
-- ============================================================================

map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down, center" })
map("n", "<C-u>", "<C-u>zz", { desc = "Scroll up, center" })
map("n", "n", "nzzzv", { desc = "Next search, center" })
map("n", "N", "Nzzzv", { desc = "Prev search, center" })

-- ============================================================================
-- WINDOW / SPLIT NAVIGATION (kickstart)
-- ============================================================================

map("n", "<C-h>", "<C-w><C-h>", { desc = "Focus left window" })
map("n", "<C-l>", "<C-w><C-l>", { desc = "Focus right window" })
map("n", "<C-j>", "<C-w><C-j>", { desc = "Focus lower window" })
map("n", "<C-k>", "<C-w><C-k>", { desc = "Focus upper window" })

-- ============================================================================
-- VISUAL MODE — Move lines
-- ============================================================================

map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- ============================================================================
-- CLIPBOARD
-- ============================================================================
-- CHANGE: removed unnamedplus from options.lua, so these maps are now the
-- *only* way to interact with the system clipboard. This keeps your unnamed
-- register clean — deletes and changes don't pollute the OS clipboard.

map("x", "<leader>p", [["_dP]], { desc = "Paste without overwriting register" })
map({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })
map({ "n", "v" }, "<leader>x", [["_d]], { desc = "Delete to black hole" })

-- ============================================================================
-- QUICKFIX LIST
-- ============================================================================

map("n", "<leader>j", "<cmd>cnext<CR>zz", { desc = "Next quickfix item" })
map("n", "<leader>k", "<cmd>cprev<CR>zz", { desc = "Prev quickfix item" })

-- ============================================================================
-- REPLACE WORD
-- ============================================================================

map("n", "<leader>R", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor" })

-- ============================================================================
-- FILE EXPLORER / UNDOTREE
-- ============================================================================

map("n", "<leader>e", vim.cmd.Ex, { desc = "Open file explorer (netrw)" })
map("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })

-- ============================================================================
-- TELESCOPE — <leader>s* search group (kickstart style)
-- ============================================================================

local ok_tele, builtin = pcall(require, "telescope.builtin")
if ok_tele then
  -- ── Core search (kickstart mappings) ──
  map("n", "<leader>sh", builtin.help_tags, { desc = "[S]earch [H]elp" })
  map("n", "<leader>sk", builtin.keymaps, { desc = "[S]earch [K]eymaps" })
  map("n", "<leader>sf", builtin.find_files, { desc = "[S]earch [F]iles" })
  map("n", "<leader>ss", builtin.builtin, { desc = "[S]earch [S]elect Telescope" })
  map({ "n", "v" }, "<leader>sw", builtin.grep_string, { desc = "[S]earch current [W]ord" })
  map("n", "<leader>sg", builtin.live_grep, { desc = "[S]earch by [G]rep" })
  map("n", "<leader>sd", builtin.diagnostics, { desc = "[S]earch [D]iagnostics" })
  map("n", "<leader>sr", builtin.resume, { desc = "[S]earch [R]esume" })
  map("n", "<leader>s.", builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
  map("n", "<leader>sc", builtin.commands, { desc = "[S]earch [C]ommands" })
  map("n", "<leader><leader>", builtin.buffers, { desc = "Find existing buffers" })

  -- ── Extra search (beyond kickstart) ──
  map("n", "<C-p>", builtin.git_files, { desc = "Find git-tracked files" })
  map("n", "<leader>sn", function()
    builtin.find_files({ cwd = vim.fn.stdpath("config") })
  end, { desc = "[S]earch [N]eovim config files" })
  map("n", "<leader>sN", function()
    builtin.live_grep({ cwd = vim.fn.stdpath("config") })
  end, { desc = "[S]earch (grep) [N]eovim config" })

  -- ── Fuzzy search in current buffer (kickstart) ──
  map("n", "<leader>/", function()
    builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown {
      winblend = 10,
      previewer = false,
    })
  end, { desc = "[/] Fuzzily search in current buffer" })

  -- ── Live grep in open files (kickstart) ──
  map("n", "<leader>s/", function()
    builtin.live_grep { grep_open_files = true, prompt_title = "Live Grep in Open Files" }
  end, { desc = "[S]earch [/] in Open Files" })

  -- ── Search TODO comments ──
  -- Uses the :TodoTelescope command which todo-comments.nvim provides.
  -- Safer than requiring internal module functions that may vary by version.
  local ok_todo, _ = pcall(require, "todo-comments")
  if ok_todo then
    map("n", "<leader>st", "<cmd>TodoTelescope<CR>", { desc = "[S]earch [T]ODO comments" })
  end
end

-- ============================================================================
-- HARPOON — Quick file pinning
-- ============================================================================

local ok_harp, _ = pcall(require, "harpoon")
if ok_harp then
  local mark = require("harpoon.mark")
  local ui   = require("harpoon.ui")

  map("n", "<leader>ha", mark.add_file, { desc = "Harpoon: add file" })
  map("n", "<leader>ho", ui.toggle_quick_menu, { desc = "Harpoon: open menu" })
  map("n", "<leader>1", function() ui.nav_file(1) end, { desc = "Harpoon: file 1" })
  map("n", "<leader>2", function() ui.nav_file(2) end, { desc = "Harpoon: file 2" })
  map("n", "<leader>3", function() ui.nav_file(3) end, { desc = "Harpoon: file 3" })
  map("n", "<leader>4", function() ui.nav_file(4) end, { desc = "Harpoon: file 4" })
end

-- ============================================================================
-- GIT — Fugitive
-- ============================================================================

map("n", "<leader>gs", vim.cmd.Git, { desc = "Git status (Fugitive)" })
map("n", "<leader>gc", "<cmd>Git commit<CR>", { desc = "Git commit" })

-- ============================================================================
-- TERMINAL
-- ============================================================================

map("t", "<C-w>", "<C-\\><C-n><C-w>", { desc = "Terminal: exit + window cmd" })

-- NEW: terminal resize keymaps — fixes the "can't shrink toggleterm" problem.
-- These work in terminal mode so you can resize without leaving the terminal.
map("t", "<C-Up>", "<cmd>resize +5<CR>", { desc = "Increase terminal height" })
map("t", "<C-Down>", "<cmd>resize -5<CR>", { desc = "Decrease terminal height" })
-- Also available in normal mode for when you've escaped out of the terminal:
map("n", "<C-Up>", "<cmd>resize +5<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -5<CR>", { desc = "Decrease window height" })

-- ============================================================================
-- LEAP — Jump to visible character
-- ============================================================================

local ok_leap, _ = pcall(require, "leap")
if ok_leap then
  map({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "Leap forward" })
  map({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "Leap backward" })
end

-- ============================================================================
-- FORMAT — <leader>f (kickstart style, single key)
-- ============================================================================

map("n", "<leader>f", function()
  local ok, conform = pcall(require, "conform")
  local paths = require("config.paths")
  if vim.bo.filetype == "python" and paths.is_network_buffer(0) then
    vim.lsp.buf.format({
      async = true,
      filter = function(client)
        return client.name ~= "ruff"
      end,
    })
  elseif ok then
    conform.format({ async = true, lsp_format = "fallback" })
  else
    vim.lsp.buf.format({ async = true })
  end
end, { desc = "Format buffer" })

-- ============================================================================
-- DEBUG (DAP) — F-key cluster                                          ← NEW
-- ============================================================================
-- Standard debugger keybindings using F-keys.
-- F5  = start/continue, F9 = breakpoint, F10 = step over, F11 = step into.
-- <leader>d* prefix for less common actions (UI toggle, conditional bp, etc.)

local ok_dap, dap = pcall(require, "dap")
if ok_dap then
  map("n", "<F5>",     dap.continue,          { desc = "Debug: Start / Continue" })
  map("n", "<F9>",     dap.toggle_breakpoint,  { desc = "Debug: Toggle Breakpoint" })
  map("n", "<F10>",    dap.step_over,          { desc = "Debug: Step Over" })
  map("n", "<F11>",    dap.step_into,          { desc = "Debug: Step Into" })
  map("n", "<S-F11>",  dap.step_out,           { desc = "Debug: Step Out" })
  map("n", "<leader>dB", function()
    dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
  end, { desc = "Debug: Conditional Breakpoint" })
  map("n", "<leader>dl", function()
    dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
  end, { desc = "Debug: Log Point" })
  map("n", "<leader>dr", dap.repl.open,        { desc = "Debug: Open REPL" })
  map("n", "<leader>dx", dap.terminate,         { desc = "Debug: Terminate" })

  local ok_dapui, dapui = pcall(require, "dapui")
  if ok_dapui then
    map("n", "<leader>du", dapui.toggle, { desc = "Debug: Toggle UI" })
    map("n", "<leader>de", dapui.eval,   { desc = "Debug: Evaluate expression" })
    map("v", "<leader>de", dapui.eval,   { desc = "Debug: Evaluate selection" })
  end
end

-- ============================================================================
-- IRON.NVIM — REPL / Cell execution (<leader>r* group)                 ← NEW
-- ============================================================================
-- Jupyter-like workflow: use  # %%  markers as cell delimiters in .py files,
-- then send cells/lines/selections to a live Python REPL.
--
-- NOTE: most iron keymaps (send_line, visual_send, send_file, send_code_block)
-- are defined inside iron.setup() in plugins.lua — that's how iron's API works.
-- Here we only add the extra maps that use Vim commands or plain Lua.
--
-- Iron keymaps (set in plugins.lua):
--   <leader>rl  — send current line
--   <leader>rv  — send visual selection
--   <leader>rf  — send entire file
--   <leader>rb  — send code block (# %% cell)
--   <leader>rB  — send code block and move to next
--   <leader>rp  — send paragraph
--   <leader>rq  — exit / close REPL
--   <leader>ri  — interrupt REPL
--   <leader>rx  — clear REPL

-- These use Vim commands / plain Lua, so they live here:
map("n", "<leader>rr", "<cmd>IronRepl<CR><Esc>",    { desc = "REPL: Open / focus REPL" })
map("n", "<leader>rR", "<cmd>IronRestart<CR>",  { desc = "REPL: Restart" })
map("n", "<leader>rh", "<cmd>IronHide<CR>",     { desc = "REPL: Hide REPL window" })

-- Jump between # %% cell markers
map("n", "<leader>r]", [[/^# %%<CR>:nohlsearch<CR>]], { desc = "REPL: Next cell marker", silent = true })
map("n", "<leader>r[", [[?^# %%<CR>:nohlsearch<CR>]], { desc = "REPL: Prev cell marker", silent = true })
