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
| Paset line            | `<n>P`                                 |
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

3. Install Node LSP tools<br />
   <code>npm install -g typescript typescript-language-server \ vscode-langservers-extracted @tailwindcss/language-server</code>

4. Clone this config<br />
   <code>git clone https://github.com/YOUR_USERNAME/nvim-config.git
   mv nvim-config/nvim ~/.config/</code>

    After installation, open NvLobiani<br />
    <code>nvim .</code>
    
    Press <b>shift + :</b> and type<br />
    <code>:checkhealth</code>
    
    If your Vim is working correctly, you can install plugins.<br />
    <code>:Lazy sync</code><br />
    <code>:Lazy update</code>




