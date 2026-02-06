-- lua/lsp/common.lua
local M = {}

function M.setup()
  local caps = vim.lsp.protocol.make_client_capabilities()
  caps = require("cmp_nvim_lsp").default_capabilities(caps)

  M.capabilities = caps

  M.on_attach = function(client, bufnr)
    local map = function(lhs, rhs)
      vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true })
    end

    map("gd", vim.lsp.buf.definition)
    map("gr", vim.lsp.buf.references)
    map("K", vim.lsp.buf.hover)
    map("<leader>rn", vim.lsp.buf.rename)
    map("<leader>ca", vim.lsp.buf.code_action)

    local supports_format = false
    if client.supports_method then
      supports_format = client:supports_method("textDocument/formatting")
    elseif client.server_capabilities then
      supports_format = client.server_capabilities.documentFormattingProvider
    end

    if supports_format then
      local group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = false })
      vim.api.nvim_clear_autocmds({ group = group, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = group,
        buffer = bufnr,
        callback = function()
          vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
        end,
        desc = "Format on save",
      })
    end
  end
end

return M
