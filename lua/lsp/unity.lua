-- lua/lsp/unity.lua
local M = {}

local common = require("lsp.common")

local configured = false
local client_config = nil

-- Find correct OmniSharp command. Returns cmd list or nil.
local function find_omnisharp_cmd()
  -- 1) Mason registry (preferred)
  local ok, registry = pcall(require, "mason-registry")
  if ok then
    local ok_pkg, pkg = pcall(registry.get_package, "omnisharp")
    if ok_pkg and pkg and pkg.is_installed and pkg:is_installed() then
      local base = nil
      if pkg.get_install_path then
        base = pkg:get_install_path()
      elseif pkg.install_path then
        base = pkg.install_path
      elseif pkg.path then
        base = pkg.path
      end

      if base then
        base = base .. "/"
      end

      if base then
        local candidates = {
          base .. "OmniSharp",
          base .. "omnisharp",
          base .. "OmniSharp.exe",
          base .. "omnisharp.exe",
          base .. "omnisharp.cmd",
          base .. "bin/OmniSharp",
          base .. "bin/omnisharp",
          base .. "bin/OmniSharp.exe",
          base .. "bin/omnisharp.exe",
        }
        for _, path in ipairs(candidates) do
          if vim.uv.fs_stat(path) then
            return { path }
          end
        end

        local dll_candidates = {
          base .. "OmniSharp.dll",
          base .. "omnisharp.dll",
          base .. "bin/OmniSharp.dll",
          base .. "bin/omnisharp.dll",
        }
        for _, path in ipairs(dll_candidates) do
          if vim.uv.fs_stat(path) then
            return { "dotnet", path }
          end
        end
      end
    end
  end

  -- 2) Fallback to well-known Mason path
  local base = vim.fn.stdpath("data") .. "/mason/packages/omnisharp/"
  local candidates = {
    base .. "OmniSharp",
    base .. "omnisharp",
    base .. "OmniSharp.exe",
    base .. "omnisharp.exe",
    base .. "omnisharp.cmd",
    base .. "bin/OmniSharp",
    base .. "bin/omnisharp",
    base .. "bin/OmniSharp.exe",
    base .. "bin/omnisharp.exe",
  }
  for _, path in ipairs(candidates) do
    if vim.uv.fs_stat(path) then
      return { path }
    end
  end

  local dll_candidates = {
    base .. "OmniSharp.dll",
    base .. "omnisharp.dll",
    base .. "bin/OmniSharp.dll",
    base .. "bin/omnisharp.dll",
  }
  for _, path in ipairs(dll_candidates) do
    if vim.uv.fs_stat(path) then
      return { "dotnet", path }
    end
  end

  -- 3) Fallback to PATH
  local exe = vim.fn.exepath("omnisharp")
  if exe ~= "" then
    return { exe }
  end

  return nil
end

-- Find Unity project root
local function unity_root(fname)
  if not fname or fname == "" then
    return nil
  end

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

  return nil
end

local function ensure_cs_buf(bufnr)
  bufnr = bufnr or 0
  if vim.bo[bufnr].filetype ~= "cs" then
    return false, "Not a C# buffer"
  end

  local fname = vim.api.nvim_buf_get_name(bufnr)
  if fname == "" then
    return false, "Buffer has no file path (save the file first)"
  end

  local root = unity_root(fname)
  if not root then
    return false, "Unity project root not found (open inside a Unity project)"
  end

  return true, root
end

function M.setup()
  if configured then
    return true
  end

  local omnisharp_cmd = find_omnisharp_cmd()
  if not omnisharp_cmd then
    vim.notify(
      "OmniSharp not found. Install via :Mason (package: omnisharp), then restart Neovim.",
      vim.log.levels.ERROR
    )
    return false
  end

  -- If using the .dll, ensure dotnet exists on PATH (common on Windows)
  if omnisharp_cmd[1] == "dotnet" and vim.fn.exepath("dotnet") == "" then
    vim.notify("dotnet not found on PATH. Install .NET SDK or use the OmniSharp exe.", vim.log.levels.ERROR)
    return false
  end

  local caps = vim.deepcopy(common.capabilities or {})
  caps.workspace = caps.workspace or {}
  caps.workspace.workspaceFolders = false

  client_config = {
    name = "omnisharp",
    cmd = vim.tbl_flatten({
      omnisharp_cmd,
      "-z",
      "--languageserver",
      "--hostPID",
      tostring(vim.fn.getpid()),
      "DotNet:enablePackageRestore=false",
      "--unity",
      "--encoding",
      "utf-8",
    }),

    capabilities = caps,
    on_attach = function(client, bufnr)
      client.server_capabilities.documentFormattingProvider = true
      client.server_capabilities.documentRangeFormattingProvider = true
      common.on_attach(client, bufnr)
      vim.notify("Unity C# LSP (OmniSharp) attached")
    end,

    root_dir = unity_root,

    settings = {
      FormattingOptions = {
        EnableEditorConfigSupport = true,
        OrganizeImports = true,
      },
      MsBuild = {},
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = true,
        EnableImportCompletion = true,
      },
      Sdk = {
        IncludePrereleases = true,
      },
    },
  }

  configured = true
  return true
end

function M.start_for_buffer(bufnr, opts)
  local ok, info = ensure_cs_buf(bufnr)
  if not ok then
    if not (opts and opts.silent) then
      vim.notify("Unity LSP: " .. info, vim.log.levels.WARN)
    end
    return false
  end

  if not M.setup() then
    return false
  end

  local cfg = vim.deepcopy(client_config or {})
  cfg.root_dir = info

  local client_id = vim.lsp.start(cfg, { bufnr = bufnr or 0 })
  if not client_id then
    vim.notify("Unity LSP: failed to start OmniSharp", vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.autostart()
  local group = vim.api.nvim_create_augroup("UnityLspAuto", { clear = true })
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "FileType" }, {
    group = group,
    pattern = { "*.cs", "cs" },
    callback = function(args)
      M.start_for_buffer(args.buf, { silent = true })
    end,
    desc = "Auto-start OmniSharp for Unity projects",
  })
end

return M
