vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.g.loaded_perl_provider = 0
vim.o.termguicolors = true
vim.o.showtabline = 2
vim.g.mapleader = " "

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)


vim.diagnostic.config({
  virtual_text = true,  -- show inline errors
  signs = true,         -- show signs in gutter
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

vim.api.nvim_create_user_command("Reload", function()
  vim.cmd("source $MYVIMRC")   -- Reload init.lua
  vim.cmd("edit")              -- Reload current buffer
  vim.notify("🔁 Neovim config reloaded!", vim.log.levels.INFO)
end, {})

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

-- Setup plugins with lazy.nvim
require("lazy").setup({

    {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        current_line_blame = true,
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, lhs, rhs, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
          end
          map("n", "]c", function()
            if vim.wo.diff then return "]c" end
            vim.schedule(gs.next_hunk)
            return "<Ignore>"
          end, { expr = true })
          map("n", "[c", function()
            if vim.wo.diff then return "[c" end
            vim.schedule(gs.prev_hunk)
            return "<Ignore>"
          end, { expr = true })
          map("n", "<leader>gs", gs.stage_hunk)
          map("n", "<leader>gu", gs.undo_stage_hunk)
          map("n", "<leader>gr", gs.reset_hunk)
          map("n", "<leader>gR", gs.reset_buffer)
          map("n", "<leader>gp", gs.preview_hunk)
          map("n", "<leader>gb", function() gs.blame_line { full = true } end)
          map("n", "<leader>gd", gs.diffthis)
        end,
      })
    end,
  },
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>h", "<cmd>Git<CR>", desc = "Open Git status" },
    },
    config = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fugitive",
        callback = function()
          vim.keymap.set("n", "X", function()
            local line = vim.fn.getline(".")
            local filename = line:match("%s+.-%s+(.+)")
            if filename and filename ~= "" then
              vim.ui.select({ "No", "Yes" }, { prompt = "Discard changes to " .. filename .. "?" }, function(choice)
                if choice == "Yes" then
                  vim.fn.system({ "git", "checkout", "--", filename })
                  vim.cmd("bdelete")
                  vim.cmd("silent! Git")
                end
              end)
            end
          end, { buffer = true, nowait = true, silent = true })
        end,
      })
    end,
  },
  -- Custom Dashboard with "JORTSOFT EDITOR"
{
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha = require("alpha")
    local dashboard = require("alpha.themes.dashboard")

    -- Logo header
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

    -- Buttons
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

-- Bottom widgets branch, time and more...
{
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
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
          {
            function()
              return os.date("%H:%M:%S")  
            end,
          },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
},

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      require("nvim-tree").setup({
          update_focused_file = {
          enable = true,
          update_cwd = true,        -- Optional: also updates the working directory
          ignore_list = {},         -- You can add patterns here to exclude certain files
         },
      })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },

  -- Atom One Dark theme
  {
  "navarasu/onedark.nvim",
  priority = 1000,
  config = function()
    local onedark = require("onedark")

    -- Load default style
    onedark.setup({ style = "dark" })
    onedark.load()

    -- Define :Theme [dark|light] command
    vim.api.nvim_create_user_command("Theme", function(opts)
      local style = opts.args:lower()
      if style == "dark" or style == "light" then
        onedark.setup({ style = style })
        onedark.load()
      else
        vim.notify("Invalid style: use 'dark' or 'light'", vim.log.levels.ERROR)
      end
    end, {
      nargs = 1,
      complete = function()
        return { "dark", "light" }
      end,
    })
  end,
  },

  -- Autocompletion engine + snippets
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

  -- LSP config (tsserver, angular, json, etc.)
    {
      "neovim/nvim-lspconfig",
      version = "*", -- or remove this line to always get the latest
      config = function()
        local lspconfig = require("lspconfig")

        -- CSS/SCSS
        lspconfig.cssls.setup({
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
        })

        -- TypeScript/JavaScript - use ts_ls instead of tsserver
        lspconfig.ts_ls.setup({
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          on_attach = function(_, bufnr)
            local opts = { noremap = true, silent = true, buffer = bufnr }

            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
            vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

            vim.keymap.set("n", "<A-i>", function()
              vim.lsp.buf.code_action({
                context = {
                  only = {
                    "quickfix",
                    "source.fixAll",
                    "source.organizeImports",
                    "source.addMissingImports.ts"
                  },
                },
                apply = true,
              })
            end, opts)
          end,
        })

        -- JSON
        lspconfig.jsonls.setup({})
      end,
    },


  -- Prettier + ESLint formatter integration (via null-ls)
     {
  "nvimtools/none-ls.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local null_ls = require("null-ls")

    null_ls.setup({
      sources = {
        -- Only use Prettier for formatting
        null_ls.builtins.formatting.prettier.with({
          condition = function(utils)
            return utils.root_has_file({ 
              ".prettierrc", 
              ".prettierrc.json", 
              ".prettierrc.js", 
              "prettier.config.js", 
              "package.json" 
            })
          end,
        }),
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

  -- Telescope fuzzy finder
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
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--glob=!node_modules/**", -- ignore node_modules
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          no_ignore = false, -- use .gitignore
        }
      }
    })

    vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<CR>", { noremap = true, silent = true })
  end,
  },

-- Toggle terminal with <leader>t
{
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      direction = "float", -- Other options: 'horizontal', 'vertical', 'tab'
      float_opts = {
        border = "curved",
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
        show_buffer_close_icons = true,
        show_close_icon = false,
        diagnostics = "nvim_lsp",
        separator_style = "slant", -- or "thin", "padded_slant", "thick"
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

    -- Keymaps to navigate tabs
    vim.keymap.set("n", "<A-,>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, silent = true })
    vim.keymap.set("n", "<A-.>", "<cmd>BufferLineCycleNext<CR>", { noremap = true, silent = true })
  end,
},

})

-- Global keymaps
-- Toggle open file tree
vim.keymap.set("n", "<D-e>", function()
  vim.cmd("NvimTreeToggle")
end, { noremap = true, silent = true })

-- Open find file popup
vim.keymap.set("n", "<D-f>", function()
  require("telescope.builtin").find_files()
end, { noremap = true, silent = true })

-- Import auto modules
vim.keymap.set("n", "<leader>i", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "source.addMissingImports.ts" },
    },
    apply = true,
  })
end, { noremap = true, silent = true })

-- Open terminal
local sysname = vim.loop.os_uname().sysname
local shell

if sysname == "Windows_NT" then
  -- Use PowerShell with sane defaults
  shell = "powershell.exe"
else
  -- macOS or Linux
  shell = "/bin/bash"
end

require("toggleterm").setup({
  direction = "float",
  float_opts = {
    border = "curved",
  },
  shell = shell,
})

-- Undo and rendu
vim.keymap.set("n", "<leader><Left>", "u", { noremap = true, silent = true })
vim.keymap.set("n", "<leader><Right>", "<C-r>", { noremap = true, silent = true })

-- Toggle switch file tab
vim.keymap.set("n", "<leader>p", "<C-^>", { noremap = true, silent = true })

-- Save files
vim.keymap.set("n", "<leader>s", function()
  vim.cmd("write!")  -- <-- force save

  local diagnostics = vim.diagnostic.get(0)
  if diagnostics and #diagnostics > 0 then
    vim.defer_fn(function()
      vim.diagnostic.open_float(nil, { focus = false })
    end, 100)
  end
end, { noremap = true, silent = true })


vim.keymap.set("n", "<D-i>", function()
  vim.lsp.buf.code_action({
    context = {
      only = { "quickfix", "source.fixAll", "source.organizeImports", "source.addMissingImports.ts" },
    },
    apply = true,
  })
end, { noremap = true, silent = true })

-- Find file inner file
vim.keymap.set("n", "<leader>l", function()
  require("telescope.builtin").current_buffer_fuzzy_find()
end, { noremap = true, silent = true })

-- Split files
vim.keymap.set("n", "<leader>c", function()
  local current = vim.api.nvim_buf_get_name(0)
  vim.cmd("b#")         -- switch to previous buffer
  vim.cmd("vsplit " .. current) -- open the original file in vertical split
end, { noremap = true, silent = true })

-- Toggle navigate splited files
vim.keymap.set("n", "<leader><Up>", "<C-w>w", { noremap = true, silent = true })

vim.keymap.set("n", "<D-,>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<D-.>", "<cmd>BufferLineCycleNext<CR>", { noremap = true, silent = true })

-- Esc exits terminal mode
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { noremap = true })

-- <leader>t toggles terminal from terminal mode
vim.keymap.set("t", "<leader>t", [[<C-\><C-n><cmd>ToggleTerm<CR>]], { noremap = true, silent = true })

-- <leader>t in normal mode (already exists)
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader><CR>", function()
  vim.lsp.buf.definition()
end, { noremap = true, silent = true })
