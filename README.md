# 🚀 AppLauncher.sh

**AppLauncher** is a high-performance, feature-rich TUI (Terminal User Interface) application manager written in Bash. Specifically optimized for the **Fish Shell**, it serves as a centralized hub for managing AppImages, scripts, and binaries with built-in update tracking, fuzzy-finding, and deep UI customization.

---

## ✨ Key Features

* **🗂️ Smart Categorization:** Automatically groups tools into logical categories (Media, Dev, Emulation) and types (AppImages, Binaries, Fish Scripts).
* **🎨 Advanced Theme Engine:** * **Built-in Palettes:** Choose from popular themes like Catppuccin, Dracula, and Rose Pine.
* **Reactive UI:** Experience themes that respond to system sensors—changing colors based on **battery life**, **CPU load**, **temperature**, and **network latency**.
* **"Feeling Lucky?":** A randomization engine that generates unique layouts with custom pointers and separators.


* **🔄 Integrated Update Tracker:** Scans your scripts for GitHub repository links and compares local versions against remote releases in real-time.
* **🔍 Power Searching:** Leverages `fzf` for lightning-fast navigation with a live preview window for app metadata and notes.
* **⚙️ Setup Wizard:** A built-in first-run configuration assistant that helps you set up paths and your GitHub API token.
* **📖 Live Documentation:** View `-h` or `--help` output of any script directly within the preview pane with `Ctrl+H`.

---

## 🛠️ Prerequisites

Ensure the following are installed on your system:

| Tool | Purpose |
| --- | --- |
| **`fzf`** | The core fuzzy-finding engine |
| **`fish`** | Required to execute the backend functions |
| **`jq`** | For parsing GitHub API data |
| **`curl`** | For network pings and update checks |
| **`bc`** | For calculating sensor values in reactive themes |

---

## 🚀 Getting Started

### 1. Installation

Clone the repository and make the script executable (the script itself is available in the releases section):

```bash
git clone https://github.com/Drago241/AppLauncher.git
cd AppLauncher
chmod +x AppLauncher.sh

```

### 2. Initial Setup

Run the script for the first time:

```bash
./AppLauncher.sh

```

The **First-Time Setup Wizard** will launch. It will prompt you for:

* A **GitHub Personal Access Token** (to avoid API rate limiting).
* Initial application seeds to get your categories started.
* Default paths for your favorites and history logs.

---

## ⌨️ Keybindings

| Key | Action |
| --- | --- |
| **Enter** | Launch selected application |
| **Left / Right** | Switch Tabs (All / Recent / Favorites / Updates) |
| **Tab** | Filter categories / Toggle Recent mode / Scan updates |
| **Ctrl + T** | **Open Theme Picker & Builder** |
| **Ctrl + R** | Reset filters to "All" view |
| **Ctrl + F** | Toggle Favorite (★) |
| **Ctrl + N** | Add/Edit personal notes for an app |
| **Ctrl + E** | Open the source `.fish` file in your editor |
| **Ctrl + H** | Toggle app-specific help in preview |
| **Alt + P** | Cycle preview window position |
| **Ctrl + /** | Show the full help menu |

---

## 📝 Script Metadata

To enable the **Update Tracker**, add this metadata format to the top of your Fish functions:

```fish
# --link "https://github.com/user/repo"
# --version "1.2.0"
# --description "A brief summary of what this app does"

```

## 📂 File Structure

* `~/.config/fish/launcher_data.sh`: Your main configuration and category data.
* `~/.config/fish/launcher_theme`: Stores your currently active theme.
* `~/.config/fish/themes/`: Directory for your custom-built theme files.
