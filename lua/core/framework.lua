local M = {}

-- Angular/Vue current framework
vim.g.current_framework = vim.g.current_framework or "angular"

local function setup_angular_autocmds()
  vim.cmd([[
    augroup AngularSetup
      autocmd!
      autocmd BufRead,BufNewFile *.component.html set filetype=angular.html
      autocmd BufRead,BufNewFile *.html set filetype=html
      autocmd FileType angular.html syntax match ngLet /@let\s\+\w\+/
      autocmd FileType angular.html syntax match ngFor /@for\s\+(.*)\s+{/
      autocmd FileType angular.html highlight link ngLet Keyword
      autocmd FileType angular.html highlight link ngFor Repeat
    augroup END
  ]])
end

local function setup_vue_autocmds()
  vim.cmd([[
    augroup VueSetup
      autocmd!
      autocmd BufRead,BufNewFile *.vue set filetype=vue
      autocmd FileType vue syntax sync fromstart
    augroup END
  ]])
end

local function set_framework(framework)
  framework = framework:lower()
  if framework == "angular" then
    vim.g.current_framework = "angular"
    vim.cmd("augroup VueSetup | autocmd! | augroup END")
    setup_angular_autocmds()
    -- Force-load Angular plugins and restart LSP
    pcall(vim.cmd, "silent! Lazy load yats.vim emmet-vim")
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    pcall(function() require("lsp.angular").setup() end)
    vim.notify("Switched to Angular framework", vim.log.levels.INFO)
  elseif framework == "vue" then
    vim.g.current_framework = "vue"
    vim.cmd("augroup AngularSetup | autocmd! | augroup END")
    setup_vue_autocmds()
    -- Force-load Vue plugins and restart LSP
    pcall(vim.cmd, "silent! Lazy load vim-vue emmet-vim")
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    pcall(function() require("lsp.vue").setup() end)
    vim.notify("Switched to Vue framework", vim.log.levels.INFO)
  else
    vim.notify("Unknown framework: " .. framework, vim.log.levels.ERROR)
  end
end

function M.setup()
  -- Init with Angular by default
  setup_angular_autocmds()

  -- Auto-start Unity LSP when opening C# files inside a Unity project
  pcall(function() require("lsp.unity").autostart() end)

  -- Auto-initialize framework on startup (lazy-load framework plugins)
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.defer_fn(function()
        if vim.g.current_framework == "angular" then
          pcall(vim.cmd, "silent! Lazy load yats.vim emmet-vim")
        elseif vim.g.current_framework == "vue" then
          pcall(vim.cmd, "silent! Lazy load vim-vue emmet-vim")
        end
        vim.notify(string.format("Framework: %s", vim.g.current_framework:upper()), vim.log.levels.INFO)
      end, 100)
    end,
    desc = "Initialize framework plugins on startup",
  })

  -- :Framework angular|vue
  vim.api.nvim_create_user_command("Framework", function(opts)
    set_framework(opts.args)
  end, {
    nargs = 1,
    complete = function() return { "angular", "vue" } end,
  })

  -- :SetLanguage angular|vue|unity
  vim.api.nvim_create_user_command("SetLanguage", function(opts)
    local lang = opts.args:lower()
    if lang == "angular" or lang == "vue" then
      set_framework(lang)
    elseif lang == "unity" then
      local ok = require("lsp.unity").start_for_buffer(0)
      if ok then
        vim.notify("Unity / C# LSP enabled (OmniSharp)", vim.log.levels.INFO)
      end
    else
      vim.notify("Unknown language: " .. lang, vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function() return { "angular", "vue", "unity" } end,
  })

  -- Shortcuts
  vim.keymap.set("n", "<leader>la", ":Framework angular<CR>", { desc = "Switch to Angular", nowait = true })
  vim.keymap.set("n", "<leader>lv", ":Framework vue<CR>", { desc = "Switch to Vue", nowait = true })
  vim.keymap.set("n", "<leader>lu", ":SetLanguage unity<CR>", { desc = "Enable Unity LSP", nowait = true })
end

return M
