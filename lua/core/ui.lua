local M = {}

local break_messages = {
  {
    "🚨 Your keyboard is crying.",
    "💧 Give it a break before it files a complaint.",
    "🧠 Go touch some grass.",
  },
  {
    "🦍 Brain cells have left the chat.",
    "🛌 Reboot yourself outside for 5 mins.",
    "🧘‍♂️ Zen mode: ON.",
  },
  {
    "🧟‍♂️ You're starting to look like a semicolon.",
    "📴 Unplug yourself and stretch a bit.",
    "🍵 Tea time, legend.",
  },
  {
    "🚀 Coding power at 1%.",
    "🔋 Please charge with fresh air.",
    "😮‍💨 Go fuck someone...",
  },
}

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
    border = "rounded",
  }

  local win = vim.api.nvim_open_win(buf, false, opts)
  vim.defer_fn(function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, 5000)
end

local function setup_break_timer()
  local timer = vim.loop.new_timer()
  timer:start(40 * 60 * 1000, 40 * 60 * 1000, vim.schedule_wrap(show_break_message))
end

local function open_path_in_system(path)
  if not path or path == "" then
    vim.notify("Nothing to open", vim.log.levels.WARN)
    return
  end

  local expanded = vim.fn.fnamemodify(vim.fn.expand(path), ":p")
  if vim.uv.fs_stat(expanded) == nil then
    vim.notify("Path does not exist: " .. expanded, vim.log.levels.WARN)
    return
  end

  local sys = vim.loop.os_uname().sysname
  local is_windows = (sys == "Windows_NT" or sys:match("Windows"))

  -- vim.ui.open can silently no-op on some Windows environments.
  -- Keep it for macOS/Linux, but use explicit OS commands on Windows.
  if (not is_windows) and vim.ui and vim.ui.open then
    local ok, result_or_nil, err_or_nil = pcall(vim.ui.open, expanded)
    if ok and result_or_nil then
      return
    end
    if ok and err_or_nil then
      vim.notify("vim.ui.open failed: " .. tostring(err_or_nil), vim.log.levels.WARN)
    elseif not ok then
      vim.notify("vim.ui.open failed unexpectedly", vim.log.levels.WARN)
    end
  end

  local cmd = nil
  if sys == "Darwin" then
    cmd = { "open", expanded }
  elseif is_windows then
    local win_path = expanded:gsub("/", "\\")
    -- cmd /c start is the most reliable way to open files/folders on Windows.
    -- Passing as an array avoids shell quoting issues with spaces.
    -- The empty string "" is required as the window title placeholder.
    local jid = vim.fn.jobstart({ "cmd.exe", "/c", "start", "", win_path }, { detach = true })
    if jid > 0 then
      return
    end
    -- Fallback: explicit explorer.exe
    jid = vim.fn.jobstart({ "explorer.exe", win_path }, { detach = true })
    if jid > 0 then
      return
    end
    -- Last resort: PowerShell Start-Process
    cmd = {
      "powershell.exe",
      "-NoProfile",
      "-ExecutionPolicy",
      "Bypass",
      "-Command",
      "Start-Process -LiteralPath '" .. win_path:gsub("'", "''") .. "'",
    }
  else
    cmd = { "xdg-open", expanded }
  end

  local jid = vim.fn.jobstart(cmd, { detach = true })
  if jid <= 0 then
    vim.notify("Could not open in system: " .. expanded, vim.log.levels.ERROR)
  end
end

local function detect_open_target(arg)
  if arg and arg ~= "" then
    return arg
  end

  if vim.bo.filetype == "NvimTree" then
    local node = nil

    local ok, api = pcall(require, "nvim-tree.api")
    if ok and api and api.tree and api.tree.get_node_under_cursor then
      node = api.tree.get_node_under_cursor()
    end

    if not node then
      local ok_lib, lib = pcall(require, "nvim-tree.lib")
      if ok_lib and lib and lib.get_node_at_cursor then
        node = lib.get_node_at_cursor()
      end
    end

    if node then
      if node.absolute_path and node.absolute_path ~= "" then
        return node.absolute_path
      end
      if node.link_to and node.link_to ~= "" then
        return node.link_to
      end
      if node.name and node.name ~= "" and node.parent and node.parent.absolute_path then
        return node.parent.absolute_path .. "/" .. node.name
      end
      if node.name and node.name ~= "" then
        return node.name
      end
    end
  end

  local current = vim.api.nvim_buf_get_name(0)
  if current and current ~= "" then
    return current
  end

  return vim.loop.cwd()
end

local function open_selected_in_system(arg)
  local target = detect_open_target(arg)
  open_path_in_system(target)
end

-- Git wrappers (simplified from your original)
local function git_root()
  local out = vim.fn.systemlist({ "git", "rev-parse", "--show-toplevel" })
  if vim.v.shell_error ~= 0 or #out == 0 then
    return nil
  end
  return out[1]
end

local function rel_from_root(root, abs)
  if not root or not abs then
    return nil
  end

  if vim.fs and vim.fs.relpath then
    local rel = vim.fs.relpath(root, abs)
    if rel then
      return rel
    end
  end

  local prefix = root .. "/"
  if abs:sub(1, #prefix) == prefix then
    return abs:sub(#prefix + 1)
  end
  return abs
end

local function open_git_diff_view(entry)
  local root = git_root()
  if not root then
    vim.notify("Not inside a git repository", vim.log.levels.WARN)
    return
  end

  local abs = entry.path or vim.fn.fnamemodify(entry.value, ":p")
  local rel = rel_from_root(root, abs)
  if not rel then
    vim.notify("Unable to resolve selected file path", vim.log.levels.WARN)
    return
  end

  local head_lines = vim.fn.systemlist({ "git", "-C", root, "--no-pager", "show", "HEAD:" .. rel })
  local has_head = vim.v.shell_error == 0
  if not has_head then
    head_lines = {}
  end

  local work_lines = {}
  if vim.uv.fs_stat(abs) then
    work_lines = vim.fn.readfile(abs)
  end

  local ft = vim.filetype.match({ filename = abs }) or ""

  vim.cmd("tabnew")

  local right = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(right, 0, -1, false, work_lines)
  vim.api.nvim_buf_set_name(right, "WORKTREE:" .. rel)
  vim.bo[right].buftype = "nofile"
  vim.bo[right].bufhidden = "wipe"
  vim.bo[right].swapfile = false
  vim.bo[right].modifiable = false
  vim.bo[right].readonly = true
  if ft ~= "" then
    vim.bo[right].filetype = ft
  end

  vim.cmd("leftabove vnew")
  local left = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(left, 0, -1, false, head_lines)
  vim.api.nvim_buf_set_name(left, "HEAD:" .. rel)
  vim.bo[left].buftype = "nofile"
  vim.bo[left].bufhidden = "wipe"
  vim.bo[left].swapfile = false
  vim.bo[left].modifiable = false
  vim.bo[left].readonly = true
  if ft ~= "" then
    vim.bo[left].filetype = ft
  end

  vim.cmd("diffthis")
  vim.cmd("wincmd l")
  vim.cmd("diffthis")

  vim.keymap.set("n", "q", "<cmd>tabclose<CR>", { buffer = left, silent = true })
  vim.keymap.set("n", "q", "<cmd>tabclose<CR>", { buffer = right, silent = true })

  if not has_head then
    vim.notify("New file: showing against empty HEAD version", vim.log.levels.INFO)
  end
end

local function show_git_changes()
  local ok_b, builtin = pcall(require, "telescope.builtin")
  local ok_a, actions = pcall(require, "telescope.actions")
  local ok_s, action_state = pcall(require, "telescope.actions.state")

  if ok_b and ok_a and ok_s then
    builtin.git_status({
      prompt_title = "Git Changes (Enter: open diff view)",
      attach_mappings = function(prompt_bufnr, map)
        local open_selected = function()
          local selection = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          if selection then
            open_git_diff_view(selection)
          end
        end

        map({ "i", "n" }, "<CR>", open_selected)
        return true
      end,
    })
    return
  end

  vim.notify("Telescope not available for git change browser", vim.log.levels.WARN)
end

function M.setup()
  setup_break_timer()

  vim.api.nvim_create_user_command("Reload", function()
    vim.cmd("source $MYVIMRC")
    vim.cmd("edit")
    vim.notify("🔁 Neovim config reloaded!", vim.log.levels.INFO)
  end, {})

  vim.api.nvim_create_user_command("Open", function(opts)
    open_selected_in_system(opts.args)
  end, {
    nargs = "?",
    complete = "file",
    desc = "Open selected file/folder in system app",
  })

  vim.api.nvim_create_user_command("ShowChanges", show_git_changes, { desc = "Show git changes" })
  vim.keymap.set("n", "<leader>gs", ":ShowChanges<CR>", { desc = "Show git changes", nowait = true })

  -- Simple conflict resolver popup
  vim.keymap.set("n", "<leader>g", function()
    local choices = {
      { label = "✅ Keep Current (ours)", command = "GitConflictChooseOurs" },
      { label = "🔄 Keep Incoming (theirs)", command = "GitConflictChooseTheirs" },
      { label = "🤝 Keep Both", command = "GitConflictChooseBoth" },
      { label = "❌ Cancel", command = nil },
    }
    vim.ui.select(choices, {
      prompt = "Resolve conflict:",
      format_item = function(i) return i.label end,
    }, function(choice)
      if choice and choice.command then vim.cmd(choice.command) end
    end)
  end, { noremap = true, silent = true, desc = "Resolve Git Conflict" })
end

return M
