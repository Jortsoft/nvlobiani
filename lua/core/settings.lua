local M = {}

function M.setup()
  -- Basic editor options
  vim.opt.number = true
  vim.opt.relativenumber = true
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true
  vim.opt.mouse = "a"
  vim.opt.termguicolors = true
  vim.opt.showtabline = 2
  vim.opt.timeoutlen = 300
  vim.opt.ttimeoutlen = 0

  -- Disable unused providers
  vim.g.loaded_perl_provider = 0

  -- Clipboard to system
  vim.schedule(function()
    vim.o.clipboard = "unnamedplus"
  end)

  -- Diagnostics
  vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })

  -- Float styling
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e2e", fg = "#ffffff" })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1e1e2e", fg = "#6c7086" })

  vim.cmd("syntax on")
end

return M
