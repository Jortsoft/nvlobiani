local M = {}

function M.setup()
  -- Bootstrap lazy.nvim
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

  local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

  require("lazy").setup({
    -- =========================
    -- UI & Appearance
    -- =========================
    {
      "goolord/alpha-nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        local alpha = require("alpha")
        local dashboard = require("alpha.themes.dashboard")

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

    {
      "nvim-lualine/lualine.nvim",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        local clock = "🕒 00:00:00"
        local timer_display = "⏱ 00:00"
        local start_time = vim.loop.hrtime()

        local timer = vim.loop.new_timer()
        timer:start(0, 1000, vim.schedule_wrap(function()
          clock = os.date("🕒 %H:%M:%S")

          local elapsed = math.floor((vim.loop.hrtime() - start_time) / 1e9)
          local m = math.floor(elapsed / 60)
          local s = elapsed % 60
          timer_display = string.format("⏱ %02d:%02d", m, s)
          vim.cmd("redrawstatus")
        end))

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
                local fw = vim.g.current_framework or "none"
                return "[" .. fw:upper() .. "]"
              end,
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

    {
      "rcarriga/nvim-notify",
      config = function()
        require("notify").setup({
          background_colour = "#1e1e2e",
          stages = "fade",
          render = "compact",
          timeout = 3000,
        })
        vim.notify = require("notify")
      end,
    },

    {
      "folke/noice.nvim",
      dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
      config = function()
        require("noice").setup({
          lsp = {
            override = {
              ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
              ["vim.lsp.util.stylize_markdown"] = true,
            },
          },
          presets = {
            command_palette = true,
            lsp_doc_border = true,
          },
        })
      end,
    },

    -- Themes
    { "bluz71/vim-moonfly-colors", name = "moonfly", lazy = false, priority = 1000,
      config = function() vim.cmd("colorscheme moonfly") end },
    { "folke/tokyonight.nvim", name = "tokyonight", lazy = false, priority = 1000 },
    { "scottmckendry/cyberdream.nvim", name = "cyberdream", lazy = false, priority = 1000 },
    { "projekt0n/github-nvim-theme", name = "github-theme", lazy = false, priority = 1000 },
    { "navarasu/onedark.nvim", priority = 1000,
      config = function()
        vim.api.nvim_create_user_command("Theme", function(opts)
          local style = opts.args:lower()

          if style == "onedark" or style == "onelight" then
            require("onedark").setup({ style = style == "onelight" and "light" or "dark" })
            require("onedark").load()
          elseif style == "moonfly" then
            vim.cmd("colorscheme moonfly")
          elseif style == "cyberdream" then
            require("cyberdream").setup({})
            vim.cmd("colorscheme cyberdream")
          elseif style == "tokyonight" then
            require("tokyonight").setup({})
            vim.cmd("colorscheme tokyonight")
          elseif style == "githubdark" or style == "github-dark" then
            require("github-theme").setup({ options = { darken = { floats = false } } })
            vim.cmd("colorscheme github_dark")
          else
            vim.notify("Invalid theme", vim.log.levels.ERROR)
          end
        end, { nargs = 1 })
      end
    },

    -- =========================
    -- Navigation & Files
    -- =========================
    { "nvim-lua/plenary.nvim" },

    {
      "nvim-tree/nvim-tree.lua",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1
        require("nvim-tree").setup({
          update_focused_file = { enable = true, update_cwd = true },
          filters = {
            dotfiles = false,
            custom = function(absolute_path)
              return absolute_path:match("%.meta$") ~= nil
            end,
          },
        })
      end,
    },

    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.5",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        require("telescope").setup({
          defaults = {
            file_ignore_patterns = { "node_modules/", "%.git/", "build/", "dist/" },
          },
        })
      end,
    },

    {
      "akinsho/bufferline.nvim",
      version = "*",
      dependencies = { "nvim-tree/nvim-web-devicons" },
      config = function()
        require("bufferline").setup({
          options = {
            mode = "buffers",
            diagnostics = "nvim_lsp",
            separator_style = "slant",
          },
        })
      end,
    },

    {
      "akinsho/toggleterm.nvim",
      version = "*",
      config = function()
        local sys = vim.loop.os_uname().sysname
        local shell = sys == "Windows_NT" and "powershell.exe" or "/bin/bash"
        require("toggleterm").setup({
          direction = "float",
          float_opts = { border = "rounded", winblend = 0 },
          shell = shell,
        })
      end,
    },

    -- =========================
    -- Git
    -- =========================
    {
      "lewis6991/gitsigns.nvim",
      config = function()
        require("gitsigns").setup({
          current_line_blame = true,
          current_line_blame_opts = {
            virt_text = true,
            virt_text_pos = "eol",
            delay = 1000,
          },
        })
      end,
    },

    { "akinsho/git-conflict.nvim", version = "*", config = true },

    -- =========================
    -- Syntax / Treesitter
    -- =========================
    {
      "nvim-treesitter/nvim-treesitter",
      enabled = function() return not is_windows end,
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup({
          ensure_installed = {
            "html", "typescript", "css", "javascript",
            "json", "vue", "scss", "c_sharp", "lua",
          },
          highlight = { enable = true, additional_vim_regex_highlighting = { "vue" } },
        })
      end,
    },

    -- Angular & Vue syntax helpers
    { "HerringtonDarkholme/yats.vim", lazy = false },
    { "posva/vim-vue", lazy = false },

    -- Comment
    { "numToStr/Comment.nvim", config = function() require("Comment").setup() end },

    -- =========================
    -- Completion & LSP
    -- =========================
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
            expand = function(args) luasnip.lsp_expand(args.body) end,
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

    -- LSP
    { "williamboman/mason.nvim", build = ":MasonUpdate", config = true },
    {
      "williamboman/mason-lspconfig.nvim",
      dependencies = { "mason.nvim", "neovim/nvim-lspconfig" },
    },
    {
      "neovim/nvim-lspconfig",
      dependencies = { "b0o/schemastore.nvim" },
      config = function()
        require("lsp").setup()
      end,
    },

    -- Formatting (prettier via null-ls)
    {
      "nvimtools/none-ls.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local null_ls = require("null-ls")
        null_ls.setup({
          sources = {
            null_ls.builtins.formatting.prettier.with({
              filetypes = {
                "html", "css", "scss", "javascript", "typescript",
                "vue", "json", "yaml", "markdown"
              },
            }),
          },
        })
      end,
    },
  })
end

return M
