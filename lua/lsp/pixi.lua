-- lua/lsp/pixi.lua
local M = {}

local lsp = require("lspconfig")
local common = require("lsp.common")

local configured = false
local ts_server_name = nil
local has_eslint = false

local supported_filetypes = {
  javascript = true,
  ["javascriptreact"] = true,
  ["javascript.jsx"] = true,
  typescript = true,
  ["typescriptreact"] = true,
  ["typescript.tsx"] = true,
}

local function root(fname)
  local found = vim.fs.find({
    "package.json",
    "tsconfig.json",
    "jsconfig.json",
    "pnpm-workspace.yaml",
    "yarn.lock",
    "package-lock.json",
    "bun.lock",
    "bun.lockb",
    ".git",
  }, { upward = true, path = fname })[1]

  return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

function M.setup()
  if configured then
    return true
  end

  local ts = nil
  if lsp.ts_ls and type(lsp.ts_ls.setup) == "function" then
    ts = lsp.ts_ls
    ts_server_name = "ts_ls"
  elseif lsp.tsserver and type(lsp.tsserver.setup) == "function" then
    ts = lsp.tsserver
    ts_server_name = "tsserver"
  end

  if not ts then
    vim.notify("TypeScript LSP not available (install ts_ls or tsserver)", vim.log.levels.WARN)
    return false
  end

  ts.setup({
    capabilities = common.capabilities,
    on_attach = common.on_attach,
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    root_dir = root,
    single_file_support = true,
  })

  if lsp.eslint and type(lsp.eslint.setup) == "function" then
    lsp.eslint.setup({
      capabilities = common.capabilities,
      on_attach = function(client, bufnr)
        -- Keep formatting on save on ts_ls/tsserver to avoid formatter conflicts.
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        common.on_attach(client, bufnr)
      end,
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
      root_dir = root,
    })
    has_eslint = true
  else
    has_eslint = false
    vim.notify("ESLint LSP not available (install eslint)", vim.log.levels.WARN)
  end

  configured = true
  return true
end

function M.start_for_buffer(bufnr, opts)
  bufnr = bufnr or 0

  if not M.setup() then
    return false
  end

  local ft = vim.bo[bufnr].filetype
  if not supported_filetypes[ft] then
    if not (opts and opts.silent) then
      vim.notify("Pixi mode enabled. Open a JS/TS file to attach LSP.", vim.log.levels.INFO)
    end
    return true
  end

  if ts_server_name then
    pcall(vim.cmd, "LspStart " .. ts_server_name)
  end
  if has_eslint then
    pcall(vim.cmd, "LspStart eslint")
  end

  return true
end

return M
