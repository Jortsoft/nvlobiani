-- lua/lsp/unity.lua
local M = {}

local lsp = require("lspconfig")
local common = require("lsp.common")

-- Find correct OmniSharp binary installed by Mason
local function find_omnisharp()
  local base = vim.fn.stdpath("data") .. "/mason/packages/omnisharp/"
  local bin1 = base .. "omnisharp"
  local bin2 = base .. "OmniSharp"

  if vim.uv.fs_stat(bin1) then return bin1 end
  if vim.uv.fs_stat(bin2) then return bin2 end

  vim.notify("❌ OmniSharp not found in Mason!", vim.log.levels.ERROR)
  return nil
end

-- Find Unity project root
local function unity_root(fname)
  local project_settings = vim.fs.find("ProjectSettings/ProjectSettings.asset", { upward = true, path = fname })[1]
  if project_settings then
    return vim.fs.dirname(vim.fs.dirname(project_settings))
  end

  local manifest = vim.fs.find("Packages/manifest.json", { upward = true, path = fname })[1]
  if manifest then
    return vim.fs.dirname(vim.fs.dirname(manifest))
  end

  local assets = vim.fs.find("Assets", { upward = true, path = fname })[1]
  if assets then
    return vim.fs.dirname(assets)
  end

  local sln = vim.fs.find(function(name, _)
    return name:match("%.sln$")
  end, { upward = true, path = fname })[1]
  if sln then
    return vim.fs.dirname(sln)
  end

  local csproj = vim.fs.find(function(name, _)
    return name:match("%.csproj$")
  end, { upward = true, path = fname })[1]
  if csproj then
    return vim.fs.dirname(csproj)
  end

  return vim.fn.getcwd()
end

function M.setup()
  local omnisharp_bin = find_omnisharp()
  if not omnisharp_bin then return end

  lsp.omnisharp.setup({
    cmd = {
      omnisharp_bin,
      "--languageserver",
      "--hostPID",
      tostring(vim.fn.getpid()),
      "--unity",
      "--encoding",
      "utf-8",
    },

    capabilities = common.capabilities,
    on_attach = function(client, bufnr)
      -- Force-enable formatting for OmniSharp
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.documentRangeFormattingProvider = true

      -- Use shared keymaps
      common.on_attach(client, bufnr)

      vim.notify("🔥 Unity C# LSP (OmniSharp) attached")
    end,

    root_dir = unity_root,

    enable_roslyn_analyzers = true,
    enable_import_completion = true,
    organize_imports_on_format = true,
  })

end

return M
