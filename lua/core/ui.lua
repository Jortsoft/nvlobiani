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
    "😮‍💨 Alt+F4 life temporarily.",
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

-- Git wrappers (simplified from your original)
local function show_git_changes()
  local git_status = vim.fn.systemlist("git status --porcelain")

  if #git_status == 0 then
    vim.notify("✨ No changes in working directory", vim.log.levels.INFO)
    return
  end

  local changes = {}
  for _, line in ipairs(git_status) do
    local status = line:sub(1, 2)
    local file = line:sub(4)

    local status_text = "Changed"
    if status:match("M") then status_text = "Modified"
    elseif status:match("A") then status_text = "Added"
    elseif status:match("D") then status_text = "Deleted"
    elseif status:match("R") then status_text = "Renamed"
    elseif status:match("??") then status_text = "Untracked" end

    table.insert(changes, {
      label = string.format("[%s] %s", status_text, file),
      file = file,
      status = status,
      action = "file",
    })
  end

  table.insert(changes, { label = "🗑️ Discard ALL changes", action = "discard_all" })
  table.insert(changes, { label = "❌ Cancel", action = "cancel" })

  vim.ui.select(changes, {
    prompt = "Select file to view/discard:",
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice or choice.action == "cancel" then return end

    if choice.action == "discard_all" then
      vim.ui.select(
        { "Yes, discard all", "No, cancel" },
        { prompt = "⚠️ Discard ALL changes? This cannot be undone!" },
        function(confirm)
          if confirm == "Yes, discard all" then
            vim.fn.system("git checkout -- .")
            vim.fn.system("git clean -fd")
            vim.notify("🗑️ All changes discarded", vim.log.levels.WARN)
            vim.cmd("checktime")
          end
        end
      )
    else
      -- simple diff in popup
      local diff = vim.fn.systemlist("git diff " .. choice.file)
      if #diff == 0 then
        vim.notify("No diff to show for " .. choice.file, vim.log.levels.INFO)
        return
      end

      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, diff)
      vim.api.nvim_buf_set_option(buf, "filetype", "diff")
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
        title = " 🔍 Changes: " .. choice.file .. " ",
        title_pos = "center",
      })
      vim.keymap.set("n", "q", ":close<CR>", { buffer = buf, silent = true })
      vim.keymap.set("n", "d", function()
        vim.ui.select(
          { "Yes, discard", "No" },
          { prompt = "Discard changes to " .. choice.file .. "?" },
          function(confirm)
            if confirm == "Yes, discard" then
              vim.fn.system("git checkout -- " .. vim.fn.shellescape(choice.file))
              vim.notify("🗑️ Changes discarded: " .. choice.file, vim.log.levels.WARN)
              vim.api.nvim_win_close(win, true)
              vim.cmd("checktime")
            end
          end
        )
      end, { buffer = buf, silent = true })
    end
  end)
end

function M.setup()
  setup_break_timer()

  vim.api.nvim_create_user_command("Reload", function()
    vim.cmd("source $MYVIMRC")
    vim.cmd("edit")
    vim.notify("🔁 Neovim config reloaded!", vim.log.levels.INFO)
  end, {})

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
