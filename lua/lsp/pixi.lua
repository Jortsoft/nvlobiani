-- lua/lsp/pixi.lua
local M = {}

local lsp = require("lspconfig")
local common = require("lsp.common")
local uv = vim.uv or vim.loop

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

local function is_windows()
  return vim.loop.os_uname().sysname == "Windows_NT"
end

local function path_exists(path)
  return path and path ~= "" and uv.fs_stat(path) ~= nil
end

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

local function local_node_bin(root_dir, bin_name)
  if not root_dir or root_dir == "" then
    return nil
  end

  local base = root_dir .. "/node_modules/.bin/" .. bin_name

  if is_windows() then
    local cmd = base .. ".cmd"
    if path_exists(cmd) then
      return cmd
    end

    local exe = base .. ".exe"
    if path_exists(exe) then
      return exe
    end
  end

  if path_exists(base) then
    return base
  end

  return nil
end

local function mason_bin(bin_name)
  local base = vim.fn.stdpath("data") .. "/mason/bin/" .. bin_name

  if is_windows() then
    local cmd = base .. ".cmd"
    if path_exists(cmd) then
      return cmd
    end

    local exe = base .. ".exe"
    if path_exists(exe) then
      return exe
    end
  end

  if path_exists(base) then
    return base
  end

  return nil
end

local function system_bin(bin_name)
  local bin = vim.fn.exepath(bin_name)
  if bin and bin ~= "" then
    return bin
  end
  return nil
end

local function resolve_ts_cmd(root_dir)
  local local_bin = local_node_bin(root_dir, "typescript-language-server")
  if local_bin then
    return { local_bin, "--stdio" }
  end

  local m_bin = mason_bin("typescript-language-server")
  if m_bin then
    return { m_bin, "--stdio" }
  end

  local global_bin = system_bin("typescript-language-server")
  if global_bin then
    return { global_bin, "--stdio" }
  end

  if system_bin("npx") then
    return { "npx", "typescript-language-server", "--stdio" }
  end

  return nil
end

local function resolve_eslint_cmd(root_dir)
  local local_bin = local_node_bin(root_dir, "vscode-eslint-language-server")
  if local_bin then
    return { local_bin, "--stdio" }
  end

  local m_bin = mason_bin("vscode-eslint-language-server")
  if m_bin then
    return { m_bin, "--stdio" }
  end

  local global_bin = system_bin("vscode-eslint-language-server")
  if global_bin then
    return { global_bin, "--stdio" }
  end

  if system_bin("npx") then
    return { "npx", "vscode-eslint-language-server", "--stdio" }
  end

  return nil
end

local function set_dynamic_cmd(resolver)
  return function(new_config, new_root_dir)
    local cmd = resolver(new_root_dir or vim.fn.getcwd())
    if cmd then
      new_config.cmd = cmd
    end
  end
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

  local initial_ts_cmd = resolve_ts_cmd(vim.fn.getcwd())
  if not initial_ts_cmd then
    vim.notify(
      "TypeScript language server executable not found. Install Mason package 'typescript-language-server' or add it to project dependencies.",
      vim.log.levels.WARN
    )
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
    cmd = initial_ts_cmd,
    on_new_config = set_dynamic_cmd(resolve_ts_cmd),
  })

  local eslint_cmd = resolve_eslint_cmd(vim.fn.getcwd())
  if lsp.eslint and type(lsp.eslint.setup) == "function" and eslint_cmd then
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
      cmd = eslint_cmd,
      on_new_config = set_dynamic_cmd(resolve_eslint_cmd),
    })
    has_eslint = true
  else
    has_eslint = false
    if lsp.eslint and type(lsp.eslint.setup) == "function" then
      vim.notify(
        "ESLint language server executable not found. Install Mason package 'eslint-lsp' or add it to project dependencies.",
        vim.log.levels.WARN
      )
    else
      vim.notify("ESLint LSP not available (install eslint)", vim.log.levels.WARN)
    end
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
