# quarticc.nvim

A lightweight, high-performance syntax highlighting and diagnostics extension for the QuarticC (`qc`) language in Neovim. 

## Note:
Requires QC Version `x0.20.11`+

## Installation

### Using `packer.nvim`

Add the repository block to your Neovim plugins file:

```lua
use {
  'Youg-Otricked/quarticc.nvim',
  ft = { 'quarticc' },
}
```
Then:
```vim
:PackerInstall
:PackerCompile
```

### Using `lazy.nvim`

```lua
return {
  {
    "Youg-Otricked/quarticc.nvim",
    ft = { "quarticc" },
  }
}
```

## Customization

The plugin binds your compiler tokens directly to Neovim's standard token groups, meaning it automatically updates its palette to match your active editor theme (e.g., Catppuccin, Gruvbox, NordFox).
