-- lua/lsp/vue.lua
local M = {}
local lsp = require("lspconfig")
local common = require("lsp.common")

function M.setup()
  local root = function(fname)
    local found = vim.fs.find({ "package.json", "vue.config.js" }, { upward = true, path = fname })[1]
    return found and vim.fs.dirname(found)
  end

  local volar = lsp.volar or lsp.vue_ls
  if not volar or type(volar.setup) ~= "function" then
    vim.notify("Vue LSP not available (volar/vue_ls not found)", vim.log.levels.WARN)
  else
    -- Vue Language Server (Volar)
    volar.setup({
      capabilities = common.capabilities,
      on_attach = common.on_attach,
      filetypes = { "vue", "typescript", "javascript", "typescriptreact" },
      root_dir = root,
      init_options = {
        typescript = {
          tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib",
        },
        vue = {
          hybridMode = false,
        },
      },
    })
  end

  -- TypeScript with Vue plugin
  local tsserver = lsp.tsserver or lsp.ts_ls
  if not tsserver or type(tsserver.setup) ~= "function" then
    vim.notify("TypeScript LSP not available (tsserver/ts_ls not found)", vim.log.levels.WARN)
    return
  end

  tsserver.setup({
    capabilities = common.capabilities,
    on_attach = common.on_attach,
    filetypes = { "typescript", "javascript", "typescriptreact", "vue" },
    root_dir = root,
    init_options = {
      plugins = {
        {
          name = "@vue/typescript-plugin",
          location = vim.fn.getcwd() .. "/node_modules/@vue/typescript-plugin",
          languages = { "vue" },
        },
      },
    },
  })
end

return M
