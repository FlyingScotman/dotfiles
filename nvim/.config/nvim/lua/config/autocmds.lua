-- =============================================================================
-- lua/config/autocmds.lua — Autocommands and filetype-specific settings
-- =============================================================================
-- CHANGE SUMMARY:
--   • Python: added makeprg + errorformat for quickfix-based error navigation
--   • Python: removed <F5>/<F6> (now used by DAP — see keymaps.lua)
--   • Python: removed <leader>r (now used by iron.nvim REPL — see keymaps.lua)
-- =============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on Yank ──
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

-- ── Python-specific Settings ──
augroup("PythonSettings", { clear = true })
autocmd("FileType", {
  group = "PythonSettings",
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.colorcolumn = "88"

    -- NEW: makeprg + errorformat for Python.
    -- Run with :make — errors land in the quickfix list automatically.
    -- Navigate errors with <leader>j / <leader>k (cnext/cprev in keymaps.lua)
    -- or use <leader>sd (Telescope diagnostics) for a searchable list.
    --
    -- The errorformat pattern parses standard Python tracebacks:
    --   File "path/to/file.py", line 42, in function_name
    --       some_code_here
    --   ErrorType: message
    vim.opt_local.makeprg = "python %"
    vim.opt_local.errorformat = table.concat({
      '%A  File "%f"\\, line %l\\, in %o',  -- traceback "File" line
      '%A  File "%f"\\, line %l',            -- traceback without function
      "%C    %.%#",                           -- continuation (code context)
      "%Z%[%^ ]%\\@=%m",                     -- error message (first non-space)
      "%-G%.%#",                              -- ignore everything else
    }, ",")

    -- <leader>m: run current file via :make (errors go to quickfix)
    vim.keymap.set("n", "<leader>m", "<cmd>make<CR>", {
      buffer = true,
      desc = "Run Python file (:make → quickfix)",
    })
  end,
})

-- ── Trim Trailing Whitespace on Save ──
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = { "*.py", "*.lua", "*.toml", "*.md" },
  callback = function()
    local save_cursor = vim.fn.getpos(".")
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos(".", save_cursor)
  end,
})

-- ── Restore Cursor Position on Reopen ──
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Terminal Settings ──
augroup("TerminalSettings", { clear = true })
autocmd("TermOpen", {
  group = "TerminalSettings",
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.cmd("startinsert")
    vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = true, desc = "Exit terminal mode" })
  end,
})

-- ── Iron.nvim cell markers — highlight # %% lines ──                    NEW
-- Makes cell boundaries visible when editing Python files with iron.nvim.
augroup("IronCellHighlight", { clear = true })
autocmd("FileType", {
  group = "IronCellHighlight",
  pattern = "python",
  callback = function()
    -- Highlight # %% markers using the same style as code comments but bolder
    vim.fn.matchadd("Todo", "^# %%.*$")
  end,
})
