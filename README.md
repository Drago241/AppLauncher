---

# 🚀 AppLauncher.sh

A high-performance, feature-rich TUI Application Launcher written in Bash, specifically designed for users of the Fish Shell. It serves as a centralized hub for managing AppImages, Scripts, and Linux Binaries with built-in update tracking, categorization, and fuzzy-finding.

## ✨ Features

* **Smart Categorization:** Automatically groups your tools into categories (Media, Emulation, Dev Tools, etc.) and types (AppImages, Scripts, Binaries).
* **Advanced Theme Engine:** Switch between classic palettes, the sleek sage-green "mint" theme, or build your own custom UI directly in the app.
* **Reactive & Sensor-Aware Themes:** Dynamic UI that responds in real-time to your system's battery life, CPU load, network ping latency, and time of day.
* **"Feeling Lucky?":** Instantly randomize your interface with curated color pools, pointer icons, and separators to generate a completely unique layout.
* **Fuzzy Search:** Powered by fzf for lightning-fast navigation, complete with customizable keybindings.
* **Update Tracker:** Scans GitHub repositories and external links to compare local file timestamps/versions against remote releases.
* **First-Time Setup Wizard:** Automatically bootstraps your configurations, creates necessary files, and prompts for GitHub tokens and application seeds upon first run.
* **Integrated Help:** Press `Ctrl+H` to view the specific `-h` or `--help` documentation of any script directly within the preview window.

## 🛠️ Prerequisites

To enjoy the full experience, ensure you have the following installed:

* **fzf:** The interactive fuzzy finder.
* **fish:** The launcher is designed to execute `.fish` functions stored in your config.
* **jq:** Required for parsing GitHub API responses during update checks.
* **curl:** For fetching remote update data.
* **bc:** Required for math processing in the reactive/sensor-aware themes.
* **Nemo:** (Default GUI Editor) Or modify the `GUI_EDITOR` variable in the script to your preference (e.g., code, nvim).

## 🚀 Installation

1. **Clone the repository:**
```bash
git clone https://github.com/Drago241/AppLauncher.git
cd AppLauncher

```


2. **Make it executable:**
```bash
chmod +x AppLauncher.sh

```


3. **Run it!**
The new First-Time Setup Wizard will automatically create your `~/.config/fish/launcher_data.sh` file, ask for your GitHub Personal Access Token (to avoid API rate limiting), and help you seed your first application.

## ⌨️ Keybindings

| Key | Action |
| --- | --- |
| **Enter** | Launch selected application |
| **Left / Right** | Switch Tabs (All / Recent / Favorites / Updates) |
| **Tab** | Contextual Action (Filter categories / Toggle Recent mode / Scan updates) |
| **Ctrl + F** | Toggle Favorite (★) |
| **Ctrl + E** | Open the source `.fish` file in your editor |
| **Ctrl + N** | Add or edit a personal note for the selected app |
| **Ctrl + H** | Toggle app-specific help in the preview window |
| **Ctrl + A** | Launch with custom arguments |
| **Ctrl + T** | Open the Theme Picker & Builder |
| **Ctrl + R** | Reset filters / Return to "All" view |
| **Ctrl + B** | Toggle background color on/off |
| **Alt + P** | Cycle preview window position (Bottom, Right, Top, Left) |
| **Alt + I / D** | Increase (`I`) or Decrease (`D`) the preview window size |
| **Ctrl + /** | Show the Launcher help menu |

## 📝 How it Works

The script relies on a dynamically generated central data file (`~/.config/fish/launcher_data.sh`) to safely manage your GitHub token, category arrays, and aliases. It parses your `~/.config/fish/functions` directory to populate the launcher.

For the Update Tracker to work, it looks for specific metadata within your fish files:

* `--link "URL"`: The GitHub or web link to the project.
* `--version "1.0.0"`: The current local version.
* `--description "..."`: Short text shown in the preview pane.

---
