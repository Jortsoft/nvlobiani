<img width="1495" alt="Screenshot 2025-06-09 at 17 31 21" src="https://github.com/user-attachments/assets/412978b3-e083-4d5e-a1b6-1cd2ffb93a49" />

# NvLobiani
NvLobiani is a Neovim configuration for web and full‑stack development with built‑in workflows for Angular, Vue, and Unity (C#).

**Leader key:** `<Space>`

**Highlights**
- Lazy.nvim plugin manager
- Telescope search and navigation
- LSP + completion (Angular/Vue/TypeScript/Unity)
- Auto‑imports and organize imports
- Built‑in Git helpers and conflict resolver
- Integrated terminal

**Requirements**
- Neovim (0.9+ recommended)
- Git
- Node.js + npm
- A Nerd Font in your terminal
- ripgrep (for fast search)

**Optional (Unity/C#)**
- .NET SDK (if OmniSharp uses `dotnet`)

---

## Installation

**macOS**
1. Install dependencies:
```bash
brew install neovim git node ripgrep
```

2. Backup existing config (optional):
```bash
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup
```

3. Clone:
```bash
git clone https://github.com/Jortsoft/nvlobiani.git ~/.config/nvim
```

**Windows (PowerShell)**
1. Install dependencies (with winget or scoop):
```powershell
winget install Neovim.Neovim Git.Git OpenJS.NodeJS BurntSushi.ripgrep.MSVC
```

2. Backup existing config (optional):
```powershell
if (Test-Path "$env:LOCALAPPDATA\nvim") { Rename-Item "$env:LOCALAPPDATA\nvim" "$env:LOCALAPPDATA\nvim.backup" }
```

3. Clone:
```powershell
git clone https://github.com/Jortsoft/nvlobiani.git "$env:LOCALAPPDATA\nvim"
```

---

## First Launch
1. Start Neovim:
```bash
nvim
```

2. Lazy.nvim will install plugins automatically on first run.

3. Restart Neovim after the plugin install finishes.

4. Set your terminal font to a Nerd Font so icons render correctly.

---

## Language Setup
NvLobiani supports Angular, Vue, and Unity. Use these commands:

**Commands**
- `:Framework angular` or `:Framework vue`
- `:SetLanguage unity`

**Keymaps**
- `<leader>la` Switch to Angular
- `<leader>lv` Switch to Vue
- `<leader>lu` Enable Unity (C#)

**Install LSP servers (recommended)**
Open Neovim and run:
```
:Mason
```
Then install these servers:
- `angularls`
- `tsserver` (or `ts_ls`)
- `volar` (or `vue_ls`)
- `omnisharp` (Unity/C#)

**Optional npm tools**
```bash
npm i -g typescript typescript-language-server @angular/language-server
npm i -g @vue/language-server @vue/typescript-plugin
npm i -g prettier eslint
```

---

## Keymaps

**Core**
| Action | Shortcut |
|---|---|
| Find files | `<leader>f` |
| Toggle file tree | `<leader>e` |
| Recent files | `<leader>r` |
| Live grep (project search) | `<leader>ff` |
| Search in current buffer | `<leader>l` |
| Toggle last buffer | `<leader>p` |
| Format + save all | `<leader>s` |
| Undo | `<leader><Left>` |
| Redo | `<leader><Right>` |
| Split same file (vertical) | `<leader>c` |
| Cycle splits | `<leader><Up>` |
| Toggle terminal | `<leader>t` |
| Close terminal (terminal mode) | `<leader>t` |
| Smart Go‑To Definition | `<leader><CR>` |
| Comment/uncomment (visual) | `<leader>/` |
| File manager actions | `<leader>j` |
| Auto import / organize imports | `<leader>i` |

**Git**
| Action | Shortcut |
|---|---|
| Show git changes | `<leader>gs` |
| Resolve git conflict | `<leader>g` |

**LSP**
| Action | Shortcut |
|---|---|
| Go to definition | `gd` |
| References | `gr` |
| Hover | `K` |
| Rename | `<leader>rn` |
| Code action | `<leader>ca` |

---

## Commands
| Action | Command |
|---|---|
| Reload config | `:Reload` |
| Show git changes | `:ShowChanges` |
| Switch framework | `:Framework angular` / `:Framework vue` |
| Enable Unity | `:SetLanguage unity` |
| Theme (examples) | `:Theme onedark` / `:Theme onelight` / `:Theme gruvbox` / `:Theme moonfly` / `:Theme cyberdream` / `:Theme tokyonight` / `:Theme githubdark` |

---

## Auto‑Imports
`<leader>i` runs an LSP code action to add missing imports and/or organize imports. This works for any language server that supports:
- `source.addMissingImports`
- `source.organizeImports`

---

## Screenshots
![3](https://github.com/user-attachments/assets/2ea5267a-abd8-4a34-8a10-d3f400a5e065)
![2](https://github.com/user-attachments/assets/1238989e-8b5a-437e-898f-6f21e8297488)
<img width="1503" alt="Screenshot 2025-06-09 at 17 39 43" src="https://github.com/user-attachments/assets/b5e5aadc-f906-4b01-8bf4-6ec8d421bdde" />
![1](https://github.com/user-attachments/assets/b3d912f5-da30-49d0-8cb5-9244af4b961a)
<img width="1498" alt="Screenshot 2025-06-09 at 17 40 04" src="https://github.com/user-attachments/assets/a7739e31-ec71-4d50-9b3f-c87094ca6f68" />

---

## Contributing
Issues and enhancement requests are welcome.

## License
MIT

Created by Jortsoft
