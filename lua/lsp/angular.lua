-- lua/lsp/angular.lua
local M = {}
local lsp = require("lspconfig")
local common = require("lsp.common")

-- find Angular LS
local function find_ngserver(root)
  local local_path = root .. "/node_modules/@angular/language-server/bin/ngserver"
  if vim.uv.fs_stat(local_path) then
    return {
      "node",
      local_path,
      "--stdio",
      "--tsProbeLocations",
      root .. "/node_modules",
      "--ngProbeLocations",
      root .. "/node_modules",
    }
  end

  return { "npx", "@angular/language-server", "--stdio" }
end

function M.setup()
  local root = function(fname)
    local found = vim.fs.find({ "angular.json", "nx.json" }, { upward = true, path = fname })[1]
    return found and vim.fs.dirname(found)
  end

  if not lsp.angularls then
    vim.notify("Angular LSP not available (angularls not found)", vim.log.levels.WARN)
    return
  end

  lsp.angularls.setup({
    capabilities = common.capabilities,
    on_attach = common.on_attach,
    filetypes = { "typescript", "html", "typescriptreact" },
    root_dir = root,
    cmd = function(fname)
      local r = root(fname) or vim.fn.getcwd()
      return find_ngserver(r)
    end
  })

  -- TypeScript support
  local tsserver = lsp.tsserver or lsp.ts_ls
  if not tsserver or type(tsserver.setup) ~= "function" then
    vim.notify("TypeScript LSP not available (tsserver/ts_ls not found)", vim.log.levels.WARN)
    return
  end

  tsserver.setup({
    capabilities = common.capabilities,
    on_attach = common.on_attach,
    root_dir = function(fname)
      local found = vim.fs.find({ "tsconfig.json", "package.json" }, { upward = true, path = fname })[1]
      return found and vim.fs.dirname(found)
    end
  })
end

return M
