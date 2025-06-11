<img width="1495" alt="Screenshot 2025-06-09 at 17 31 21" src="https://github.com/user-attachments/assets/412978b3-e083-4d5e-a1b6-1cd2ffb93a49" />

# 🧠 NvLobiani
NvLobiani is a Vim-based code editor for web and full-stack developers.
---

## 🎹 Keymaps

| Action                | Shortcut                              |
|-----------------------|----------------------------------------|
| 💾 Save file          | `<leader>space + S`                    |
| 📁 Toggle file tree   | `<leader>space + E`                    |
| 🔍 Find file          | `<leader>space + F`                    |
| 🔄 Switch files       | `<leader>space + P`                    |
| 📦 Import module      | `<leader>space + I`                    |
| 💻 Open Terminal      | `<leader>space + T`                    |
| 👀 Find word in file  | `<leader>space + L`                    |
| 🔪 Split file         | `<leader>space + C`                    |
| 🔂 Toggle navigate file  | `<leader>space + ↑`                 |
| ↩️ Undo               | `<leader>space + ←`                    |
| ↪️ Redo               | `<leader>space + →`                    |
| 📝 Open module        | `<leader>space + Enter`                |
| 📝 Show file history  | `<leader>space + R`                    |
| 📝 Search word in all file | `<leader>space + FF`              |

## ⌨ Shortcuts

| Action                | Shortcut                              |
|-----------------------|----------------------------------------|
| Back to word          | `<n>Shift + B`                         |
| Go to word            | `<n>Shift + E`                         |
| Go to end of line     | `<n>Shift + A`                         |
| Back to line          | `<n>0`                                 |
| Up to start file      | `<n>GG`                                |
| Up to end file        | `<n>Shift + G`                         |
| Delete line           | `<n>D`                                 |
| Copy line             | `<n>Y`                                 |
| Paste line            | `<n>P`                                 |
| Select text           | `<v>Arrow buttons`                     |
| Change selected text  | `<v>C`                                 |


## 🗓️ Commands

| Action                | Command                                |
|-----------------------|----------------------------------------|
|  ☾ Dark theme         | `:Theme dark`                           |
| ☀️ Light theme        | `:Theme light`                          |
| 🔄 Reload vim         | `:Reload`                               |


## ✨ Features

- 🎨 OneDark theme with full UI customization
- 🔍 Fast file searching and fuzzy finding with Telescope
- 🧠 Autocompletion and diagnostics for Angular, Vue, React, Node, Express, TS, SCSS, JSON
- 🔄 Quick switching and splitting between files
- 📦 Git-aware terminal + statusline with branch/time
- ⚙️ Auto import/fix with
- 🖥️ Integrated Terminal
- ⚡ Fast Performance with Lazy.nvim plugin manager 


# 📸 Screenshots

---


<img width="1503" alt="Screenshot 2025-06-09 at 17 39 43" src="https://github.com/user-attachments/assets/b5e5aadc-f906-4b01-8bf4-6ec8d421bdde" />
<img width="1498" alt="Screenshot 2025-06-09 at 17 40 04" src="https://github.com/user-attachments/assets/a7739e31-ec71-4d50-9b3f-c87094ca6f68" />

---

## 📦 Installation

1. Install Neovim<br/>

    macOS<br />
    <code>brew install neovim</code>

    Windows<br />
    Download from: https://github.com/neovim/neovim/releases

2. Install Node.js<br/>

    macOS<br />
    <code>brew install neovim</code>

    Windows<br />
    Download from: https://nodejs.org/en/download

4. Install git<br />

    macOS<br />
    <code>brew install git</code>

    Windows<be />
    Download from: https://git-scm.com/downloads

5. Install a Nerd Font<br />
   https://www.nerdfonts.com/font-downloads

6. Clone NvLobiani<br />
   MacOs<br />
   Backup existing config (if any)<br />
   <code>[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup</code>
   
   Clone the configuration<br />
   <code>git clone https://github.com/Jortsoft/nvlobiani.git ~/.config/nvim</code>

   Windows<br />
   Backup existing config (if any)<br />
   <code>if (Test-Path "$env:LOCALAPPDATA\nvim") {
    Rename-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup"
    }</code><br />
    
   Clone the configuration<br />
   <code>git clone https://github.com/Jortsoft/nvlobiani.git "$env:LOCALAPPDATA\nvim"</code>

7. Install LSP servers and formatters<br />
   <code>npm install -g typescript-language-server</code>
   <code>npm install -g vscode-langservers-extractedr</code>
   <code>npm install -g prettier</code>

8. Install ripgrep<br />
   macOS<br />
   <code>brew install ripgrep</code>

   Windows/Powershell vis scoop<br />
   <code>scoop install ripgrep</code>

   
## 📦 First Launch
Open Neovim:<br />
<code>nvim</code>

Wait for plugins to install:

Lazy.nvim will automatically install all plugins on first launch
This may take a few minutes


Restart Neovim:

Close and reopen Neovim after plugins are installed


Set up your terminal font:

Configure your terminal to use a Nerd Font
This ensures icons display correctly

🤝 Contributing
Feel free to submit issues and enhancement requests!
📄 License
This configuration is open source and available under the MIT License.

Created by Jortsoft 🚀
   


   


   




