-- ===================================================================
-- JORTSOFT NEOVIM CONFIGURATION
-- A clean, well-organized Neovim setup with modern plugins
-- ===================================================================

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

-- Disable providers we don't need
vim.g.loaded_perl_provider = 0

-- Set clipboard to system clipboard (delayed to avoid startup issues)
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

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
          lualine_c = { "filename" },
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
      current_line_blame = true,         -- Show blame text at end of line
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",           -- Show at end of line
        delay = 1000,                    -- Delay before showing blame
        ignore_whitespace = false,
      },
      current_line_blame_formatter = '<author> • <author_time:%Y-%m-%d> • <summary>',
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

  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    version = "*",
    dependencies = { "b0o/schemastore.nvim" }, -- JSON schemas
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Helper function to find Angular Language Server
      local function get_angular_ls_cmd(root_dir)
        local util = require("lspconfig.util")
        
        -- Try to find @angular/language-server in node_modules
        local node_modules_path = util.path.join(root_dir, "node_modules")
        local angular_server_path = util.path.join(
          node_modules_path,
          "@angular",
          "language-server",
          "bin",
          "ngserver"
        )
        
        -- Check if the Angular server exists
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
        
        -- Try global installation paths
        local global_paths = {
          -- npm global (Linux/macOS)
          "/usr/local/lib/node_modules/@angular/language-server/bin/ngserver",

          -- ✅ Homebrew npm global (Apple Silicon Macs typically use this)
          "/opt/homebrew/lib/node_modules/@angular/language-server/bin/ngserver",

          -- npm global (alternative)
          vim.fn.expand("~/.npm-global/lib/node_modules/@angular/language-server/bin/ngserver"),

          -- yarn global
          vim.fn.expand("~/.yarn/global/node_modules/@angular/language-server/bin/ngserver"),

          -- pnpm global
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
        
        -- Try using npx as fallback (if @angular/language-server is available)
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

      -- Angular Language Server (with smart detection)
      lspconfig.angularls.setup({
        cmd = function()
          local root_dir = lspconfig.util.root_pattern("angular.json", "nx.json", ".git")(vim.fn.getcwd())
          if root_dir then
            return get_angular_ls_cmd(root_dir)
          end
          -- Fallback if no root directory found
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
        single_file_support = false, -- Angular LS needs a project context
        on_attach = function(client, bufnr)
          -- Disable Angular LS formatting in favor of Prettier
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        end,
      })

      -- CSS/SCSS Language Server
      lspconfig.cssls.setup({ 
        capabilities = capabilities,
        filetypes = { "css", "scss", "less" }
      })

      -- TypeScript/JavaScript Language Server
      lspconfig.tsserver.setup({
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git"),
        on_attach = function(client, bufnr)
          -- Disable ts_ls formatting in favor of Prettier
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
          
          local opts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          
          -- Additional TypeScript-specific keymaps
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        end,
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
        filetypes = { "html", "templ" }
      })
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
          null_ls.builtins.formatting.prettier,
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
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
        float_opts = { border = "curved" },
        shell = shell,
      })
    end,
  },

})

-- ===================================================================
-- KEY MAPPINGS
-- ===================================================================

-- File operations
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>r", ":Telescope oldfiles<CR>", { desc = "Recent files" })
vim.keymap.set("n", "<leader>ff", ":Telescope live_grep<CR>", { desc = "Find in files" })
vim.keymap.set("n", "<leader>l", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Find in current file" })

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
  vim.lsp.buf.format({ async = false })
  vim.cmd("wall")
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

-- Smart navigation (Angular components)
vim.keymap.set("n", "<leader><CR>", function()
  local filetype = vim.bo.filetype
  local word = vim.fn.expand("<cword>")

  if filetype == "html" and word:match("^app%-") then
    -- Navigate to Angular component
    local component_name = word
      :gsub("^app%-", "")
      :gsub("(%-)([^%-]+)", function(_, c) return "." .. c end)
    
    local search_name = component_name .. ".component.ts"
    require("telescope.builtin").find_files({
      prompt_title = "Find Angular Component",
      search_file = search_name,
    })
  else
    -- Default LSP definition
    vim.lsp.buf.definition()
  end
end, { desc = "Go to definition (smart)" })

-- Comment toggling
vim.keymap.set("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle comment" })
