-- Entry point for Neovim config
vim.g.mapleader = " "
vim.g.maplocalleader = " "
require("core.settings").setup()
require("core.plugins").setup()
require("core.keymaps").setup()
require("core.ui").setup()
require("core.framework").setup()
require("lsp").setup()
