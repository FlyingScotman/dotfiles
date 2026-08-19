# Neovim configuration

Neovim 0.11+ configuration for Python, Rust, and Lua development. It supports
normal online installation through `lazy.nvim` and a strict offline mode for
machines that cannot access GitHub.

## Compatibility requirement

This configuration must remain usable on the work Windows machine where GitHub
repositories can be downloaded through a browser, but automatic GitHub cloning
and plugin installation do not work. Core editing and the `<leader>e` file
explorer therefore must not depend on a downloadable explorer plugin;
`<leader>e` uses Neovim's built-in netrw `:Ex` command.

## Minimal setup

From the root of the dotfiles repository, link the configuration:

```sh
stow nvim
```

On a machine with GitHub access, no local configuration is required. Start
Neovim and `lazy.nvim` will bootstrap itself and install missing plugins.

Install the external tools you use separately. The main ones are:

- `git` and `ripgrep`;
- `pyright`, `ruff`, `debugpy`, and optionally `ipython`;
- `rust-analyzer`;
- `lua-language-server` and `stylua`.

## Work/offline machine

1. Copy the example without committing the copy:

   ```powershell
   Copy-Item lua/config/local.lua.example lua/config/local.lua
   ```

2. Keep this setting enabled in `local.lua`:

   ```lua
   vim.g.neovim_offline = true
   ```

3. Put `lazy.nvim` and plugin directories in the locations described in
   [OFFLINE.md](OFFLINE.md).

As a temporary alternative to `local.lua`, launch Neovim with:

```powershell
$env:NVIM_OFFLINE = "1"
nvim
```

`local.lua` is ignored by Git and is also the right place for a machine-specific
Git Bash path:

```lua
vim.g.toggleterm_shell = "C:/Users/your-name/AppData/Local/Programs/Git/usr/bin/bash.exe"
```

## Network paths and Ruff

Ruff LSP and Ruff formatting are automatically disabled for files on `G:\` and
UNC paths such as `\\server\share\project`. Pyright remains enabled. This avoids
the path failures seen on the work machine without requiring `:LspStop ruff`.

## Optional LLM support

CodeCompanion provides chat and inline actions. Minuet provides automatic LLM
code completion through the existing `nvim-cmp` menu. Each integration is
enabled only when the configuration detects a compatible provider. Without an
API key or supported local CLI, the plugins are not installed or loaded and the
rest of the configuration works unchanged.

Supported API key variables are `OPENAI_API_KEY`, `ANTHROPIC_API_KEY`,
`GEMINI_API_KEY`, `OPENROUTER_API_KEY`, `DEEPSEEK_API_KEY`, and `XAI_API_KEY`.
The configuration also detects Codex ACP, Claude Code ACP, Gemini CLI, Copilot
CLI, OpenCode, and Ollama. Ollama defaults to `qwen2.5-coder:7b`.

Set `NVIM_LLM_ADAPTER` or `NVIM_LLM_MODEL` to override the detected adapter or
model. Autocomplete can be overridden independently with
`NVIM_LLM_COMPLETION_PROVIDER` and `NVIM_LLM_COMPLETION_MODEL`.

LLM suggestions appear automatically in the completion menu. Press `<A-y>` in
insert mode to request them manually, or use `:Minuet cmp toggle` to toggle
automatic LLM completion for the current session. Chat mappings are:

- `<leader>ac`: toggle LLM chat;
- `<leader>aa`: open the LLM action palette;
- `<leader>ai`: use an inline prompt;
- `ga` in visual mode: add the selection to chat.

## Useful compatible keybindings

- `gd` / `F12`: definition;
- `gr` / `Shift-F12`: references;
- `gi`: implementation;
- `gy`: type definition;
- `F2`: rename;
- `]d` / `[d`: next/previous diagnostic;
- `]e` / `[e`: next/previous error;
- `F8` / `Shift-F8`: next/previous problem;
- `<leader>ha` / `<leader>ho`: add a file to Harpoon / open its menu;
- `<leader>r]` / `<leader>r[`: next/previous Python cell;
- `<leader>x`: delete to the black-hole register.
