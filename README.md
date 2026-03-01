🚀 AppLauncher.sh

A high-performance, feature-rich TUI Application Launcher written in Bash, specifically designed for users of the Fish Shell. It serves as a centralized hub for managing AppImages, Scripts, and Linux Binaries with built-in update tracking, categorization, and fuzzy-finding.
✨ Features

    🗂️ Smart Categorization: Automatically groups your tools into categories (Media, Emulation, Dev Tools, etc.) and types (AppImages, Scripts, Binaries).

    🔍 Fuzzy Search: Powered by fzf for lightning-fast navigation.

    🔄 Update Tracker: Scans GitHub repositories and external links to compare local file timestamps/versions against remote releases.

    ⭐ Favorites & History: Quick access to your most-used applications and a "Recent" tab that toggles between used apps and recently modified script files.

    📖 Integrated Help: Press Ctrl+H to view the specific -h or --help documentation of any script directly within the preview window.

    🎨 Dynamic UI: Features a tabbed interface, progress bars for scans, and a clean, color-coded layout using tput.

🛠️ Prerequisites

To enjoy the full experience, ensure you have the following installed:

    fzf: The interactive fuzzy finder.

    fish: The launcher is designed to execute .fish functions stored in your config.

    jq: Required for parsing GitHub API responses during update checks.

    curl: For fetching update data.

    Nemo: (Default GUI Editor) Or modify the GUI_EDITOR variable in the script to your preference (e.g., code, nvim).

🚀 Installation

    Clone the repository:
    Bash

    git clone https://github.com/your-username/applauncher.git
    cd applauncher

    Make it executable:
    Bash

    chmod +x AppLauncher.sh

    Configure Paths:
    Open the script and ensure the following paths match your setup:
    Bash

    FISH_FUNCTIONS_DIR="$HOME/.config/fish/functions"
    FAVORITES_FILE="$HOME/.config/fish/launcher_favorites.txt"
    HISTORY_FILE="$HOME/.config/fish/launcher_history.txt"

    GitHub Token (Optional):
    For frequent update checking, replace the GITHUB_TOKEN variable with your own Personal Access Token to avoid API rate limiting.

⌨️ Keybindings
Key	Action
Enter	Launch selected application
Left / Right	Switch Tabs (All / Recent / Favorites / Updates)
Tab	Contextual Action (Filter categories / Toggle Recent mode / Scan updates)
Ctrl + F	Toggle Favorite (★)
Ctrl + E	Open the source .fish file in your editor
Ctrl + H	Toggle app-specific help in the preview window
Ctrl + A	Launch with custom arguments
Ctrl + /	Show the Launcher help menu

📝 How it Works

The script parses your ~/.config/fish/functions directory. For the Update Tracker to work, it looks for specific metadata within your fish files:

    --link "URL": The GitHub or web link to the project.

    --version "1.0.0": The current local version.

    --description "...": Short text shown in the preview pane.
