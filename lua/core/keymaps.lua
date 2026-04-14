local M = {}

function M.setup()
  local map = vim.keymap.set
  local sysname = vim.loop.os_uname().sysname
  local is_mac = sysname == "Darwin"
  local is_win = sysname:match("Windows") or sysname:match("Win")

  -- File / search
  map("n", "<leader>f", ":Telescope find_files<CR>", { desc = "Find files", nowait = true })
  map("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file tree", nowait = true })
  map("n", "<leader>r", ":Telescope oldfiles<CR>", { desc = "Recent files", nowait = true })
  map("n", "<leader>ff", ":Telescope live_grep<CR>", { desc = "Live grep", nowait = true })
  map("n", "<leader>l", ":Telescope current_buffer_fuzzy_find<CR>", { desc = "Search in buffer", nowait = true })

  -- macOS / Windows style
  if is_mac then
    map("n", "<D-e>", ":NvimTreeToggle<CR>", { desc = "Toggle file tree (Cmd+E)" })
    map("n", "<D-f>", ":Telescope find_files<CR>", { desc = "Find files (Cmd+F)" })
  elseif is_win then
    map("n", "<C-e>", ":NvimTreeToggle<CR>", { desc = "Toggle file tree (Ctrl+E)" })
    map("n", "<C-f>", ":Telescope find_files<CR>", { desc = "Find files (Ctrl+F)" })
  end

  -- Buffers
  map("n", "<A-,>", ":BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
  map("n", "<A-.>", ":BufferLineCycleNext<CR>", { desc = "Next buffer" })
  if is_mac then
    map("n", "<D-,>", ":BufferLineCyclePrev<CR>", { desc = "Prev buffer (Cmd+,)" })
    map("n", "<D-.>", ":BufferLineCycleNext<CR>", { desc = "Next buffer (Cmd+.)" })
  elseif is_win then
    map("n", "<C-,>", ":BufferLineCyclePrev<CR>", { desc = "Prev buffer (Ctrl+,)" })
    map("n", "<C-.>", ":BufferLineCycleNext<CR>", { desc = "Next buffer (Ctrl+.)" })
  end
  map("n", "<leader>p", "<C-^>", { desc = "Toggle last buffer" })

  -- Save + format all
  map("n", "<leader>s", function()
    local clients = {}
    if vim.lsp.get_clients then
      clients = vim.lsp.get_clients({ bufnr = 0 })
    else
      clients = vim.lsp.get_active_clients({ bufnr = 0 })
    end

    local can_format = false
    for _, client in ipairs(clients) do
      if client.supports_method and client:supports_method("textDocument/formatting") then
        can_format = true
        break
      end
      if client.server_capabilities and client.server_capabilities.documentFormattingProvider then
        can_format = true
        break
      end
    end

    if can_format then
      vim.lsp.buf.format({ async = false })
    end
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_option(buf, "modified") then
        local ro = vim.api.nvim_buf_get_option(buf, "readonly")
        local bt = vim.api.nvim_buf_get_option(buf, "buftype")
        if not ro and bt == "" then
          vim.api.nvim_buf_call(buf, function()
            vim.cmd("silent write")
          end)
        end
      end
    end
    if can_format then
      vim.notify("✅ Formatted and saved all files", vim.log.levels.INFO)
    else
      vim.notify("✅ Saved all files (no LSP formatter attached)", vim.log.levels.INFO)
    end
  end, { desc = "Format + save" })

  -- Undo / redo
  map("n", "<leader><Left>", "u", { desc = "Undo" })
  map("n", "<leader><Right>", "<C-r>", { desc = "Redo" })

  -- Splits
  map("n", "<leader>c", function()
    local current = vim.api.nvim_buf_get_name(0)
    vim.cmd("b#")
    vim.cmd("vsplit " .. current)
  end, { desc = "Vertical split same file" })

  -- Terminal
  local tmux_term = nil

  local function ensure_tmux_terminal()
    if vim.fn.executable("tmux") == 0 then
      return nil
    end

    if tmux_term and tmux_term.bufnr and vim.api.nvim_buf_is_valid(tmux_term.bufnr) then
      return tmux_term
    end

    local ok, terminal = pcall(require, "toggleterm.terminal")
    if not ok then
      vim.notify("toggleterm not loaded", vim.log.levels.WARN)
      return nil
    end

    tmux_term = terminal.Terminal:new({
      id = 99,
      cmd = "tmux new-session -A -s nvlobiani-popup",
      direction = "float",
      hidden = true,
      close_on_exit = false,
    })
    return tmux_term
  end

  local function in_tmux_popup()
    return tmux_term
      and tmux_term.bufnr
      and vim.api.nvim_get_current_buf() == tmux_term.bufnr
      and tmux_term:is_open()
  end

  local function toggle_terminal_popup()
    local term = ensure_tmux_terminal()
    if not term then
      vim.notify("tmux is required for pane-based popup terminal", vim.log.levels.WARN)
      return
    end
    term:toggle()
  end

  local function tmux_send(cmd)
    local term = ensure_tmux_terminal()
    if not term then
      vim.notify("tmux is required for pane-based popup terminal", vim.log.levels.WARN)
      return false
    end

    if not term:is_open() then
      term:open()
    end
    term:send(cmd, false)
    term:focus()
    vim.cmd("startinsert")
    return true
  end

  map("n", "<leader><Up>", function()
    if in_tmux_popup() then
      tmux_send("tmux select-pane -t :.+")
    else
      vim.cmd("wincmd w")
    end
  end, { desc = "Cycle splits / tmux panes" })

  map("n", "<leader>t", toggle_terminal_popup, { desc = "Toggle terminal popup" })
  map("n", "<leader>m", function()
    tmux_send("tmux split-window -h")
  end, { desc = "Split terminal pane" })
  map("t", "<leader>t", function()
    vim.cmd("stopinsert")
    toggle_terminal_popup()
  end, { desc = "Toggle terminal popup" })
  map("t", "<leader>m", function()
    tmux_send("tmux split-window -h")
  end, { desc = "Split terminal pane" })
  map("t", "<leader><Up>", function()
    if in_tmux_popup() then
      tmux_send("tmux select-pane -t :.+")
    else
      vim.cmd("stopinsert")
      vim.cmd("wincmd w")
    end
  end, { desc = "Cycle splits / tmux panes" })
  map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

  -- Smart navigation (Angular/Vue/Unity)
  map("n", "<leader><CR>", function()
    local ft = vim.bo.filetype
    local word = vim.fn.expand("<cword>")
    local framework = vim.g.current_framework or "angular"

    -- Unity: C# (jump to definition, fallback to file search)
    if ft == "cs" then
      local params = vim.lsp.util.make_position_params()
      local result = vim.lsp.buf_request_sync(0, "textDocument/definition", params, 800)
      if result then
        for _, res in pairs(result) do
          if res.result and not vim.tbl_isempty(res.result) then
            vim.lsp.buf.definition()
            return
          end
        end
      end

      -- Fallback: search for a C# file with the same name
      local search_file = word .. ".cs"
      require("telescope.builtin").find_files({
        prompt_title = "Find C# Script",
        search_file = search_file,
      })
      return
    end

    -- Angular HTML: <app-something>
    if framework == "angular" and ft == "html" and word:match("^app%-") then
      local component_name = word
        :gsub("^app%-", "")
        :gsub("(%-)([^%-]+)", function(_, c) return "." .. c end)

      local search_name = component_name .. ".component.ts"
      require("telescope.builtin").find_files({
        prompt_title = "Find Angular Component",
        search_file = search_name,
      })
      return
    end

    -- Vue: try to jump to component file
    if framework == "vue" then
      local component_file = word .. ".vue"
      require("telescope.builtin").find_files({
        prompt_title = "Find Vue Component",
        search_file = component_file,
      })
      return
    end

    -- Default
    vim.lsp.buf.definition()
  end, { desc = "Smart Go-To Definition" })

  -- Comment toggling (visual)
  map("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)", { desc = "Toggle comment" })

  -- Auto import / organize imports (Angular/Vue/Unity/TS/JS/C#)
  map({ "n", "v" }, "<leader>i", function()
    vim.lsp.buf.code_action({
      apply = true,
      context = { only = { "source.addMissingImports", "source.organizeImports" } },
    })
  end, { desc = "Auto import / organize imports" })

  -- File manager action menu
  map("n", "<leader>j", function()
    local ok, api = pcall(require, "nvim-tree.api")
    if not ok then
      vim.notify("nvim-tree not loaded", vim.log.levels.WARN)
      return
    end

    local actions = {
      { label = "📄 Rename", fn = api.fs.rename },
      { label = "➕ Create", fn = api.fs.create },
      { label = "🖥️ Open in System", fn = function() vim.cmd("Open") end },
      { label = "🗑️ Delete", fn = api.fs.remove },
      { label = "📁 Move", fn = api.fs.cut },
      { label = "📋 Copy", fn = api.fs.copy.node },
      { label = "❌ Cancel", fn = nil },
    }

    vim.ui.select(actions, {
      prompt = "File action:",
      format_item = function(item) return item.label end,
    }, function(choice)
      if choice and choice.fn then choice.fn() end
    end)
  end, { desc = "File/folder action menu" })
end

return M
