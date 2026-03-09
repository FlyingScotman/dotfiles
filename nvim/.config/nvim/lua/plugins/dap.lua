-- ============================================================
--  lua/plugins/dap.lua — Debug Adapter Protocol
--
--  DAP is a protocol (also by Microsoft, same idea as LSP) that
--  separates debugging logic from the editor. A debug adapter
--  runs your code in debug mode and communicates with Neovim.
--
--  nvim-dap       → the DAP client built into Neovim (like nvim-lspconfig for LSP)
--  nvim-dap-python → configures the Python debug adapter (debugpy) automatically
--
--  To actually debug Python, you need debugpy installed:
--    pip install debugpy
-- ============================================================

return {
  {
    "mfussenegger/nvim-dap",

    -- Load DAP only when these keymaps are first triggered (via `keys = {}`).
    -- This is the most aggressive lazy loading — the plugin doesn't even load
    -- until you press one of these keys for the first time.
    keys = {
      "<leader>db",  -- these are just the trigger keys for lazy-loading
      "<leader>dc",  -- the actual mappings are defined below in config
      "<leader>ds",
    },

    dependencies = {
      "mfussenegger/nvim-dap-python",
    },

    config = function()
      local dap = require("dap")

      -- ── Python adapter setup ─────────────────────────────────
      -- require("dap-python").setup() configures the Python debug adapter.
      -- The argument is the path to the Python executable that has debugpy
      -- installed. Using the system python3 assumes debugpy is installed globally.
      --
      -- If you use virtual environments, consider:
      --   require("dap-python").setup("~/.virtualenvs/debugpy/bin/python")
      --   (a dedicated venv for debugpy is a common pattern)
      require("dap-python").setup("python3")

      -- ── Keymaps ──────────────────────────────────────────────

      -- <leader>db → toggle a breakpoint on the current line.
      -- A breakpoint tells the debugger: "pause execution here."
      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })

      -- <leader>dc → continue (or start) the debug session.
      -- If no session is running, this starts one. If paused at a breakpoint, resumes.
      vim.keymap.set("n", "<leader>dc", dap.continue, { desc = "DAP: Continue / Start" })

      -- <leader>ds → step over the current line.
      -- Executes the current line and pauses on the next one.
      -- (vs. step INTO which would enter a called function)
      vim.keymap.set("n", "<leader>ds", dap.step_over, { desc = "DAP: Step over" })

      -- <leader>di → step into the function call on the current line.
      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step into" })

      -- <leader>do → step out of the current function, back to its caller.
      vim.keymap.set("n", "<leader>do", dap.step_out, { desc = "DAP: Step out" })

      -- ── DAP UI signs ─────────────────────────────────────────
      -- Customize the icons shown in the sign column for breakpoints.
      -- vim.fn.sign_define() registers a named sign with a given text/color.
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn"  })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticInfo"  })
      -- texthl links to an existing highlight group for color.
      -- DiagnosticError is typically red, DiagnosticWarn yellow, DiagnosticInfo blue.
    end,
  },
}
