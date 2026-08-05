# Offline plugin installation

Offline mode never clones missing plugins, installs updates, runs the Lazy
update checker, or builds Treesitter parsers. Missing plugin directories are
disabled and listed in a Neovim warning.

## Directory layout

Check the data directory inside Neovim:

```vim
:echo stdpath("data")
```

On Windows it is normally:

```text
C:\Users\<user>\AppData\Local\nvim-data
```

Place `lazy.nvim` here:

```text
<data>\site\pack\manual\start\lazy.nvim
```

Place every other plugin directory here:

```text
<data>\site\pack\manual\opt\<plugin-directory>
```

The `start` directory also works for ordinary plugins, but `opt` is preferred
because `lazy.nvim` controls loading.

Directory names must match the repository names used in
`lua/config/lazy.lua`. The main exceptions are already named explicitly there,
for example `catppuccin` rather than the upstream repository basename `nvim`.

## Moving plugins to the offline machine

On a connected machine, download or clone `lazy.nvim` and each plugin listed in
`lua/config/lazy.lua`. Copy the complete directories to removable media, then
place them in the layout above. Include compiled Treesitter parser binaries if
you need Treesitter languages on the offline machine; `:TSUpdate` requires
network access and is intentionally not run in offline mode.

Enable offline mode with `lua/config/local.lua` or `NVIM_OFFLINE=1` before the
first launch. If Neovim reports a missing directory, copy that plugin using the
exact directory name from the warning and restart Neovim.

Language servers, formatters, debuggers, `ripgrep`, and REPL programs are
external executables rather than Neovim plugins. Install them separately and
make sure they are available on `PATH`.
