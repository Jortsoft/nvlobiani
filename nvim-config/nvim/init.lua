-- ===================================================================
-- JORTSOFT NEOVIM CONFIGURATION
-- A clean, well-organized Neovim setup with modern plugins
-- Now with framework switching support (Angular/Vue)
-- ===================================================================

-- ===================================================================
-- FRAMEWORK CONFIGURATION STATE
-- ===================================================================
vim.g.current_framework = vim.g.current_framework or "angular" -- Default framework, persists across sessions

-- Auto-initialize framework on startup
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Ensure plugins are loaded for the current framework
    vim.defer_fn(function()
      if vim.g.current_framework == "angular" then
        vim.cmd("silent! Lazy load yats.vim emmet-vim")
      elseif vim.g.current_framework == "vue" then
        vim.cmd("silent! Lazy load vim-vue emmet-vim")
      end
      vim.notify(string.format("🚀 Framework: %s", vim.g.current_framework:upper()), vim.log.levels.INFO)
    end, 100)
  end,
  desc = "Initialize framework plugins on startup"
})

-- ===================================================================
-- BASIC SETTINGS
-- ===================================================================

-- General editor settings
vim.o.number = true              -- Show line numbers
vim.o.relativenumber = true      -- Show relative line numbers
vim.o.mouse = "a"                -- Enable mouse support
vim.o.termguicolors = true       -- Enable 24-bit RGB colors
vim.o.showtabline = 2            -- Always show tabline
vim.g.mapleader = " "            -- Set space as leader key
vim.o.timeoutlen = 300           -- Faster key sequence completion (default is 1000ms)
vim.o.ttimeoutlen = 0            -- Make ESC instantaneous

-- Disable providers we don't need
vim.g.loaded_perl_provider = 0

-- Set clipboard to system clipboard (delayed to avoid startup issues)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

-- Function to setup Angular-specific autocmds
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

-- Function to setup Vue-specific autocmds
local function setup_vue_autocmds()
  vim.cmd([[
    augroup VueSetup
      autocmd!
      autocmd BufRead,BufNewFile *.vue set filetype=vue
      autocmd FileType vue syntax sync fromstart
    augroup END
  ]])
end

-- Initialize with Angular by default
setup_angular_autocmds()

vim.notify("Open file manager with <leader>j", vim.log.levels.INFO)

vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#1e1e2e", fg = "#ffffff" })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#1e1e2e", fg = "#6c7086" })

-- ===================================================================
-- BREAK REMINDER SYSTEM
-- ===================================================================

-- Motivational messages for break reminders
local break_messages = {
  {
    "🚨 Your keyboard is crying.",
    "💧 Give it a break before it files a complaint.",
    "🧠 Go touch some grass."
  },
  {
    "🦍 Brain cells have left the chat.",
    "🛌 Reboot yourself outside for 5 mins.",
    "🧘‍♂️ Zen mode: ON."
  },
  {
    "🧟‍♂️ You're starting to look like a semicolon.",
    "📴 Unplug yourself and stretch a bit.",
    "🍵 Tea time, legend."
  },
  {
    "🚀 Coding power at 1%.",
    "🔋 Please charge with fresh air.",
    "😮‍💨 Alt+F4 life temporarily."
  },
  {
    "🥴 You've been in the matrix for too long.",
    "🕶️ Neo took a walk. You should too.",
    "🌳 Touch a tree. Or at least imagine one."
  },
  {
    "🧠 Brain overheating!",
    "🌬️ Cooling required: Walk, breathe, smile.",
    "🧃 Grab a juice. Or pretend you have one."
  }
}

vim.api.nvim_create_user_command("GitConflictDiff", function()
  vim.cmd("windo diffthis")
end, { desc = "Enable diff mode in all open windows" })

-- Function to display break reminder in floating window
local function show_break_message()
  local msg = break_messages[math.random(#break_messages)]
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, msg)

  local width = 50
  local height = #msg
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    col = vim.o.columns - width - 2,
    row = 2,
    style = "minimal",
    border = "rounded"
  }

  local win = vim.api.nvim_open_win(buf, false, opts)

  -- Auto-close after 5 seconds
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 5000)
end

-- Start break reminder timer (every 40 minutes)
local break_timer = vim.loop.new_timer()
break_timer:start(
  40 * 60 * 1000,    -- Initial delay: 40 minutes
  40 * 60 * 1000,    -- Repeat every: 40 minutes
  vim.schedule_wrap(show_break_message)
)

-- ===================================================================
-- DIAGNOSTIC CONFIGURATION
-- ===================================================================

vim.diagnostic.config({
  virtual_text = true,      -- Show inline error messages
  signs = true,             -- Show error signs in gutter
  underline = true,         -- Underline errors
  update_in_insert = false, -- Don't update diagnostics in insert mode
  severity_sort = true,     -- Sort by severity
})

-- ===================================================================
-- FRAMEWORK SWITCHING SYSTEM
-- ===================================================================

-- Framework-specific LSP setup functions (will be populated after plugins load)
vim.g.setup_angular_lsp = function() end
vim.g.setup_vue_lsp = function() end

-- Main framework switching command
vim.api.nvim_create_user_command("Framework", function(opts)
  local framework = opts.args:lower()
  
  if framework == "angular" then
    vim.g.current_framework = "angular"
    
    -- Clear Vue autocmds and set Angular ones
    vim.cmd("augroup VueSetup | autocmd! | augroup END")
    setup_angular_autocmds()
    
    -- Force load Angular-related plugins
    vim.cmd("Lazy load yats.vim emmet-vim")
    
    -- Stop all LSP clients
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    
    -- Setup Angular LSP
    vim.schedule(function()
      if vim.g.setup_angular_lsp then
        vim.g.setup_angular_lsp()
      end
      vim.notify("🅰️ Switched to Angular configuration", vim.log.levels.INFO)
      vim.notify("LSP servers restarted for Angular", vim.log.levels.INFO)
    end)
    
  elseif framework == "vue" then
    vim.g.current_framework = "vue"
    
    -- Clear Angular autocmds and set Vue ones
    vim.cmd("augroup AngularSetup | autocmd! | augroup END")
    setup_vue_autocmds()
    
    -- Force load Vue-related plugins
    vim.cmd("Lazy load vim-vue emmet-vim")
    
    -- Stop all LSP clients
    vim.lsp.stop_client(vim.lsp.get_active_clients())
    
    -- Setup Vue LSP
    vim.schedule(function()
      if vim.g.setup_vue_lsp then
        vim.g.setup_vue_lsp()
      end
      vim.notify("✌️ Switched to Vue configuration", vim.log.levels.INFO)
      vim.notify("LSP servers restarted for Vue", vim.log.levels.INFO)
    end)
    
  else
    vim.notify("❌ Invalid framework. Use: Framework angular or Framework vue", vim.log.levels.ERROR)
  end
end, {
  nargs = 1,
  complete = function()
    return { "angular", "vue" }
  end,
  desc = "Set framework configuration (angular or vue)"
})

-- Alternative syntax with 'set language=' for convenience
vim.api.nvim_create_user_command("SetLanguage", function(opts)
  vim.cmd("Framework " .. opts.args)
end, {
  nargs = 1,
  complete = function()
    return { "angular", "vue" }
  end,
  desc = "Set language/framework (angular or vue)"
})

-- ===================================================================
-- GIT CHANGES VIEWER WITH DISCARD OPTIONS
-- ===================================================================

-- Function to show git changes in a floating window
local function show_git_changes()
  -- Get git status
  local git_status = vim.fn.systemlist("git status --porcelain")
  
  if #git_status == 0 then
    vim.notify("✨ No changes in working directory", vim.log.levels.INFO)
    return
  end
  
  -- Parse git status
  local changes = {}
  for _, line in ipairs(git_status) do
    local status = line:sub(1, 2)
    local file = line:sub(4)
    
    local status_text = ""
    if status:match("M") then
      status_text = "Modified"
    elseif status:match("A") then
      status_text = "Added"
    elseif status:match("D") then
      status_text = "Deleted"
    elseif status:match("R") then
      status_text = "Renamed"
    elseif status:match("??") then
      status_text = "Untracked"
    else
      status_text = "Changed"
    end
    
    table.insert(changes, {
      file = file,
      status = status,
      status_text = status_text
    })
  end
  
  -- Create choices for selection
  local choices = {}
  for _, change in ipairs(changes) do
    table.insert(choices, {
      label = string.format("[%s] %s", change.status_text, change.file),
      file = change.file,
      status = change.status
    })
  end
  
  -- Add option to discard all
  table.insert(choices, {
    label = "🗑️ Discard ALL changes",
    action = "discard_all"
  })
  
  table.insert(choices, {
    label = "❌ Cancel",
    action = "cancel"
  })
  
  -- Show selection menu
  vim.ui.select(choices, {
    prompt = "Select file to view/discard changes:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if not choice then return end
    
    if choice.action == "cancel" then
      return
    elseif choice.action == "discard_all" then
      -- Confirm before discarding all
      vim.ui.select(
        { "Yes, discard all", "No, cancel" },
        { prompt = "⚠️ Discard ALL changes? This cannot be undone!" },
        function(confirm)
          if confirm == "Yes, discard all" then
            vim.fn.system("git checkout -- .")
            vim.fn.system("git clean -fd")
            vim.notify("🗑️ All changes discarded", vim.log.levels.WARN)
            vim.cmd("checktime")  -- Reload all buffers
          end
        end
      )
    else
      -- Show diff for selected file
      show_file_diff(choice.file, choice.status)
    end
  end)
end

-- Function to show diff for a specific file
function show_file_diff(file, status)
  if status:match("??") then
    -- For untracked files, show content
    local content = vim.fn.readfile(file)
    
    -- Create floating window to show content
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
    vim.api.nvim_buf_set_option(buf, 'filetype', vim.fn.fnamemodify(file, ':e'))
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    local width = math.min(100, vim.o.columns - 10)
    local height = math.min(30, vim.o.lines - 10)
    
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      col = (vim.o.columns - width) / 2,
      row = (vim.o.lines - height) / 2,
      style = "minimal",
      border = "rounded",
      title = " 📄 Untracked: " .. file .. " ",
      title_pos = "center"
    })
    
    -- Set keymaps for the floating window
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', 'd', '', {
      noremap = true,
      silent = true,
      callback = function()
        vim.ui.select(
          { "Yes, delete file", "No, keep file" },
          { prompt = "Delete untracked file?" },
          function(confirm)
            if confirm == "Yes, delete file" then
              vim.fn.delete(file)
              vim.notify("🗑️ Deleted: " .. file, vim.log.levels.WARN)
              vim.api.nvim_win_close(win, true)
              show_git_changes()  -- Refresh the list
            end
          end
        )
      end,
      desc = "Delete untracked file"
    })
    
    vim.notify("Press 'q' to close, 'd' to delete file", vim.log.levels.INFO)
  else
    -- For tracked files, show git diff
    local diff = vim.fn.systemlist("git diff " .. file)
    
    if #diff == 0 then
      diff = vim.fn.systemlist("git diff --cached " .. file)
    end
    
    if #diff == 0 then
      vim.notify("No changes to display for " .. file, vim.log.levels.INFO)
      return
    end
    
    -- Create floating window for diff
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, diff)
    vim.api.nvim_buf_set_option(buf, 'filetype', 'diff')
    vim.api.nvim_buf_set_option(buf, 'modifiable', false)
    
    local width = math.min(100, vim.o.columns - 10)
    local height = math.min(30, vim.o.lines - 10)
    
    local win = vim.api.nvim_open_win(buf, true, {
      relative = "editor",
      width = width,
      height = height,
      col = (vim.o.columns - width) / 2,
      row = (vim.o.lines - height) / 2,
      style = "minimal",
      border = "rounded",
      title = " 🔍 Changes: " .. file .. " ",
      title_pos = "center"
    })
    
    -- Set keymaps for the floating window
    vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, 'n', 'd', '', {
      noremap = true,
      silent = true,
      callback = function()
        vim.ui.select(
          { "Yes, discard changes", "No, keep changes" },
          { prompt = "Discard changes to " .. file .. "?" },
          function(confirm)
            if confirm == "Yes, discard changes" then
              vim.fn.system("git checkout -- " .. vim.fn.shellescape(file))
              vim.notify("🗑️ Changes discarded: " .. file, vim.log.levels.WARN)
              vim.api.nvim_win_close(win, true)
              
              -- Reload the file if it's open
              for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
                if vim.api.nvim_buf_get_name(buf_id):match(file) then
                  vim.api.nvim_buf_call(buf_id, function()
                    vim.cmd("edit!")
                  end)
                end
              end
              
              show_git_changes()  -- Refresh the list
            end
          end
        )
      end,
      desc = "Discard changes"
    })
    
    vim.api.nvim_buf_set_keymap(buf, 'n', 'D', '', {
      noremap = true,
      silent = true,
      callback = function()
        vim.fn.system("git checkout -- " .. vim.fn.shellescape(file))
        vim.notify("🗑️ Changes discarded: " .. file, vim.log.levels.WARN)
        vim.api.nvim_win_close(win, true)
        
        -- Reload the file if it's open
        for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_get_name(buf_id):match(file) then
            vim.api.nvim_buf_call(buf_id, function()
              vim.cmd("edit!")
            end)
          end
        end
        
        show_git_changes()  -- Refresh the list
      end,
      desc = "Discard without confirmation"
    })
    
    vim.notify("Press 'q' to close, 'd' to discard (with confirm), 'D' to discard immediately", vim.log.levels.INFO)
  end
end

-- Create commands for git operations
vim.api.nvim_create_user_command("ShowChanges", show_git_changes, { desc = "Show git changes with discard options" })
vim.api.nvim_create_user_command("GitChanges", show_git_changes, { desc = "Show git changes with discard options" })

vim.api.nvim_create_user_command("DiscardAll", function()
  vim.ui.select(
    { "Yes, discard all", "No, cancel" },
    { prompt = "⚠️ Discard ALL changes? This cannot be undone!" },
    function(confirm)
      if confirm == "Yes, discard all" then
        vim.fn.system("git checkout -- .")
        vim.fn.system("git clean -fd")
        vim.notify("🗑️ All changes discarded", vim.log.levels.WARN)
        vim.cmd("checktime")  -- Reload all buffers
      end
    end
  )
end, { desc = "Discard all git changes" })

vim.api.nvim_create_user_command("DiscardFile", function()
  local file = vim.fn.expand("%:p")
  local relative_file = vim.fn.fnamemodify(file, ":.")
  
  vim.ui.select(
    { "Yes, discard changes", "No, keep changes" },
    { prompt = "Discard changes to " .. relative_file .. "?" },
    function(confirm)
      if confirm == "Yes, discard changes" then
        vim.fn.system("git checkout -- " .. vim.fn.shellescape(relative_file))
        vim.notify("🗑️ Changes discarded: " .. relative_file, vim.log.levels.WARN)
        vim.cmd("edit!")  -- Reload current buffer
      end
    end
  )
end, { desc = "Discard changes in current file" })

-- ===================================================================
-- CUSTOM COMMANDS
-- ===================================================================

-- Command to reload Neovim configuration
vim.api.nvim_create_user_command("Reload", function()
  vim.cmd("source $MYVIMRC")
  vim.cmd("edit")
  vim.notify("🔁 Neovim config reloaded!", vim.log.levels.INFO)
end, {})

-- Commands to install Angular Language Server
vim.api.nvim_create_user_command("AngularInstallLocal", function()
  vim.notify("📦 Installing Angular Language Server locally...", vim.log.levels.INFO)
  vim.fn.system("npm install --save-dev @angular/language-server")
  vim.notify("✅ Angular Language Server installed locally! Restart Neovim.", vim.log.levels.INFO)
end, { desc = "Install Angular Language Server locally" })

vim.api.nvim_create_user_command("AngularInstallGlobal", function()
  vim.notify("🌍 Installing Angular Language Server globally...", vim.log.levels.INFO)
  vim.fn.system("npm install -g @angular/language-server")
  vim.notify("✅ Angular Language Server installed globally! Restart Neovim.", vim.log.levels.INFO)
end, { desc = "Install Angular Language Server globally" })

-- Commands to install Vue Language Server
vim.api.nvim_create_user_command("VueInstallLocal", function()
  vim.notify("📦 Installing Vue Language Server locally...", vim.log.levels.INFO)
  vim.fn.system("npm install --save-dev @vue/language-server @vue/typescript-plugin")
  vim.notify("✅ Vue Language Server installed locally! Restart Neovim.", vim.log.levels.INFO)
end, { desc = "Install Vue Language Server locally" })

vim.api.nvim_create_user_command("VueInstallGlobal", function()
  vim.notify("🌍 Installing Vue Language Server globally...", vim.log.levels.INFO)
  vim.fn.system("npm install -g @vue/language-server @vue/typescript-plugin")
  vim.notify("✅ Vue Language Server installed globally! Restart Neovim.", vim.log.levels.INFO)
end, { desc = "Install Vue Language Server globally" })

-- Check current framework configuration
vim.api.nvim_create_user_command("FrameworkStatus", function()
  local framework = vim.g.current_framework or "none"
  local active_clients = vim.lsp.get_active_clients()
  local client_names = {}
  
  for _, client in ipairs(active_clients) do
    table.insert(client_names, client.name)
  end
  
  vim.notify(string.format("🔧 Current framework: %s\n📡 Active LSP servers: %s", 
    framework:upper(), 
    table.concat(client_names, ", ")
  ), vim.log.levels.INFO)
end, { desc = "Show current framework configuration" })

vim.api.nvim_create_user_command("AngularCheck", function()
  local util = require("lspconfig.util")
  local root_dir = util.root_pattern("angular.json", "nx.json", ".git")(vim.fn.getcwd())
  
  if not root_dir then
    vim.notify("❌ Not in an Angular project directory", vim.log.levels.WARN)
    return
  end
  
  local node_modules_path = util.path.join(root_dir, "node_modules")
  local angular_server_path = util.path.join(
    node_modules_path,
    "@angular",
    "language-server",
    "bin",
    "ngserver"
  )
  
  if util.path.exists(angular_server_path) then
    vim.notify("✅ Angular Language Server found locally: " .. angular_server_path, vim.log.levels.INFO)
  else
    vim.notify("❌ Angular Language Server not found locally. Run :AngularInstallLocal", vim.log.levels.WARN)
  end
  
  -- Check global installation
  local global_check = vim.fn.system("npm list -g @angular/language-server --depth=0")
  if vim.v.shell_error == 0 then
    vim.notify("✅ Angular Language Server found globally", vim.log.levels.INFO)
  else
    vim.notify("❌ Angular Language Server not found globally. Run :AngularInstallGlobal", vim.log.levels.WARN)
  end
end, { desc = "Check Angular Language Server installation" })

-- ===================================================================
-- PACKAGE MANAGER SETUP (LAZY.NVIM)
-- ===================================================================

-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ===================================================================
-- PLUGIN CONFIGURATION
-- ===================================================================

require("lazy").setup({

  -- ===============================================================
  -- UI & APPEARANCE
  -- ===============================================================

  -- Custom dashboard with ASCII art
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      -- ASCII art header
      dashboard.section.header.val = {
        "███╗   ██╗██╗   ██╗██╗      ██████╗ ██████╗ ██╗ █████╗ ███╗   ██╗██╗",
        "████╗  ██║██║   ██║██║     ██╔═══██╗██╔══██╗██║██╔══██╗████╗  ██║██║",
        "██╔██╗ ██║██║   ██║██║     ██║   ██║██████╔╝██║███████║██╔██╗ ██║██║",
        "██║╚██╗██║╚██╗ ██╔╝██║     ██║   ██║██╔══██╗██║██╔══██║██║╚██╗██║██║",
        "██║ ╚████║ ╚████╔╝ ███████╗╚██████╔╝██████╔╝██║██║  ██║██║ ╚████║██║",
        "╚═╝  ╚═══╝  ╚═══╝  ╚══════╝ ╚═════╝ ╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═╝",
        "",
        "                   ⚡ Write code and eat Lobiani ⚡                ",
      }

      -- Dashboard buttons
      dashboard.section.buttons.val = {
        dashboard.button("e", "📄  New File", ":ene <BAR> startinsert<CR>"),
        dashboard.button("f", "🔍  Find File", ":Telescope find_files<CR>"),
        dashboard.button("r", "🕘  Recent Files", ":Telescope oldfiles<CR>"),
        dashboard.button("q", "❌  Quit", ":qa<CR>"),
      }

      dashboard.section.footer.val = "🚀 Created by Jortsoft"
      dashboard.opts.opts.noautocmd = true

      alpha.setup(dashboard.opts)
    end,
  },

  -- Emmet for both Angular and Vue
  {
    "mattn/emmet-vim",
    lazy = false,  -- Always load on startup
  },

  -- Status line with real-time clock and timer
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Initialize time tracking variables
      local clock = "🕒 00:00:00"
      local timer_display = "⏱ 00:00"
      local start_time = vim.loop.hrtime()
      
      -- Create timer for real-time updates
      local timer = vim.loop.new_timer()
      timer:start(0, 1000, vim.schedule_wrap(function()
        -- Update real-time clock
        clock = os.date("🕒 %H:%M:%S")

        -- Calculate elapsed session time
        local elapsed_sec = math.floor((vim.loop.hrtime() - start_time) / 1e9)
        local hours = math.floor(elapsed_sec / 3600)
        local minutes = math.floor((elapsed_sec % 3600) / 60)
        local seconds = elapsed_sec % 60

        if hours > 0 then
          timer_display = string.format("⏱ %d:%02d:%02d", hours, minutes, seconds)
        else
          timer_display = string.format("⏱ %02d:%02d", minutes, seconds)
        end

        vim.cmd("redrawstatus")
      end))

      -- Status line configuration
      require("lualine").setup({
        options = {
          theme = "auto",
          section_separators = "",
          component_separators = "",
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { 
            "filename",
            function() 
              return vim.g.current_framework and 
                     string.format("[%s]", vim.g.current_framework:upper()) or ""
            end
          },
          lualine_x = {
            "encoding",
            "fileformat",
            "filetype",
            function() return timer_display end,
            function() return clock end,
          },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Git lens
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 1000,
          ignore_whitespace = false,
        },
        current_line_blame_formatter = '<author> • <author_time:%Y-%m-%d> • <summary>',
      })
    end
  },

  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
          },
        },
        cmdline = {
          view = "cmdline_popup",
          format = {
            cmdline = { icon = "" },
            search_down = { icon = "🔍⌄" },
            search_up = { icon = "🔍⌃" },
          },
        },
        views = {
          cmdline_popup = {
            border = {
              style = "rounded",
              padding = { 0, 1 },
            },
            position = {
              row = 5,
              col = "50%",
            },
            size = {
              width = 60,
              height = "auto",
            },
          },
          popupmenu = {
            relative = "editor",
            border = {
              style = "rounded",
            },
            position = {
              row = 8,
              col = "50%",
            },
            size = {
              width = 60,
              height = 10,
            },
          },
        },
        presets = {
          bottom_search = false,
          command_palette = true,
          long_message_to_split = true,
          inc_rename = true,
          lsp_doc_border = true,
        },
      })
    end,
  },

  {
    "rcarriga/nvim-notify",
    config = function()
      require("notify").setup({
        background_colour = "#1e1e2e",
        stages = "fade",   
        render = "compact",
        timeout = 3000,
      })
    end,
  },

  -- Angular TypeScript support
  {
    "HerringtonDarkholme/yats.vim",
    lazy = false,  -- Always load on startup
  }, 

  -- Vue syntax highlighting
  {
    "posva/vim-vue",
    lazy = false,  -- Always load on startup
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "html",
          "typescript",
          "css",
          "javascript",
          "json",
          "vue",
          "scss",
        },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "vue" },
        },
      })
    end
  },

  -- Buffer line (tab bar)
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          mode = "buffers",
          show_buffer_close_icons = true,
          show_close_icon = false,
          diagnostics = "nvim_lsp",
          separator_style = "slant",
          offsets = {
            {
              filetype = "NvimTree",
              text = "File Explorer",
              highlight = "Directory",
              text_align = "left",
            }
          },
        }
      })
    end,
  },

  -- ===============================================================
  -- COLOR SCHEMES
  -- ===============================================================

  -- Tokyo Night theme
  {
    "folke/tokyonight.nvim",
    name = "tokyonight",
    lazy = false,
    priority = 1000,
  },

  -- Moonfly theme (default)
  {
    "bluz71/vim-moonfly-colors",
    name = "moonfly",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd("colorscheme moonfly")
    end,
  },

  -- Cyberdream theme
  {
    "scottmckendry/cyberdream.nvim",
    name = "cyberdream",
    lazy = false,
    priority = 1000,
  },

  -- One Dark theme with theme switcher command
  {
    "navarasu/onedark.nvim",
    priority = 1000,
    config = function()
      -- Theme switcher command
      vim.api.nvim_create_user_command("Theme", function(opts)
        local style = opts.args:lower()
        
        if style == "onedark" then
          require("onedark").setup({ style = "dark" })
          require("onedark").load()
        elseif style == "onelight" then
          require("onedark").setup({ style = "light" })
          require("onedark").load()
        elseif style == "moonfly" then
          vim.cmd("colorscheme moonfly")
        elseif style == "cyberdream" then
          require("cyberdream").setup({
            transparent = false,
            italic_comments = true,
            hide_fillchars = true,
            borderless_telescope = true,
          })
          vim.cmd("colorscheme cyberdream")
        elseif style == "tokyonight" then
          require("tokyonight").setup({
            style = "storm",
            transparent = false,
            terminal_colors = true,
          })
          vim.cmd("colorscheme tokyonight")
        else
          vim.notify("Invalid theme. Available: onedark, onelight, moonfly, cyberdream, tokyonight", vim.log.levels.ERROR)
        end
      end, {
        nargs = 1,
        complete = function()
          return { "onedark", "onelight", "moonfly", "cyberdream", "tokyonight" }
        end,
      })
    end,
  },

  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = function()
      require("git-conflict").setup()
    end,
  },

  -- ===============================================================
  -- FILE MANAGEMENT
  -- ===============================================================

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- Disable netrw (built-in file explorer)
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      
      require("nvim-tree").setup({
        update_focused_file = {
          enable = true,
          update_cwd = true,
          ignore_list = {},
        },
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          file_ignore_patterns = {
            "node_modules/",
            "%.git/",
            "build/",
            "dist/"
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--glob=!node_modules/**",
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            no_ignore = false,
          }
        }
      })
    end,
  },

  -- ===============================================================
  -- CODING TOOLS
  -- ===============================================================

  -- Comment toggling
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Auto-completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()

      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- LSP Configuration with framework switching
  {
    "neovim/nvim-lspconfig",
    version = "*",
    dependencies = { "b0o/schemastore.nvim" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Helper function to find Angular Language Server
      local function get_angular_ls_cmd(root_dir)
        local util = require("lspconfig.util")
        
        local node_modules_path = util.path.join(root_dir, "node_modules")
        local angular_server_path = util.path.join(
          node_modules_path,
          "@angular",
          "language-server",
          "bin",
          "ngserver"
        )
        
        if util.path.exists(angular_server_path) then
          return {
            "node",
            angular_server_path,
            "--stdio",
            "--tsProbeLocations",
            node_modules_path,
            "--ngProbeLocations", 
            node_modules_path
          }
        end
        
        local global_paths = {
          "/usr/local/lib/node_modules/@angular/language-server/bin/ngserver",
          "/opt/homebrew/lib/node_modules/@angular/language-server/bin/ngserver",
          vim.fn.expand("~/.npm-global/lib/node_modules/@angular/language-server/bin/ngserver"),
          vim.fn.expand("~/.yarn/global/node_modules/@angular/language-server/bin/ngserver"),
          vim.fn.expand("~/.local/share/pnpm/global/5/node_modules/@angular/language-server/bin/ngserver"),
        }
        
        for _, path in ipairs(global_paths) do
          if util.path.exists(path) then
            return {
              "node",
              path,
              "--stdio",
              "--tsProbeLocations",
              node_modules_path,
              "--ngProbeLocations",
              node_modules_path
            }
          end
        end
        
        return {
          "npx",
          "@angular/language-server",
          "--stdio",
          "--tsProbeLocations",
          node_modules_path,
          "--ngProbeLocations",
          node_modules_path
        }
      end

      -- Setup Angular LSP function
      vim.g.setup_angular_lsp = function()
        lspconfig.angularls.setup({
          cmd = function()
            local root_dir = lspconfig.util.root_pattern("angular.json", "nx.json", ".git")(vim.fn.getcwd())
            if root_dir then
              return get_angular_ls_cmd(root_dir)
            end
            return { "npx", "@angular/language-server", "--stdio" }
          end,
          on_new_config = function(new_config, new_root_dir)
            if new_root_dir then
              new_config.cmd = get_angular_ls_cmd(new_root_dir)
            end
            new_config.cmd_env = { NG_LOG_LEVEL = "info" }
          end,
          filetypes = { "html", "typescript", "typescriptreact" },
          root_dir = lspconfig.util.root_pattern("angular.json", "nx.json", ".git"),
          capabilities = capabilities,
          single_file_support = false,
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          end,
        })
        
        -- TypeScript server for Angular
        lspconfig.tsserver.setup({
          capabilities = capabilities,
          root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          end,
        })
      end

      -- Setup Vue LSP function
      vim.g.setup_vue_lsp = function()
        -- Volar (Vue Language Server)
        lspconfig.volar.setup({
          capabilities = capabilities,
          filetypes = { "vue", "typescript", "javascript", "typescriptreact", "javascriptreact" },
          init_options = {
            typescript = {
              tsdk = vim.fn.getcwd() .. "/node_modules/typescript/lib"
            },
            vue = {
              hybridMode = false,
            },
          },
          on_attach = function(client, bufnr)
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          end,
        })

        -- TypeScript server for Vue (with Vue plugin)
        lspconfig.tsserver.setup({
          capabilities = capabilities,
          root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
          init_options = {
            plugins = {
              {
                name = "@vue/typescript-plugin",
                location = vim.fn.getcwd() .. "/node_modules/@vue/typescript-plugin",
                languages = { "vue" },
              },
            },
          },
          filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact", "vue" },
          on_attach = function(client, bufnr)
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
            vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
            vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          end,
        })
      end

      -- Common LSP servers for both frameworks
      local function setup_common_lsp()
        -- CSS/SCSS Language Server
        lspconfig.cssls.setup({ 
          capabilities = capabilities,
          filetypes = { "css", "scss", "less", "vue" }
        })

        -- JSON Language Server
        lspconfig.jsonls.setup({ 
          capabilities = capabilities,
          settings = {
            json = {
              schemas = require('schemastore').json.schemas(),
              validate = { enable = true },
            }
          }
        })

        -- HTML Language Server
        lspconfig.html.setup({ 
          capabilities = capabilities,
          filetypes = { "html", "templ", "vue" }
        })

        -- ESLint
        lspconfig.eslint.setup({
          capabilities = capabilities,
          on_attach = function(client, bufnr)
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              command = "EslintFixAll",
            })
          end,
        })
      end

      -- Setup common LSP servers
      setup_common_lsp()

      -- Initialize with the current framework
      if vim.g.current_framework == "angular" then
        vim.g.setup_angular_lsp()
      elseif vim.g.current_framework == "vue" then
        vim.g.setup_vue_lsp()
      end
    end,
  },

  -- Code formatting
  {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local null_ls = require("null-ls")

      null_ls.setup({
        sources = {
          null_ls.builtins.formatting.prettier.with({
            filetypes = { 
              "html", 
              "css", 
              "scss",
              "javascript", 
              "typescript", 
              "vue",
              "json",
              "yaml",
              "markdown"
            },
          }),
        },
        on_attach = function(client, bufnr)
          if client.supports_method and client:supports_method("textDocument/formatting") then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      })
    end,
  },

  -- ===============================================================
  -- TERMINAL & UTILITIES
  -- ===============================================================

  -- Floating terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      -- Detect operating system and set appropriate shell
      local sysname = vim.loop.os_uname().sysname
      local shell = sysname == "Windows_NT" and "powershell.exe" or "/bin/bash"

      require("toggleterm").setup({
        direction = "float",
          float_opts = {
            border = "rounded",
            winblend = 0,
          },
        shell = shell,
      })
    end,
  },

})

-- ===================================================================
-- KEY MAPPINGS
-- ===================================================================

-- File operations (with nowait for faster response)
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Find files", nowait = true })
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree", nowait = true })
vim.keymap.set("n", "<leader>r", ":Telescope oldfiles<CR>", { desc = "Recent files", nowait = true })
vim.keymap.set("n", "<leader>ff", ":Telescope live_grep<CR>", { desc = "Find in files", nowait = true })
vim.keymap.set("n", "<leader>l", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Find in current file", nowait = true })

-- macOS-style shortcuts (Cmd key mappings)
vim.keymap.set("n", "<D-e>", ":NvimTreeToggle<CR>", { desc = "Toggle file tree (Cmd+E)" })
vim.keymap.set("n", "<D-f>", ":Telescope find_files<CR>", { desc = "Find files (Cmd+F)" })

-- Buffer/tab navigation
vim.keymap.set("n", "<A-,>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<A-.>", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<D-,>", ":BufferLineCyclePrev<CR>", { desc = "Previous buffer (Cmd+,)" })
vim.keymap.set("n", "<D-.>", ":BufferLineCycleNext<CR>", { desc = "Next buffer (Cmd+.)" })
vim.keymap.set("n", "<leader>p", "<C-^>", { desc = "Switch to previous buffer" })

-- Code actions and formatting
vim.keymap.set("n", "<leader>i", function()
  vim.lsp.buf.code_action({
    context = { only = { "source.addMissingImports.ts" } },
    apply = true,
  })
end, { desc = "Add missing imports" })

vim.keymap.set("n", "<D-i>", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "quickfix", "source.fixAll", "source.organizeImports", "source.addMissingImports.ts" },
    },
    apply = true,
  })
end, { desc = "Fix all issues (Cmd+I)" })

-- Save and format
vim.keymap.set("n", "<leader>s", function()
  -- Format current buffer
  vim.lsp.buf.format({ async = false })
  
  -- Save only modified, writable buffers
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "modified") then
      local readonly = vim.api.nvim_buf_get_option(buf, "readonly")
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      
      -- Only save normal buffers that are not readonly
      if not readonly and buftype == "" then
        vim.api.nvim_buf_call(buf, function()
          vim.cmd("silent write")
        end)
      end
    end
  end
  
  vim.notify("✅ Formatted and saved all files", vim.log.levels.INFO)
end, { desc = "Format and save all files" })

-- Undo/redo
vim.keymap.set("n", "<leader><Left>", "u", { desc = "Undo" })
vim.keymap.set("n", "<leader><Right>", "<C-r>", { desc = "Redo" })

-- Window management
vim.keymap.set("n", "<leader>c", function()
  local current = vim.api.nvim_buf_get_name(0)
  vim.cmd("b#")
  vim.cmd("vsplit " .. current)
end, { desc = "Split current file vertically" })

vim.keymap.set("n", "<leader><Up>", "<C-w>w", { desc = "Navigate between splits" })

-- Terminal
vim.keymap.set("n", "<leader>t", ":ToggleTerm<CR>", { desc = "Toggle terminal" })
vim.keymap.set("t", "<leader>t", [[<C-\><C-n>:ToggleTerm<CR]], { desc = "Close terminal" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

-- Smart navigation (Framework-aware)
vim.keymap.set("n", "<leader><CR>", function()
  local filetype = vim.bo.filetype
  local word = vim.fn.expand("<cword>")
  local framework = vim.g.current_framework

  if framework == "angular" and filetype == "html" and word:match("^app%-") then
    -- Navigate to Angular component
    local component_name = word
      :gsub("^app%-", "")
      :gsub("(%-)([^%-]+)", function(_, c) return "." .. c end)
    
    local search_name = component_name .. ".component.ts"
    require("telescope.builtin").find_files({
      prompt_title = "Find Angular Component",
      search_file = search_name,
    })
  elseif framework == "vue" and (filetype == "vue" or filetype == "javascript" or filetype == "typescript") then
    -- Try to find Vue component
    local component_file = word .. ".vue"
    require("telescope.builtin").find_files({
      prompt_title = "Find Vue Component",
      search_file = component_file,
    })
  else
    -- Default LSP definition
    vim.lsp.buf.definition()
  end
end, { desc = "Go to definition (smart)" })

-- Comment toggling
vim.keymap.set("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle comment" })

-- Git operations
vim.keymap.set("n", "<leader>gs", ":ShowChanges<CR>", { desc = "Show git changes", nowait = true })
vim.keymap.set("n", "<leader>gd", ":DiscardFile<CR>", { desc = "Discard current file changes", nowait = true })
vim.keymap.set("n", "<leader>gD", ":DiscardAll<CR>", { desc = "Discard ALL changes", nowait = true })

-- Git conflict resolution
vim.keymap.set("n", "<leader>g", function()
  local choices = {
    { label = "✅ Keep Current (ours)", command = "GitConflictChooseOurs" },
    { label = "🔄 Keep Incoming (theirs)", command = "GitConflictChooseTheirs" },
    { label = "🤝 Keep Both", command = "GitConflictChooseBoth" },
    { label = "❌ Cancel", command = nil },
  }

  vim.ui.select(choices, {
    prompt = "Choose how to resolve this conflict:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice and choice.command then
      vim.cmd(choice.command)
    end
  end)
end, { noremap = true, silent = true, desc = "Resolve Git Conflict" })

-- File manager action menu
vim.keymap.set("n", "<leader>j", function()
  local api = require("nvim-tree.api")

  local actions = {
    { label = "📄 Rename", fn = api.fs.rename },
    { label = "➕ Create", fn = api.fs.create },
    { label = "🗑️ Delete", fn = api.fs.remove },
    { label = "📁 Move", fn = api.fs.cut },
    { label = "📋 Copy", fn = api.fs.copy.node },
    { label = "❌ Cancel", fn = nil },
  }

  vim.ui.select(actions, {
    prompt = "File action:",
    format_item = function(item)
      return item.label
    end,
  }, function(choice)
    if choice and choice.fn then
      choice.fn()
    end
  end)
end, { desc = "📦 File/folder action menu" })

-- Framework switching shortcuts (changed to avoid conflict with <leader>f)
vim.keymap.set("n", "<leader>la", ":Framework angular<CR>", { desc = "Switch to Angular", nowait = true })
vim.keymap.set("n", "<leader>lv", ":Framework vue<CR>", { desc = "Switch to Vue", nowait = true })
