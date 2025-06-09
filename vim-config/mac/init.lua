vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = "a"
vim.g.loaded_perl_provider = 0
vim.o.termguicolors = true
vim.o.showtabline = 2
vim.g.mapleader = " "

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
      require("nvim-tree").setup()
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
    config = function()
      local lspconfig = require("lspconfig")

      lspconfig.tsserver.setup({
on_attach = function(_, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

  -- Alt+i to apply code actions like missing import
  vim.keymap.set("n", "<A-i>", function()
    vim.lsp.buf.code_action({
      context = {
        only = { "quickfix", "source.fixAll", "source.organizeImports", "source.addMissingImports.ts" },
      },
      apply = true,
    })
  end, opts)
end,
      })

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
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint,
          null_ls.builtins.code_actions.eslint,
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
      open_mapping = [[<leader>t]],
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
require("toggleterm").setup({
  direction = "float",
  open_mapping = [[<leader>t]],
  float_opts = {
    border = "curved",
  },
  shell = "/bin/bash", -- ← make sure Bash is used
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

vim.keymap.set("n", "<D-,>", "<cmd>BufferLineCyclePrev<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<D-.>", "<cmd>BufferLineCycleNext<CR>", { noremap = true, silent = true })
