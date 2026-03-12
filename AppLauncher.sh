#!/usr/bin/env bash

# ============================================================
# CONFIG & PATHS
# ============================================================
FISH_FUNCTIONS_DIR="$HOME/.config/fish/functions"
FAVORITES_FILE="$HOME/.config/fish/launcher_favorites.txt"
HISTORY_FILE="$HOME/.config/fish/launcher_history.txt"
UPDATE_CACHE="/tmp/launcher_update_cache"
NOTES_FILE="$HOME/.config/fish/launcher_notes.txt"
THEME_FILE="$HOME/.config/fish/launcher_theme"
DATA_FILE="$HOME/.config/fish/launcher_data.sh"

touch "$FAVORITES_FILE" "$HISTORY_FILE" "$NOTES_FILE"
mkdir -p "$UPDATE_CACHE"

# ============================================================
# DATA FILE — Load or create ~/.config/fish/launcher_data.sh
# ============================================================
_create_data_file() {
    local df="$1"
    # ── Ask for seed data ────────────────────────────────────
    echo ""
    echo "  ╭──────────────────────────────────────────────────────╮"
    echo "  │          LAUNCHER — First-Time Setup                 │"
    echo "  │  No data file found. Let's create one for you.       │"
    echo "  │  File: $df"
    echo "  ╰──────────────────────────────────────────────────────╯"
    echo ""
    echo "  Answer a few questions to seed the data file."
    echo "  (Press Enter to skip any field — you can edit the file later.)"
    echo ""

    # GitHub token
    printf "  GitHub Personal Access Token\n"
    printf "  (Create one at https://github.com/settings/tokens — scope: public_repo)\n"
    printf "  Token (or Enter to skip): "
    IFS= read -r _seed_token </dev/tty
    [[ -z "$_seed_token" ]] && _seed_token="your_github_pat_here"

    # Function alias
    printf "\n  Function alias (the .fish file name without extension, e.g. my-app): "
    IFS= read -r _seed_alias </dev/tty

    local _seed_display=""
    local _seed_cat_array="LINUX_EXECUTABLES"
    local _seed_cat_key="LINUX_EXECUTABLES"
    local _seed_subcat_array="MISCELLANEOUS"

    if [[ -n "$_seed_alias" ]]; then
        printf "  Display name for '%s' (e.g. My Application): " "$_seed_alias"
        IFS= read -r _seed_display </dev/tty
        [[ -z "$_seed_display" ]] && _seed_display="$_seed_alias"

        echo ""
        echo "  Category — how is it installed?"
        echo "    1) AppImages        (self-contained .AppImage file)"
        echo "    2) Linux Executables (native binary on PATH)"
        echo "    3) Scripts          (shell script)"
        printf "  Choice [1-3, default 2]: "
        IFS= read -r _seed_cat_choice </dev/tty
        case "$_seed_cat_choice" in
            1) _seed_cat_array="APPIMAGES" ;;
            3) _seed_cat_array="SCRIPTS" ;;
            *) _seed_cat_array="LINUX_EXECUTABLES" ;;
        esac

        echo ""
        echo "  Subcategory — what does it do?"
        echo "    1) Emulation          6) Media              11) Timers & Clocks"
        echo "    2) Games              7) Multiplexers        12) ToDo Lists"
        echo "    3) File Managers      8) System Cleaners     13) Typing-Speed Tests"
        echo "    4) File Transfer      9) System Tools        14) Terminals"
        echo "    5) File Viewer       10) Text Editors        15) Miscellaneous"
        printf "  Choice [1-15, default 15]: "
        IFS= read -r _seed_sub_choice </dev/tty
        case "$_seed_sub_choice" in
            1)  _seed_subcat_array="EMULATION" ;;
            2)  _seed_subcat_array="GAMES" ;;
            3)  _seed_subcat_array="FILE_MANAGERS" ;;
            4)  _seed_subcat_array="FILE_TRANSFER" ;;
            5)  _seed_subcat_array="FILE_VIEWERS" ;;
            6)  _seed_subcat_array="MEDIA" ;;
            7)  _seed_subcat_array="MULTIPLEXERS" ;;
            8)  _seed_subcat_array="SYSTEM_CLEANERS" ;;
            9)  _seed_subcat_array="SYSTEMTOOLS_AND_INFORMATION" ;;
            10) _seed_subcat_array="TEXT_EDITORS" ;;
            11) _seed_subcat_array="TIMERS_AND_CLOCKS" ;;
            12) _seed_subcat_array="TODO_LISTS" ;;
            13) _seed_subcat_array="TYPINGSPEED_TESTS" ;;
            14) _seed_subcat_array="TERMINALS" ;;
            *)  _seed_subcat_array="MISCELLANEOUS" ;;
        esac
    fi

    # ── Write the data file ──────────────────────────────────
    mkdir -p "$(dirname "$df")"
    cat > "$df" << DATAEOF
#!/usr/bin/env bash
# ============================================================
# LAUNCHER DATA FILE
# ============================================================
# Location : ${df}
# Purpose  : Stores your GitHub token, app aliases, and all
#            category / subcategory groupings for AL3.
#
# HOW TO ADD A NEW APP
# ─────────────────────────────────────────────────────────────
# 1. Add its alias in the ALIASES block below:
#       ["my-app"]="My App Display Name"
#
# 2. Add the alias to ONE category array (how it is installed):
#       APPIMAGES, SCRIPTS, or LINUX_EXECUTABLES
#
# 3. Add the alias to ONE subcategory array (what it does):
#       GAMES, FILE_MANAGERS, MEDIA, etc.
#       — or leave it out to fall through to "General"
#
# 4. That is it — the launcher picks up changes on next launch.
#
# HOW TO ADD A CUSTOM CATEGORY OR SUBCATEGORY
# ─────────────────────────────────────────────────────────────
# 1. Declare a new array anywhere in this file:
#       MY_NEW_GROUP=("app1" "app2")
#
# 2. Add an entry to CATEGORY_DEFS or SUBCATEGORY_DEFS:
#       "icon|Display Label|MY_NEW_GROUP"
#       Icons are Nerd Font glyphs or plain ASCII text.
# ============================================================


# ============================================================
# GITHUB TOKEN
# ============================================================
# Used to authenticate API calls that check for AppImage
# updates from GitHub releases.
# Create a token at: https://github.com/settings/tokens
# Required scope  : public_repo  (read-only is fine)
# ============================================================
GITHUB_TOKEN="${_seed_token}"


# ============================================================
# ALIASES — function alias → Display Name
# ============================================================
# Format : ["function-name"]="Human Readable Name"
# Example: ["my-app"]="My Application"
# ============================================================
declare -A ALIASES=(
DATAEOF

    # Append seed alias if provided
    if [[ -n "$_seed_alias" ]]; then
        echo "    [\"${_seed_alias}\"]=\"${_seed_display}\"" >> "$df"
    else
        echo "    # [\"example-app\"]=\"Example Application\"" >> "$df"
    fi

    cat >> "$df" << DATAEOF2
)


# ============================================================
# CATEGORIES — Type of installation
# ============================================================
# Each function alias must belong to exactly ONE category.
# Unrecognised functions (not in any array) show as "Other".
# ============================================================

# AppImages: distributed as self-contained .AppImage files
APPIMAGES=(
DATAEOF2

    [[ "$_seed_cat_array" == "APPIMAGES" && -n "$_seed_alias" ]] && echo "    \"${_seed_alias}\"" >> "$df"
    cat >> "$df" << DATAEOF3
)

# Scripts: shell scripts or interpreted programs
SCRIPTS=(
DATAEOF3

    [[ "$_seed_cat_array" == "SCRIPTS" && -n "$_seed_alias" ]] && echo "    \"${_seed_alias}\"" >> "$df"
    cat >> "$df" << DATAEOF4
)

# Linux Executables: native compiled binaries installed on PATH
LINUX_EXECUTABLES=(
DATAEOF4

    [[ "$_seed_cat_array" == "LINUX_EXECUTABLES" && -n "$_seed_alias" ]] && echo "    \"${_seed_alias}\"" >> "$df"
    cat >> "$df" << DATAEOF5
)

# ── Category Display Definitions ─────────────────────────────
# Format: "icon|Display Label|ARRAY_VARIABLE_NAME"
# ─────────────────────────────────────────────────────────────
CATEGORY_DEFS=(
    "󰗈|AppImages|APPIMAGES"
    "󰆍|Linux Executables|LINUX_EXECUTABLES"
    "󰈙|Scripts|SCRIPTS"
)


# ============================================================
# SUBCATEGORIES — Functional grouping
# ============================================================
# Each function alias can belong to ONE subcategory.
# Functions not listed in any array show as "General".
# ============================================================

EMULATION=()
GAMES=()
FILE_MANAGERS=()
DISKSPACE_VISUALIZERS=()
FILE_TRANSFER=()
FILE_VIEWERS=()
MEDIA=()
MULTIPLEXERS=()
SYSTEM_CLEANERS=()
SYSTEMTOOLS_AND_INFORMATION=()
TIMERS_AND_CLOCKS=()
TODO_LISTS=()
TYPINGSPEED_TESTS=()
TERMINALS=()
WEB_BROWSERS=()
OFFICE_SUITES=()
LAUNCHERS=()
TEXT_EDITORS=()
MISCELLANEOUS=(
DATAEOF5

    [[ "$_seed_subcat_array" == "MISCELLANEOUS" && -n "$_seed_alias" ]] && echo "    \"${_seed_alias}\"" >> "$df"
    # Handle non-MISCELLANEOUS seed subcategory
    if [[ -n "$_seed_alias" && "$_seed_subcat_array" != "MISCELLANEOUS" ]]; then
        # Rewrite the relevant empty array with the seed entry
        sed -i "s/^${_seed_subcat_array}=()/${_seed_subcat_array}=(\"${_seed_alias}\")/" "$df"
    fi

    cat >> "$df" << DATAEOF6
)

# ── Subcategory Display Definitions ──────────────────────────
# Format: "icon|Display Label|ARRAY_VARIABLE_NAME"
# ─────────────────────────────────────────────────────────────
SUBCATEGORY_DEFS=(
    "|Disk-Space Visualizers|DISKSPACE_VISUALIZERS"
    "󰘚|Emulation|EMULATION"
    "|File Managers|FILE_MANAGERS"
    "󰇚|File Transfer|FILE_TRANSFER"
    "|File Viewer|FILE_VIEWERS"
    "󱎓|Games|GAMES"
    "|Launchers|LAUNCHERS" 
    "|Media|MEDIA"
    "|Miscellaneous|MISCELLANEOUS"
    "󰖯|Multiplexers|MULTIPLEXERS"
    "󰃢|System Cleaners|SYSTEM_CLEANERS"
    "󰒓|System Tools & Information|SYSTEMTOOLS_AND_INFORMATION"
    "󱩼|Text Editors|TEXT_EDITORS"
    "󰥔|Timers & Clocks|TIMERS_AND_CLOCKS"
    "󰏫|ToDo Lists|TODO_LISTS"
    "󰌌|Typing-Speed Tests|TYPINGSPEED_TESTS"
    "󰞷|Terminals|TERMINALS"
    "󰖟|Web Browsers|WEB_BROWSERS"
    "󰏆|Office Suites|OFFICE_SUITES"
)
DATAEOF6

    echo ""
    echo "  ✔ Data file created: ${df}"
    echo "  Open it in your editor to add more apps and customise categories."
    echo ""
}

# ── Load or bootstrap data file ──────────────────────────────
if [[ ! -f "$DATA_FILE" ]]; then
    _create_data_file "$DATA_FILE"
fi
# shellcheck source=/dev/null
source "$DATA_FILE"

GUI_EDITOR="nemo"
PREVIEW_POSITION="bottom"
PREVIEW_SIZE="70%"
PIPE=" │ "
POINTER=""
BAR_ICON="#"          # Character used to fill the update progress bar

# ============================================================
# FEELING LUCKY? — Custom character pools
# ──────────────────────────────────────────────────────────
# Add or remove entries freely; Feeling Lucky? picks one at
# random from each array on every roll.
# ──────────────────────────────────────────────────────────
# PIPES  — column-separator shown in the list rows.
#          Include surrounding spaces, e.g. " ┃ "
LUCKY_PIPES=(" │ " " ┃ " " ╎ " " ▏ " " ⋮ " " ┊ " " ╏ " "  " "  " "  " "  " " 󰇝 " " 󰮾 ")
# POINTERS — fzf cursor/selection arrow.
#            Empty string "" = fzf's built-in default (▶)
LUCKY_POINTERS=("" "▶" "➤" "›" "❯" "⟩" "⦚" "" "" "󰁁" "" "" "" "󰞔" "󰜴")
# BAR ICONS — fill character for the update-scan progress bar.
#             Single chars or simple unicode work best.
LUCKY_BAR_ICONS=("#" "█" "▓" "▒" "░" "=" "-" "+" "~" "•" "◆" "★" "▪" "" "" "" "󰇝" "󱤩" "󰚉")
# ============================================================
# ============================================================
# THEME & COLORS
# ============================================================
RESET=$(tput sgr0)
BOLD=$(tput bold)
DIM=$(tput dim)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)

# ── Theme engine ─────────────────────────────────────────────
# Load saved theme (falls back to "default")
[[ -f "$THEME_FILE" ]] && CURRENT_THEME=$(cat "$THEME_FILE") || CURRENT_THEME="dynamic"
[[ -n "$LAUNCHER_THEME" ]] && CURRENT_THEME="$LAUNCHER_THEME"

# BG state: all themes default to bg ON
USE_BG=1

apply_theme() {
    local theme="$1"
    # Each theme sets: ACCENT GOLD FG GOOD BAD (tput codes)
    #                  BG_COLOR (fzf 256-colour int for solid bg; -1 = terminal default)
    #                  _FZF ("fg:N,hl:N|fg+:N,bg+:N,hl+:N|info:N,prompt:N,pointer:N,spinner:N|border:N,header:N")
    case "$theme" in
        dynamic)
            # Merged Original + Dynamic — ANSI 0–15, fully controlled by terminal palette
            # Background togglable: OFF = terminal default, ON = solid black (BG_COLOR=0)
            ACCENT=$(tput setaf 4)
            GOLD=$(tput setaf 3)
            FG=$(tput setaf 7)
            GOOD=$(tput setaf 2)
            BAD=$(tput setaf 1)
            BG_COLOR=0
            _FZF="fg:7,hl:4|fg+:15,bg+:8,hl+:6|info:2,prompt:4,pointer:4,spinner:2|border:8,header:4,label:4,gutter:8|marker:4,query:15,disabled:8,preview-fg:7,preview-bg:0,preview-border:8,preview-scrollbar:4,preview-label:4"
            ;;
        feeling-lucky)
            # Randomise from curated colour palettes — each roll is saved as a unique .theme file
            local _vib=(27 33 39 45 51 63 69 75 81 87 93 99 105 111 117 129 135 141 147 153 165 171 177 183 196 197 198 199 200 201 202 203 204 205 206 207 208 209 210 211 212 213 214 215 216 217 218 219 220 221 222 226 227 228)
            local _grn=(40 46 47 48 76 77 82 83 84 114 115 118 119 120 148 154 155 156)
            local _red=(160 161 167 168 174 196 197 198 203 204 205 210 211)
            local _drk=(16 232 233 234 235 236 237 238)
            local _lgt=(250 251 252 253 254 255)
            local _pos_arr=("bottom" "right" "top" "left")
            local _ra="${_vib[$((RANDOM % ${#_vib[@]}))]}"
            local _rg="${_vib[$((RANDOM % ${#_vib[@]}))]}"
            local _rgd="${_grn[$((RANDOM % ${#_grn[@]}))]}"
            local _rb="${_red[$((RANDOM % ${#_red[@]}))]}"
            local _rf="${_lgt[$((RANDOM % ${#_lgt[@]}))]}"
            local _rbg="${_drk[$((RANDOM % ${#_drk[@]}))]}"
            local _rbgp=$(( _rbg + 2 )); [[ $_rbgp -gt 238 ]] && _rbgp=238
            
            # Randomise preview position, size, pipe, and pointer
            PREVIEW_POSITION="${_pos_arr[$((RANDOM % 4))]}"
            local _rpsize=$(( 35 + (RANDOM % 41) ))
            PREVIEW_SIZE="${_rpsize}%"
            
            if [[ ${#LUCKY_PIPES[@]} -gt 0 ]]; then
                PIPE="${LUCKY_PIPES[$((RANDOM % ${#LUCKY_PIPES[@]}))]}"
            fi
            if [[ ${#LUCKY_POINTERS[@]} -gt 0 ]]; then
                POINTER="${LUCKY_POINTERS[$((RANDOM % ${#LUCKY_POINTERS[@]}))]}"
            fi
            if [[ ${#LUCKY_BAR_ICONS[@]} -gt 0 ]]; then
                BAR_ICON="${LUCKY_BAR_ICONS[$((RANDOM % ${#LUCKY_BAR_ICONS[@]}))]}"
            fi
            
            local _rbdr="${_vib[$((RANDOM % ${#_vib[@]}))]}"
            ACCENT=$(tput setaf "$_ra")
            GOLD=$(tput setaf "$_rg")
            FG=$(tput setaf "$_rf")
            GOOD=$(tput setaf "$_rgd")
            BAD=$(tput setaf "$_rb")
            BG_COLOR=$_rbg
            _FZF="fg:${_rf},hl:${_ra}:bold|fg+:255:bold,bg+:${_rbgp},hl+:${_ra}:bold|info:${_rgd}:dim,prompt:${_ra}:bold,pointer:${_ra}:bold,spinner:${_rgd}:dim|border:${_rbdr}:bold,header:${_ra}:bold,label:${_ra}:bold,gutter:${_rbgp}:dim|marker:${_ra}:bold,query:255:bold,disabled:${_rbgp}:dim,preview-fg:${_rf},preview-bg:${_rbg},preview-border:${_rbdr}:bold,preview-scrollbar:${_ra},preview-label:${_ra}:bold"
            
            local _ts; _ts=$(date +"%Y%m%d-%H%M%S")
            local _lf="$HOME/.config/fish/themes/lucky-${_ts}.theme"
            mkdir -p "$HOME/.config/fish/themes"
            
            printf '# Auto-generated by Feeling Lucky? — %s\nTHEME_LABEL="Lucky (%s)"\nTHEME_ACCENT=%d\nTHEME_GOLD=%d\nTHEME_FG=%d\nTHEME_GOOD=%d\nTHEME_BAD=%d\nTHEME_BG=%d\nTHEME_BORDER=%d\nTHEME_FZF="%s"\nTHEME_PREVIEW_POS="%s"\nTHEME_PREVIEW_SIZE="%s"\nTHEME_PIPE="%s"\nTHEME_POINTER="%s"\nTHEME_BAR_ICON="%s"\n' \
                "$_ts" "$_ts" "$_ra" "$_rg" "$_rf" "$_rgd" "$_rb" "$_rbg" "$_rbdr" "$_FZF" \
                "$PREVIEW_POSITION" "$PREVIEW_SIZE" "$PIPE" "$POINTER" "$BAR_ICON" > "$_lf"
            
            local _lucky_key="lucky-${_ts}"
            CURRENT_THEME="$_lucky_key"
            THEME_LABELS["$_lucky_key"]="Lucky (${_ts})"
            ;;
        # ── STATIC THEMES ────────────────────
        nordic-night)
            # High-contrast Arctic Frost
            ACCENT=$(tput setaf 123); GOLD=$(tput setaf 110); FG=$(tput setaf 255); GOOD=$(tput setaf 34); BAD=$(tput setaf 167)
            BG_COLOR=234
            _FZF="fg:255,hl:123|fg+:123,bg+:236,hl+:110|info:110,prompt:123,pointer:123,spinner:110|border:110,header:123,label:123,gutter:236|marker:123,query:255,disabled:241,preview-fg:255,preview-bg:234,preview-border:110,preview-scrollbar:123,preview-label:123" ;;
        dracula)
            # High-contrast Vampire palette
            ACCENT=$(tput setaf 141); GOLD=$(tput setaf 228); FG=$(tput setaf 253); GOOD=$(tput setaf 84); BAD=$(tput setaf 212)
            BG_COLOR=235
            _FZF="fg:253,hl:141|fg+:255,bg+:236,hl+:212|info:84,prompt:141,pointer:212,spinner:84|border:141,header:141,label:141,gutter:236|marker:212,query:255,disabled:241,preview-fg:253,preview-bg:235,preview-border:141,preview-scrollbar:141,preview-label:141" ;;
        catppuccin)
            # Mocha palette — soothing pastels
            ACCENT=$(tput setaf 117); GOLD=$(tput setaf 221); FG=$(tput setaf 254); GOOD=$(tput setaf 115); BAD=$(tput setaf 210)
            BG_COLOR=234
            _FZF="fg:254,hl:117|fg+:255,bg+:236,hl+:117|info:115,prompt:117,pointer:117,spinner:115|border:117,header:117,label:117,gutter:236|marker:117,query:255,disabled:240,preview-fg:254,preview-bg:234,preview-border:117,preview-scrollbar:117,preview-label:117" ;;
        rose-pine)
            # SoHo Dusty Rose & Gold
            ACCENT=$(tput setaf 210); GOLD=$(tput setaf 222); FG=$(tput setaf 252); GOOD=$(tput setaf 116); BAD=$(tput setaf 174)
            BG_COLOR=233
            _FZF="fg:252,hl:210|fg+:255,bg+:235,hl+:222|info:116,prompt:210,pointer:210,spinner:116|border:236,header:210,label:210,gutter:235|marker:210,query:255,disabled:241,preview-fg:252,preview-bg:233,preview-border:235,preview-scrollbar:210,preview-label:210" ;;
        tokyo-night)
            # Deep Storm Blue
            ACCENT=$(tput setaf 111); GOLD=$(tput setaf 215); FG=$(tput setaf 250); GOOD=$(tput setaf 120); BAD=$(tput setaf 203)
            BG_COLOR=234
            _FZF="fg:250,hl:111|fg+:255,bg+:235,hl+:111|info:120,prompt:111,pointer:111,spinner:120|border:237,header:111,label:111,gutter:235|marker:111,query:255,disabled:241,preview-fg:250,preview-bg:234,preview-border:235,preview-scrollbar:111,preview-label:111" ;;
        monokai)
            ACCENT=$(tput setaf 208); GOLD=$(tput setaf 228); FG=$(tput setaf 252); GOOD=$(tput setaf 148); BAD=$(tput setaf 197)
            BG_COLOR=234
            _FZF="fg:252,hl:208|fg+:255,bg+:236,hl+:148|info:148,prompt:208,pointer:208,spinner:148|border:236,header:208,label:208,gutter:236|marker:208,query:255,disabled:241,preview-fg:252,preview-bg:234,preview-border:236,preview-scrollbar:208,preview-label:208" ;;
        solarized)
            # Classic Solarized Dark — teal bg, cyan & gold accents
            ACCENT=$(tput setaf 37);  GOLD=$(tput setaf 136); FG=$(tput setaf 109); GOOD=$(tput setaf 64);  BAD=$(tput setaf 160)
            BG_COLOR=23
            _FZF="fg:109,hl:37|fg+:230,bg+:24,hl+:136|info:64,prompt:37,pointer:136,spinner:64|border:30,header:37,label:136,gutter:24|marker:136,query:230,disabled:66,preview-fg:109,preview-bg:23,preview-border:30,preview-scrollbar:37,preview-label:136" ;;
        everforest)
            # Comfortable Forest Green
            ACCENT=$(tput setaf 108); GOLD=$(tput setaf 208); FG=$(tput setaf 223); GOOD=$(tput setaf 142); BAD=$(tput setaf 167)
            BG_COLOR=235
            _FZF="fg:223,hl:108|fg+:231,bg+:237,hl+:142|info:142,prompt:108,pointer:108,spinner:142|border:238,header:108,label:108,gutter:237|marker:108,query:255,disabled:241,preview-fg:223,preview-bg:235,preview-border:237,preview-scrollbar:108,preview-label:108" ;;
        cyberpunk)
            # Neon High-Voltage 
            ACCENT=$(tput setaf 198); GOLD=$(tput setaf 51); FG=$(tput setaf 255); GOOD=$(tput setaf 51); BAD=$(tput setaf 196)
            BG_COLOR=232
            _FZF="fg:255,hl:198|fg+:198,bg+:234,hl+:51|info:51,prompt:198,pointer:198,spinner:51|border:198,header:198,label:198,gutter:234|marker:198,query:255,disabled:234,preview-fg:255,preview-bg:232,preview-border:198,preview-scrollbar:198,preview-label:198" ;;
        monochrome)
            # Focused Grayscale Pro 
            ACCENT=$(tput setaf 248); GOLD=$(tput setaf 244); FG=$(tput setaf 252); GOOD=$(tput setaf 250); BAD=$(tput setaf 240)
            BG_COLOR=233
            _FZF="fg:250,hl:255|fg+:255,bg+:235,hl+:255|info:244,prompt:252,pointer:255,spinner:244|border:236,header:252,label:252,gutter:235|marker:252,query:255,disabled:240,preview-fg:250,preview-bg:233,preview-border:236,preview-scrollbar:252,preview-label:252" ;;
        onedark)
            ACCENT=$(tput setaf 75);  GOLD=$(tput setaf 221); FG=$(tput setaf 252); GOOD=$(tput setaf 114); BAD=$(tput setaf 204)
            BG_COLOR=235
            _FZF="fg:252,hl:75|fg+:255,bg+:237,hl+:75|info:114,prompt:75,pointer:75,spinner:114|border:237,header:75,label:75,gutter:237|marker:75,query:255,disabled:240,preview-fg:252,preview-bg:235,preview-border:237,preview-scrollbar:75,preview-label:75" ;;
        ocean)
            # Deep Ocean — electric cyan & seafoam on abyssal navy
            ACCENT=$(tput setaf 39);  GOLD=$(tput setaf 86); FG=$(tput setaf 255); GOOD=$(tput setaf 86);  BAD=$(tput setaf 197)
            BG_COLOR=17
            _FZF="fg:255,hl:45|fg+:255,bg+:18,hl+:87|info:86,prompt:39,pointer:45,spinner:86|border:39,header:45,label:86,gutter:18|marker:87,query:255,disabled:60,preview-fg:255,preview-bg:17,preview-border:39,preview-scrollbar:45,preview-label:86" ;;
        matrix)
            # Digital Rain — pure green on black
            ACCENT=$(tput setaf 46); GOLD=$(tput setaf 34); FG=$(tput setaf 82); GOOD=$(tput setaf 10); BAD=$(tput setaf 22)
            BG_COLOR=16
            _FZF="fg:46,hl:82|fg+:15,bg+:22,hl+:46|info:34,prompt:46,pointer:82,spinner:34|border:34,header:46,label:46,gutter:22|marker:46,query:15,disabled:22,preview-fg:46,preview-bg:16,preview-border:34,preview-scrollbar:46,preview-label:46" ;;
        cyber-blood)
            # Crimson & Carbon — deep red on near-black
            ACCENT=$(tput setaf 160); GOLD=$(tput setaf 214); FG=$(tput setaf 255); GOOD=$(tput setaf 34); BAD=$(tput setaf 196)
            BG_COLOR=16
            _FZF="fg:255,hl:160|fg+:160,bg+:233,hl+:214|info:160,prompt:160,pointer:160,spinner:160|border:160,header:160,label:160,gutter:233|marker:160,query:255,disabled:233,preview-fg:255,preview-bg:16,preview-border:160,preview-scrollbar:160,preview-label:160" ;;
        e-ink)
            # E-Ink Paper Display — maximum contrast, white bg
            ACCENT=$(tput setaf 0); GOLD=$(tput setaf 240); FG=$(tput setaf 232); GOOD=$(tput setaf 240); BAD=$(tput setaf 0)
            BG_COLOR=255
            _FZF="fg:232,hl:232|fg+:255,bg+:232,hl+:255|info:240,prompt:232,pointer:232,spinner:240|border:232,header:232,label:232,gutter:232|marker:232,query:232,disabled:240,preview-fg:232,preview-bg:255,preview-border:232,preview-scrollbar:240,preview-label:240" ;;

        # ── SPECIAL THEMES (Reactive / Sensor-Aware) ─────────────
        chameleon)
            # Adapts to time of day: warm amber at night, sky blue by day
            GOLD=$(tput setaf 3); GOOD=$(tput setaf 2); BAD=$(tput setaf 1)
            local _ch; _ch=$(date +%H)
            if [ "$_ch" -ge 18 ] || [ "$_ch" -lt 6 ]; then
                ACCENT=$(tput setaf 172); FG=$(tput setaf 250); BG_COLOR=234
                _FZF="fg:250,hl:172|fg+:255,bg+:235,hl+:178|info:172,prompt:172,pointer:172,spinner:172|border:235,header:172,label:172,gutter:235|marker:172,query:255,disabled:235,preview-fg:250,preview-bg:234,preview-border:235,preview-scrollbar:172,preview-label:172"
            else
                ACCENT=$(tput setaf 32); FG=$(tput setaf 235); BG_COLOR=231
                _FZF="fg:235,hl:32|fg+:232,bg+:254,hl+:32|info:32,prompt:32,pointer:32,spinner:32|border:250,header:32,label:32,gutter:254|marker:32,query:232,disabled:250,preview-fg:235,preview-bg:231,preview-border:250,preview-scrollbar:32,preview-label:32"
            fi ;;
        connection)
            # Network ping reactive: green=fast, yellow=slow, red=offline
            GOLD=$(tput setaf 3); FG=$(tput setaf 7); GOOD=$(tput setaf 2); BAD=$(tput setaf 1); BG_COLOR=-1
            if ping -c 1 -W 1 8.8.8.8 >/dev/null 2>&1; then
                local _rt; _rt=$(ping -c 1 8.8.8.8 2>/dev/null | grep 'time=' | sed 's/.*time=\([0-9]*\).*/\1/')
                if [ "${_rt:-999}" -lt 50 ] 2>/dev/null; then
                    ACCENT=$(tput setaf 2)
                    _FZF="fg:7,hl:2|fg+:15,bg+:237,hl+:2|info:2,prompt:2,pointer:2,spinner:2|border:2,header:2,label:2,gutter:237|marker:2,query:15,disabled:237,preview-fg:7,preview-bg:-1,preview-border:2,preview-scrollbar:2,preview-label:2"
                else
                    ACCENT=$(tput setaf 3)
                    _FZF="fg:7,hl:3|fg+:15,bg+:237,hl+:3|info:3,prompt:3,pointer:3,spinner:3|border:3,header:3,label:3,gutter:237|marker:3,query:15,disabled:237,preview-fg:7,preview-bg:-1,preview-border:3,preview-scrollbar:3,preview-label:3"
                fi
            else
                ACCENT=$(tput setaf 1)
                _FZF="fg:7,hl:1|fg+:15,bg+:237,hl+:1|info:1,prompt:1,pointer:1,spinner:1|border:1,header:1,label:1,gutter:237|marker:1,query:15,disabled:237,preview-fg:7,preview-bg:-1,preview-border:1,preview-scrollbar:1,preview-label:1"
            fi ;;
        storage)
            # Disk usage reactive: green=ok, yellow=70%+, red=90%+
            GOLD=$(tput setaf 3); GOOD=$(tput setaf 2); BAD=$(tput setaf 1)
            local _usg; _usg=$(df "$HOME" | tail -1 | awk '{print $5}' | sed 's/%//')
            if [ "${_usg:-0}" -gt 90 ] 2>/dev/null; then
                ACCENT=$(tput setaf 196); FG=$(tput setaf 255); BG_COLOR=52
                _FZF="fg:255,hl:196|fg+:255,bg+:124,hl+:196|info:196,prompt:196,pointer:196,spinner:196|border:196,header:196,label:196,gutter:124|marker:196,query:255,disabled:124,preview-fg:255,preview-bg:52,preview-border:196,preview-scrollbar:196,preview-label:196"
            elif [ "${_usg:-0}" -gt 70 ] 2>/dev/null; then
                ACCENT=$(tput setaf 214); FG=$(tput setaf 7); BG_COLOR=-1
                _FZF="fg:7,hl:214|fg+:15,bg+:237,hl+:214|info:214,prompt:214,pointer:214,spinner:214|border:214,header:214,label:214,gutter:237|marker:214,query:15,disabled:237,preview-fg:7,preview-bg:-1,preview-border:214,preview-scrollbar:214,preview-label:214"
            else
                ACCENT=$(tput setaf 34); FG=$(tput setaf 7); BG_COLOR=-1
                _FZF="fg:7,hl:34|fg+:15,bg+:237,hl+:34|info:34,prompt:34,pointer:34,spinner:34|border:34,header:34,label:34,gutter:237|marker:34,query:15,disabled:237,preview-fg:7,preview-bg:-1,preview-border:34,preview-scrollbar:34,preview-label:34"
            fi ;;
        thermal)
            # CPU temperature reactive: blue=cool, red=hot (>60°C)
            GOLD=$(tput setaf 3); GOOD=$(tput setaf 2); BAD=$(tput setaf 1); BG_COLOR=-1
            local _tmp; _tmp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
            _tmp=$((_tmp / 1000))
            if [ "$_tmp" -gt 60 ] 2>/dev/null; then
                ACCENT=$(tput setaf 1); FG=$(tput setaf 7)
                _FZF="fg:7,hl:1|fg+:15,bg+:237,hl+:1|info:1,prompt:1,pointer:1,spinner:1|border:1,header:1,label:1,gutter:237|marker:1,query:15,disabled:237,preview-fg:7,preview-bg:-1,preview-border:1,preview-scrollbar:1,preview-label:1"
            else
                ACCENT=$(tput setaf 81); FG=$(tput setaf 7)
                _FZF="fg:7,hl:81|fg+:15,bg+:237,hl+:81|info:81,prompt:81,pointer:81,spinner:81|border:81,header:81,label:81,gutter:237|marker:81,query:15,disabled:237,preview-fg:7,preview-bg:-1,preview-border:81,preview-scrollbar:81,preview-label:81"
            fi ;;
        chronos-ultra)
            # 12-phase time-of-day engine — unique palette for every 2-hour block
            GOLD=$(tput setaf 220); GOOD=$(tput setaf 2); BAD=$(tput setaf 1); FG=$(tput setaf 250)
            local _chu; _chu=$(date +%H)
            case "$_chu" in
                00|01) ACCENT=$(tput setaf 57);  BG_COLOR=16;  _FZF="fg:245,hl:57|fg+:255,bg+:232,hl+:57|info:57,prompt:57,pointer:57,spinner:57|border:57,header:57,label:57,gutter:232|marker:57,query:255,disabled:232,preview-fg:245,preview-bg:16,preview-border:57,preview-scrollbar:57,preview-label:57" ;;
                02|03) ACCENT=$(tput setaf 239); BG_COLOR=232; _FZF="fg:248,hl:239|fg+:255,bg+:233,hl+:239|info:239,prompt:239,pointer:239,spinner:239|border:239,header:239,label:239,gutter:233|marker:239,query:255,disabled:233,preview-fg:248,preview-bg:232,preview-border:239,preview-scrollbar:239,preview-label:239" ;;
                04|05) ACCENT=$(tput setaf 147); BG_COLOR=234; _FZF="fg:253,hl:147|fg+:255,bg+:235,hl+:147|info:147,prompt:147,pointer:147,spinner:147|border:147,header:147,label:147,gutter:235|marker:147,query:255,disabled:235,preview-fg:253,preview-bg:234,preview-border:147,preview-scrollbar:147,preview-label:147" ;;
                06|07) ACCENT=$(tput setaf 209); BG_COLOR=234; _FZF="fg:255,hl:209|fg+:255,bg+:235,hl+:209|info:209,prompt:209,pointer:209,spinner:209|border:209,header:209,label:209,gutter:235|marker:209,query:255,disabled:235,preview-fg:255,preview-bg:234,preview-border:209,preview-scrollbar:209,preview-label:209" ;;
                08|09) ACCENT=$(tput setaf 121); BG_COLOR=-1;  _FZF="fg:252,hl:121|fg+:255,bg+:236,hl+:121|info:121,prompt:121,pointer:121,spinner:121|border:121,header:121,label:121,gutter:236|marker:121,query:255,disabled:236,preview-fg:252,preview-bg:-1,preview-border:121,preview-scrollbar:121,preview-label:121" ;;
                10|11) ACCENT=$(tput setaf 117); BG_COLOR=-1;  _FZF="fg:255,hl:117|fg+:255,bg+:237,hl+:117|info:117,prompt:117,pointer:117,spinner:117|border:117,header:117,label:117,gutter:237|marker:117,query:255,disabled:237,preview-fg:255,preview-bg:-1,preview-border:117,preview-scrollbar:117,preview-label:117" ;;
                12|13) ACCENT=$(tput setaf 33);  BG_COLOR=231; _FZF="fg:235,hl:33|fg+:232,bg+:254,hl+:33|info:33,prompt:33,pointer:33,spinner:33|border:244,header:33,label:33,gutter:254|marker:33,query:232,disabled:254,preview-fg:235,preview-bg:231,preview-border:244,preview-scrollbar:33,preview-label:33" ;;
                14|15) ACCENT=$(tput setaf 222); BG_COLOR=-1;  _FZF="fg:255,hl:222|fg+:255,bg+:236,hl+:222|info:222,prompt:222,pointer:222,spinner:222|border:222,header:222,label:222,gutter:236|marker:222,query:255,disabled:236,preview-fg:255,preview-bg:-1,preview-border:222,preview-scrollbar:222,preview-label:222" ;;
                16|17) ACCENT=$(tput setaf 202); BG_COLOR=233; _FZF="fg:255,hl:202|fg+:255,bg+:234,hl+:202|info:202,prompt:202,pointer:202,spinner:202|border:202,header:202,label:202,gutter:234|marker:202,query:255,disabled:234,preview-fg:255,preview-bg:233,preview-border:202,preview-scrollbar:202,preview-label:202" ;;
                18|19) ACCENT=$(tput setaf 161); BG_COLOR=232; _FZF="fg:252,hl:161|fg+:255,bg+:233,hl+:161|info:161,prompt:161,pointer:161,spinner:161|border:161,header:161,label:161,gutter:233|marker:161,query:255,disabled:233,preview-fg:252,preview-bg:232,preview-border:161,preview-scrollbar:161,preview-label:161" ;;
                20|21) ACCENT=$(tput setaf 63);  BG_COLOR=232; _FZF="fg:250,hl:63|fg+:255,bg+:233,hl+:63|info:63,prompt:63,pointer:63,spinner:63|border:63,header:63,label:63,gutter:233|marker:63,query:255,disabled:233,preview-fg:250,preview-bg:232,preview-border:63,preview-scrollbar:63,preview-label:63" ;;
                22|23) ACCENT=$(tput setaf 243); BG_COLOR=16;  _FZF="fg:246,hl:243|fg+:255,bg+:232,hl+:243|info:243,prompt:243,pointer:243,spinner:243|border:243,header:243,label:243,gutter:232|marker:243,query:255,disabled:232,preview-fg:246,preview-bg:16,preview-border:243,preview-scrollbar:243,preview-label:243" ;;
            esac ;;
        earth-guard)
            # CPU load reactive: moss green=idle, earthy brown=busy
            GOLD=$(tput setaf 178); GOOD=$(tput setaf 2); BAD=$(tput setaf 1)
            local _egl; _egl=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | sed 's/ //g' | cut -d. -f1)
            if [ "${_egl:-0}" -gt 1 ] 2>/dev/null; then
                ACCENT=$(tput setaf 130); FG=$(tput setaf 250); BG_COLOR=233
                _FZF="fg:250,hl:130|fg+:255,bg+:234,hl+:130|info:130,prompt:130,pointer:130,spinner:130|border:130,header:130,label:130,gutter:234|marker:130,query:255,disabled:234,preview-fg:250,preview-bg:233,preview-border:130,preview-scrollbar:130,preview-label:130"
            else
                ACCENT=$(tput setaf 108); FG=$(tput setaf 223); BG_COLOR=234
                _FZF="fg:223,hl:108|fg+:255,bg+:235,hl+:108|info:108,prompt:108,pointer:108,spinner:108|border:108,header:108,label:108,gutter:235|marker:108,query:255,disabled:235,preview-fg:223,preview-bg:234,preview-border:108,preview-scrollbar:108,preview-label:108"
            fi ;;
        vaporwave)
            # Neon 80s aesthetic — hot pink & electric cyan
            ACCENT=$(tput setaf 201); GOLD=$(tput setaf 51); FG=$(tput setaf 255); GOOD=$(tput setaf 51); BAD=$(tput setaf 196)
            BG_COLOR=233
            _FZF="fg:255,hl:201|fg+:201,bg+:234,hl+:51|info:51,prompt:201,pointer:201,spinner:51|border:201,header:201,label:201,gutter:234|marker:201,query:255,disabled:234,preview-fg:255,preview-bg:233,preview-border:201,preview-scrollbar:201,preview-label:201" ;;
        heavy-metal)
            # Downloads folder size: silver=light, deep red=heavy (>5 GB)
            GOLD=$(tput setaf 3); GOOD=$(tput setaf 2); BAD=$(tput setaf 1)
            local _hms; _hms=$(du -s "$HOME/Downloads" 2>/dev/null | cut -f1)
            if [ "${_hms:-0}" -gt 5000000 ] 2>/dev/null; then
                ACCENT=$(tput setaf 160); FG=$(tput setaf 160); BG_COLOR=232
                _FZF="fg:160,hl:196|fg+:255,bg+:233,hl+:196|info:160,prompt:160,pointer:160,spinner:160|border:160,header:160,label:160,gutter:233|marker:160,query:255,disabled:233,preview-fg:160,preview-bg:232,preview-border:160,preview-scrollbar:160,preview-label:160"
            else
                ACCENT=$(tput setaf 248); FG=$(tput setaf 250); BG_COLOR=-1
                _FZF="fg:250,hl:244|fg+:255,bg+:235,hl+:244|info:248,prompt:248,pointer:248,spinner:248|border:244,header:248,label:248,gutter:235|marker:248,query:255,disabled:240,preview-fg:250,preview-bg:-1,preview-border:244,preview-scrollbar:248,preview-label:248"
            fi ;;
        skyline)
            # Time-of-day cityscape: gold sunrise, blue afternoon, purple night
            GOLD=$(tput setaf 3); GOOD=$(tput setaf 2); BAD=$(tput setaf 1)
            local _skh; _skh=$(date +%H)
            if [ "$_skh" -lt 10 ]; then
                ACCENT=$(tput setaf 214); FG=$(tput setaf 222); BG_COLOR=234
                _FZF="fg:222,hl:214|fg+:255,bg+:235,hl+:214|info:214,prompt:214,pointer:214,spinner:214|border:214,header:214,label:214,gutter:235|marker:214,query:255,disabled:235,preview-fg:222,preview-bg:234,preview-border:214,preview-scrollbar:214,preview-label:214"
            elif [ "$_skh" -lt 17 ]; then
                ACCENT=$(tput setaf 75); FG=$(tput setaf 255); BG_COLOR=234
                _FZF="fg:255,hl:75|fg+:255,bg+:235,hl+:75|info:75,prompt:75,pointer:75,spinner:75|border:75,header:75,label:75,gutter:235|marker:75,query:255,disabled:235,preview-fg:255,preview-bg:234,preview-border:75,preview-scrollbar:75,preview-label:75"
            else
                ACCENT=$(tput setaf 105); FG=$(tput setaf 189); BG_COLOR=232
                _FZF="fg:189,hl:105|fg+:255,bg+:233,hl+:105|info:105,prompt:105,pointer:105,spinner:105|border:105,header:105,label:105,gutter:233|marker:105,query:255,disabled:233,preview-fg:189,preview-bg:232,preview-border:105,preview-scrollbar:105,preview-label:105"
            fi ;;
        pulse-check)
            # CPU load reactive: electric green=idle, alarm red=high load
            GOLD=$(tput setaf 3); GOOD=$(tput setaf 46); BAD=$(tput setaf 196)
            local _pcl; _pcl=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | sed 's/ //g')
            if (( $(echo "${_pcl:-0} > 1.0" | bc -l 2>/dev/null || echo 0) )); then
                ACCENT=$(tput setaf 196); FG=$(tput setaf 255); BG_COLOR=52
                _FZF="fg:255,hl:196|fg+:255,bg+:124,hl+:196|info:196,prompt:196,pointer:196,spinner:196|border:196,header:196,label:196,gutter:124|marker:196,query:255,disabled:124,preview-fg:255,preview-bg:52,preview-border:196,preview-scrollbar:196,preview-label:196"
            else
                ACCENT=$(tput setaf 46); FG=$(tput setaf 255); BG_COLOR=22
                _FZF="fg:255,hl:46|fg+:255,bg+:28,hl+:46|info:46,prompt:46,pointer:46,spinner:46|border:46,header:46,label:46,gutter:28|marker:46,query:255,disabled:28,preview-fg:255,preview-bg:22,preview-border:46,preview-scrollbar:46,preview-label:46"
            fi ;;
        mint)
            # Sage Green — clean minty aesthetic
            ACCENT=$(tput setaf 108); GOLD=$(tput setaf 3); FG=$(tput setaf 108); GOOD=$(tput setaf 2); BAD=$(tput setaf 1)
            BG_COLOR=234
            _FZF="fg:108,hl:142|fg+:255,bg+:235,hl+:142|info:108,prompt:108,pointer:108,spinner:108|border:108,header:108,label:108,gutter:235|marker:108,query:255,disabled:235,preview-fg:108,preview-bg:234,preview-border:108,preview-scrollbar:108,preview-label:108" ;;
        volt)
            # Battery level reactive — 6 stages from full green to critical deep red
            GOLD=$(tput setaf 220); GOOD=$(tput setaf 2); BAD=$(tput setaf 196); FG=$(tput setaf 255)
            if [[ -d /sys/class/power_supply/BAT0 ]]; then
                local _vlt; _vlt=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 50)
                if [ "$_vlt" -gt 90 ]; then
                    ACCENT=$(tput setaf 2); BG_COLOR=22
                    _FZF="fg:255,hl:2|fg+:255,bg+:28,hl+:2|info:2,prompt:2,pointer:2,spinner:2|border:2,header:2,label:2,gutter:28|marker:2,query:255,disabled:28,preview-fg:255,preview-bg:22,preview-border:2,preview-scrollbar:2,preview-label:2"
                elif [ "$_vlt" -gt 75 ]; then
                    ACCENT=$(tput setaf 10); BG_COLOR=234
                    _FZF="fg:255,hl:10|fg+:255,bg+:235,hl+:10|info:10,prompt:10,pointer:10,spinner:10|border:10,header:10,label:10,gutter:235|marker:10,query:255,disabled:235,preview-fg:255,preview-bg:234,preview-border:10,preview-scrollbar:10,preview-label:10"
                elif [ "$_vlt" -gt 50 ]; then
                    ACCENT=$(tput setaf 220); BG_COLOR=233
                    _FZF="fg:255,hl:220|fg+:255,bg+:234,hl+:220|info:220,prompt:220,pointer:220,spinner:220|border:220,header:220,label:220,gutter:234|marker:220,query:255,disabled:234,preview-fg:255,preview-bg:233,preview-border:220,preview-scrollbar:220,preview-label:220"
                elif [ "$_vlt" -gt 30 ]; then
                    ACCENT=$(tput setaf 208); BG_COLOR=232
                    _FZF="fg:255,hl:208|fg+:255,bg+:233,hl+:208|info:208,prompt:208,pointer:208,spinner:208|border:208,header:208,label:208,gutter:233|marker:208,query:255,disabled:233,preview-fg:255,preview-bg:232,preview-border:208,preview-scrollbar:208,preview-label:208"
                elif [ "$_vlt" -gt 15 ]; then
                    ACCENT=$(tput setaf 196); BG_COLOR=52
                    _FZF="fg:255,hl:196|fg+:255,bg+:124,hl+:196|info:196,prompt:196,pointer:196,spinner:196|border:196,header:196,label:196,gutter:124|marker:196,query:255,disabled:124,preview-fg:255,preview-bg:52,preview-border:196,preview-scrollbar:196,preview-label:196"
                else
                    ACCENT=$(tput setaf 124); BG_COLOR=16
                    _FZF="fg:255,hl:124|fg+:255,bg+:52,hl+:124|info:124,prompt:124,pointer:124,spinner:124|border:124,header:124,label:124,gutter:52|marker:124,query:255,disabled:52,preview-fg:255,preview-bg:16,preview-border:124,preview-scrollbar:124,preview-label:124"
                fi
            else
                ACCENT=$(tput setaf 6); BG_COLOR=-1
                _FZF="fg:7,hl:6|fg+:15,bg+:237,hl+:6|info:6,prompt:6,pointer:6,spinner:6|border:6,header:6,label:6,gutter:237|marker:6,query:15,disabled:237,preview-fg:7,preview-bg:-1,preview-border:6,preview-scrollbar:6,preview-label:6"
            fi ;;

        # ── Custom themes — loaded from $CUSTOM_THEME_DIR ────────
        *)
            local _tf="$HOME/.config/fish/themes/${theme}.theme"
            if [[ -f "$_tf" ]]; then
                unset THEME_ACCENT THEME_GOLD THEME_FG THEME_GOOD THEME_BAD THEME_BG THEME_FZF THEME_LABEL THEME_POINTER THEME_PREVIEW_POS THEME_PREVIEW_SIZE THEME_PIPE THEME_GUI_EDITOR THEME_BAR_ICON
                # shellcheck source=/dev/null
                source "$_tf"
                ACCENT=$(tput setaf "${THEME_ACCENT:-4}")
                GOLD=$(tput setaf "${THEME_GOLD:-3}")
                FG=$(tput setaf "${THEME_FG:-7}")
                GOOD=$(tput setaf "${THEME_GOOD:-2}")
                BAD=$(tput setaf "${THEME_BAD:-1}")
                BG_COLOR="${THEME_BG:-236}"
                _FZF="${THEME_FZF:-fg:7,hl:4:bold|fg+:255:bold,bg+:8,hl+:4:bold|info:4:dim,prompt:4:bold,pointer:4:bold,spinner:4:dim|border:8:bold,header:4:bold,label:4:bold,gutter:8:dim|marker:4:bold,query:255:bold,disabled:8:dim,preview-fg:7,preview-bg:-1,preview-border:8:bold,preview-scrollbar:4,preview-label:4:bold}"
                
                [[ -n "$THEME_POINTER" ]]      && POINTER="$THEME_POINTER"
                [[ -n "$THEME_PREVIEW_POS" ]]  && PREVIEW_POSITION="$THEME_PREVIEW_POS"
                [[ -n "$THEME_PREVIEW_SIZE" ]] && PREVIEW_SIZE="$THEME_PREVIEW_SIZE"
                [[ -n "$THEME_PIPE" ]]         && PIPE="$THEME_PIPE"
                [[ -n "$THEME_GUI_EDITOR" ]]   && GUI_EDITOR="$THEME_GUI_EDITOR"
                [[ -n "$THEME_BAR_ICON" ]]     && BAR_ICON="$THEME_BAR_ICON"
            else
                CURRENT_THEME="dynamic"; apply_theme "dynamic"; return
            fi
            ;;
    esac
    
    if [[ "$USE_BG" != "1" ]]; then
        _FZF=$(printf '%s' "$_FZF" | sed 's/preview-bg:[0-9-]*/preview-bg:-1/g')
    fi

    local BG_PART; [[ "$USE_BG" == "1" ]] && BG_PART="bg:${BG_COLOR}" || BG_PART="bg:-1"
    IFS='|' read -r _s1 _s2 _s3 _s4 _s5 <<< "$_FZF"
    BLUE="$ACCENT"
    local _s4_part="" _s5_part=""
    [[ -n "$_s4" ]] && _s4_part=" --color=${_s4}"
    [[ -n "$_s5" ]] && _s5_part=" --color=${_s5}"
    
    local _ptr_part="" _mkr_part=" --marker='➲ '"
    [[ -n "$POINTER" ]] && _ptr_part=" --pointer='${POINTER}'"
    export FZF_DEFAULT_OPTS="--color=${_s1},${BG_PART} --color=${_s2} --color=${_s3}${_s4_part}${_s5_part}${_ptr_part}${_mkr_part}"
}

# Built-in theme list (name — tagline)
declare -A THEME_LABELS=(
    ["dynamic"]="Terminal Colors"
    ["feeling-lucky"]="✦ Randomize Everything"
    # Normal themes
    ["nordic-night"]="Arctic Frost"          ["dracula"]="Vampire Dark"
    ["catppuccin"]="Mocha Pastels"           ["rose-pine"]="Rose & Plum"
    ["tokyo-night"]="Tokyo Storm"            ["monokai"]="Orange & Lime"
    ["solarized"]="Solarized Dark"           ["everforest"]="Forest Green"
    ["cyberpunk"]="Neon Overload"            ["monochrome"]="Greyscale Pro"
    ["onedark"]="One Dark"                   ["ocean"]="Deep Ocean"
    ["matrix"]="Digital Rain"                ["cyber-blood"]="Crimson & Carbon"
    ["e-ink"]="Paper & Ink"                  ["vaporwave"]="80s Neon"
    ["mint"]="Sage Green"
    # Special / reactive themes
    ["chameleon"]="⚡ Time-of-Day (Warm↔Cool)"            ["chronos-ultra"]="⚡ 12-Phase Day Engine"
    ["skyline"]="⚡ Cityscape Time-of-Day"                ["volt"]="⚡ Battery Level Reactive"
    ["connection"]="⚡ Network Ping Reactive"              ["storage"]="⚡ Disk Usage Reactive"
    ["thermal"]="⚡ CPU Temperature Reactive"              ["earth-guard"]="⚡ CPU Load (Earth Tones)"
    ["pulse-check"]="⚡ CPU Load Alarm"                   ["heavy-metal"]="⚡ Downloads Folder Weight"
)

# Normal themes shown in Main Themes tab
THEME_ORDER=(dynamic nordic-night dracula catppuccin rose-pine tokyo-night monokai solarized everforest cyberpunk onedark ocean matrix cyber-blood vaporwave mint monochrome e-ink)

# Special (reactive) themes shown in Special Themes tab
SPECIAL_THEME_ORDER=(chameleon chronos-ultra skyline volt connection storage thermal earth-guard pulse-check heavy-metal)

# ── Load custom themes from $HOME/.config/fish/themes/ ───────
CUSTOM_THEME_DIR="$HOME/.config/fish/themes"
mkdir -p "$CUSTOM_THEME_DIR"
for _cf in "$CUSTOM_THEME_DIR"/*.theme; do
    [[ -f "$_cf" ]] || continue
    _cname=$(basename "$_cf" .theme)
    unset THEME_LABEL
    # shellcheck source=/dev/null
    source "$_cf"
    THEME_LABELS["$_cname"]="${THEME_LABEL:-Custom Theme}"
done
unset _cf _cname THEME_LABEL

apply_theme "$CURRENT_THEME"

# ── Theme color lookup: name:accent:gold:fg:good:bad:bg ───────────────────────
_THEME_NUMS="dynamic:4:3:7:2:1:0 nordic-night:123:110:255:34:167:234 dracula:141:228:253:84:212:235 catppuccin:117:221:254:115:210:234 rose-pine:210:222:252:116:174:233 tokyo-night:111:215:250:120:203:234 monokai:208:228:252:148:197:234 solarized:37:136:109:64:160:23 everforest:108:208:223:142:167:235 cyberpunk:198:51:255:51:196:232 monochrome:248:244:252:250:240:233 onedark:75:221:252:114:204:235 ocean:39:86:255:86:197:17 matrix:46:34:82:10:22:16 cyber-blood:160:214:255:34:196:16 e-ink:0:240:232:240:0:255 vaporwave:201:51:255:51:196:233 mint:108:3:108:2:1:234"

# ── Print a 5-block color swatch: _swatch accent gold fg good bad ─────────────
_swatch() {
    printf "\033[38;5;${1}m▌\033[38;5;${2}m▌\033[38;5;${3}m▌\033[38;5;${4}m▌\033[38;5;${5}m▌\033[0m"
}

# ── Look up color numbers for a theme into _sw_{a,g,f,gd,b} ──────────────────
_lookup_nums() {
    local _n="$1"; _sw_a=4; _sw_g=3; _sw_f=7; _sw_gd=2; _sw_b=1
    local _e
    for _e in $_THEME_NUMS; do
        IFS=':' read -r _tn _ca _cg _cf _cgd _cb _cbg <<< "$_e"
        if [[ "$_tn" == "$_n" ]]; then
            _sw_a=$_ca; _sw_g=$_cg; _sw_f=$_cf; _sw_gd=$_cgd; _sw_b=$_cb; return
        fi
    done
    if [[ -f "$CUSTOM_THEME_DIR/${_n}.theme" ]]; then
        unset THEME_ACCENT THEME_GOLD THEME_FG THEME_GOOD THEME_BAD
        # shellcheck source=/dev/null
        source "$CUSTOM_THEME_DIR/${_n}.theme" 2>/dev/null
        _sw_a=${THEME_ACCENT:-4}; _sw_g=${THEME_GOLD:-3};  _sw_f=${THEME_FG:-7}
        _sw_gd=${THEME_GOOD:-2};  _sw_b=${THEME_BAD:-1}
    fi
}

# ── Theme Picker ──────────────────────────────────────────────────────────────
show_theme_picker() {
    local TSEC_NAMES=("Main Themes" "Special Themes" "Feeling Lucky?" "Create New")
    local sec=0

    # Write the fzf preview script to a temp file once
    local _ptmp; _ptmp=$(mktemp /tmp/launcher_tprev_XXXXXX)
    trap 'rm -f "$_ptmp"' RETURN
    
    # Inject character pools straight into the script
    echo "#!/usr/bin/env bash" > "$_ptmp"
    declare -p LUCKY_PIPES LUCKY_POINTERS LUCKY_BAR_ICONS >> "$_ptmp" 2>/dev/null
    
    cat >> "$_ptmp" << 'PREV_EOF'
# Theme picker preview — run by fzf; receives selected line as $1
# Relies on exported: $_THEME_NUMS  $CUSTOM_THEME_DIR  $USE_BG

is_help=0
if [[ "$1" == "HELP" ]]; then
    is_help=1
    raw="$2"
else
    raw="$1"
fi

stripped=$(printf '%s' "$raw" | sed 's/\x1b\[[0-9;]*[mKHFJsuA-Za-z]//g; s/\x1b(B//g')
name=$(echo "$stripped" | awk '{print $1}')
[[ "$name" == "◆" || "$name" == "✦" || "$name" == "✚" ]] && name=$(echo "$stripped" | awk '{print $2}')

# ── Help intercept (triggered by Ctrl+/) ──────────────────────────────────
if [[ $is_help -eq 1 ]]; then
    if [[ "$name" == "feeling-lucky" ]]; then
        printf "\n  \033[1;38;5;214m✦  FEELING LUCKY POOLS \033[0m\n\n"
        printf "  \033[1mPipes:\033[0m\n  "
        for p in "${LUCKY_PIPES[@]}"; do printf "[\033[38;5;45m%s\033[0m] " "$p"; done
        printf "\n\n  \033[1mPointers:\033[0m\n  "
        for p in "${LUCKY_POINTERS[@]}"; do printf "[\033[38;5;45m%s\033[0m] " "$p"; done
        printf "\n\n  \033[1mBar Icons:\033[0m\n  "
        for p in "${LUCKY_BAR_ICONS[@]}"; do printf "[\033[38;5;45m%s\033[0m] " "$p"; done
        printf "\n\n"
        exit 0
    elif [[ "$name" == "create_new" ]]; then
        printf "\n  \033[1;38;5;75m+  256-COLOR REFERENCE CHART\033[0m\n\n"
        # System Colors (0–15)
        printf "  \033[1mSystem Colors \033[2m(0 - 15)\033[0m\n  "
        for i in {0..15}; do
            printf "\033[48;5;%sm  \033[0m \033[38;5;%sm%-3d\033[0m " "$i" "$i" "$i"
            if (( (i + 1) % 8 == 0 )); then printf "\n  "; fi
        done
        printf "\n"
        # 216-Color Cube (16–231)
        printf "\n  \033[1m216-Color Cube \033[2m(16 - 231)\033[0m\n"
        for row in {0..35}; do
            printf "  "
            for col in {0..5}; do
                i=$(( 16 + row * 6 + col ))
                printf "\033[48;5;%sm  \033[0m \033[38;5;%sm%-3d\033[0m " "$i" "$i" "$i"
            done
            printf "\n"
        done
        # Grayscale Ramp (232–255)
        printf "\n  \033[1mGreyscale Ramp \033[2m(232 - 255)\033[0m\n  "
        for i in {232..255}; do
            printf "\033[48;5;%sm  \033[0m \033[38;5;%sm%-3d\033[0m " "$i" "$i" "$i"
            if (( (i - 232 + 1) % 8 == 0 )); then printf "\n  "; fi
        done
        printf "\n"
        exit 0
    else
        printf "\n  \033[2mNo custom elements for this entry.\033[0m\n"
        exit 0
    fi
fi

w=${FZF_PREVIEW_COLUMNS:-46}
bar=$(printf '%*s' "$((w-6))" '' | tr ' ' '─')
inner=$((w-8))
rst="\033[0m"; bld="\033[1m"; dim="\033[2m"

# ── Helper: print a 2-col row (label, swatch col#) ────────────────────────
_crow() {
    local lbl="$1" col="$2" desc="$3"
    local sc="\033[38;5;${col}m"
    printf "    ${sc}████${rst}  ${bld}%-10s${rst}  ${dim}col %-3d  %s${rst}\n" "$lbl" "$col" "$desc"
}

# ── Special entries ────────────────────────────────────────────────────────
case "$name" in
    feeling-lucky)
        ac="\033[38;5;214m"
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "✦  FEELING LUCKY?"
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "Randomize Everything"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Each roll randomizes${rst}\n\n"
        for item in \
            "Colors (accent gold text good bad)" \
            "Background shade" \
            "Preview position + size" \
            "Column separator (pipe)" \
            "Cursor pointer" \
            "Progress bar fill icon"
        do
            printf "    ${ac}◦${rst} %s\n" "$item"
        done
        printf "\n"
        printf "  ${dim}Press Ctrl+/ to see loaded characters${rst}\n\n"
        printf "  ${dim}Each roll saves a unique .theme${rst}\n"
        printf "  ${dim}file — re-apply it anytime.${rst}\n"
        exit 0 ;;

    # ── Special / Reactive theme previews ─────────────────────────────────
    chameleon)
        ac="\033[38;5;172m"
        H=$(date +%H)
        if [ "$H" -ge 18 ] || [ "$H" -lt 6 ]; then
            ac="\033[38;5;172m"; phase="Night Mode  (18:00 – 05:59)"
            col1=172; col2=178; mood="Warm amber  —  sunset tones"
        else
            ac="\033[38;5;32m"; phase="Day Mode    (06:00 – 17:59)"
            col1=32; col2=121; mood="Sky blue  —  crisp daylight"
        fi
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "CHAMELEON"
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "Time-of-Day Adaptive Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} Reads the current hour at launch\n"
        printf "    ${ac}◦${rst} Switches between warm night palette\n"
        printf "      and cool daylight palette automatically\n"
        printf "    ${ac}◦${rst} Re-applies fresh colors on every restart\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current phase  —  %s${rst}\n\n" "$(date +%H:%M)"
        printf "    \033[38;5;${col1}m████████\033[0m  %s\n" "$phase"
        printf "    \033[38;5;${col2}m████████\033[0m  %s\n" "$mood"
        exit 0 ;;

    chronos-ultra)
        H=$(date +%H)
        case "$H" in
            00|01) ac="\033[38;5;57m";  ph="00–01  Midnight Abyss"      ;;
            02|03) ac="\033[38;5;239m"; ph="02–03  Deep Night Graphite"  ;;
            04|05) ac="\033[38;5;147m"; ph="04–05  First Light Lavender" ;;
            06|07) ac="\033[38;5;209m"; ph="06–07  Sunrise Peach/Gold"   ;;
            08|09) ac="\033[38;5;121m"; ph="08–09  Early Morning Mint"   ;;
            10|11) ac="\033[38;5;117m"; ph="10–11  Late Morning Sky Blue";;
            12|13) ac="\033[38;5;33m";  ph="12–13  High Noon Solarized"  ;;
            14|15) ac="\033[38;5;222m"; ph="14–15  Afternoon Desert"     ;;
            16|17) ac="\033[38;5;202m"; ph="16–17  Golden Hour Burnt"    ;;
            18|19) ac="\033[38;5;161m"; ph="18–19  Sunset Magenta/Wine"  ;;
            20|21) ac="\033[38;5;63m";  ph="20–21  Twilight Indigo"      ;;
            22|23) ac="\033[38;5;243m"; ph="22–23  Late Night Charcoal"  ;;
        esac
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "CHRONOS ULTRA    "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "12-Phase Time-of-Day Engine"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} 12 unique color phases — one per 2 hrs\n"
        printf "    ${ac}◦${rst} Each phase has its own accent, bg & mood\n"
        printf "    ${ac}◦${rst} Automatically selects phase at launch time\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current phase  —  %s${rst}\n\n" "$(date +%H:%M)"
        printf "    ${ac}◈${rst}  %s\n" "$ph"
        printf "\n"
        printf "  ${dim}  00 Abyss ▸ 02 Graphite ▸ 04 Lavender${rst}\n"
        printf "  ${dim}  06 Peach  ▸ 08 Mint     ▸ 10 Sky${rst}\n"
        printf "  ${dim}  12 Noon   ▸ 14 Desert   ▸ 16 Gold${rst}\n"
        printf "  ${dim}  18 Sunset ▸ 20 Indigo   ▸ 22 Charcoal${rst}\n"
        exit 0 ;;

    skyline)
        H=$(date +%H)
        if [ "$H" -lt 10 ]; then
            ac="\033[38;5;214m"; ph="Morning (00–09)  —  Sunrise Gold"
        elif [ "$H" -lt 17 ]; then
            ac="\033[38;5;75m";  ph="Afternoon (10–16)  —  Sky Blue"
        else
            ac="\033[38;5;105m"; ph="Night (17–23)  —  Dusk Purple"
        fi
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "SKYLINE      "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "Cityscape Time-of-Day Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} 3-phase palette based on local time\n"
        printf "    ${ac}◦${rst} Morning: warm gold (sunrise over skyline)\n"
        printf "    ${ac}◦${rst} Afternoon: bright sky blue (clear midday)\n"
        printf "    ${ac}◦${rst} Night: deep purple (city lights & dusk)\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current phase  —  %s${rst}\n\n" "$(date +%H:%M)"
        printf "    ${ac}◈${rst}  %s\n" "$ph"
        exit 0 ;;

    volt)
        ac="\033[38;5;46m"
        if [[ -d /sys/class/power_supply/BAT0 ]]; then
            pct=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo "?")
            stat=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
        else
            pct="N/A (no battery)"; stat="AC Only"
        fi
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "VOLT    "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "Battery Level Reactive Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} Reads /sys/class/power_supply/BAT0\n"
        printf "    ${ac}◦${rst} Selects 1 of 6 color stages by charge %%\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Color stages${rst}\n\n"
        printf "    \033[38;5;2m████\033[0m  >90%%   Full charge — deep green\n"
        printf "    \033[38;5;10m████\033[0m  >75%%   Good      — light green\n"
        printf "    \033[38;5;220m████\033[0m  >50%%   Half      — yellow\n"
        printf "    \033[38;5;208m████\033[0m  >30%%   Low       — orange\n"
        printf "    \033[38;5;196m████\033[0m  >15%%   Warning   — red\n"
        printf "    \033[38;5;124m████\033[0m  ≤15%%   Critical  — deep red\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current battery${rst}\n\n"
        printf "    Charge: %s%%    Status: %s\n" "$pct" "$stat"
        exit 0 ;;

    connection)
        ac="\033[38;5;2m"
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "CONNECTION       "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "Network Ping Reactive Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} Pings 8.8.8.8 at launch\n"
        printf "    ${ac}◦${rst} Measures round-trip latency\n"
        printf "    ${ac}◦${rst} Colors indicate connection quality\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Color states${rst}\n\n"
        printf "    \033[38;5;2m████\033[0m  <50ms   Fast — green\n"
        printf "    \033[38;5;3m████\033[0m  ≥50ms   Slow — yellow\n"
        printf "    \033[38;5;1m████\033[0m  No reply  Offline — red\n"
        exit 0 ;;

    storage)
        usg=$(df "$HOME" 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
        ac="\033[38;5;34m"
        [ "${usg:-0}" -gt 70 ] && ac="\033[38;5;214m"
        [ "${usg:-0}" -gt 90 ] && ac="\033[38;5;196m"
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "STORAGE      "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "Disk Usage Reactive Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} Reads df usage of your \$HOME filesystem\n"
        printf "    ${ac}◦${rst} Switches palette based on usage percent\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Color thresholds${rst}\n\n"
        printf "    \033[38;5;34m████\033[0m  <70%%   Healthy  — green\n"
        printf "    \033[38;5;214m████\033[0m  70–89%%  Warning  — amber\n"
        printf "    \033[38;5;196m████\033[0m  ≥90%%   Critical — red (dark bg)\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current disk usage${rst}\n\n"
        printf "    \$HOME filesystem: %s%%\n" "${usg:-?}"
        exit 0 ;;

    thermal)
        tmp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null || echo 0)
        tmp=$((tmp / 1000))
        [ "$tmp" -gt 60 ] && ac="\033[38;5;1m" || ac="\033[38;5;81m"
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "THERMAL     "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "CPU Temperature Reactive Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} Reads /sys/class/thermal/thermal_zone0\n"
        printf "    ${ac}◦${rst} Switches color based on CPU temp\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Color states${rst}\n\n"
        printf "    \033[38;5;81m████\033[0m  ≤60°C  Cool — cyan/blue\n"
        printf "    \033[38;5;1m████\033[0m  >60°C  Hot  — red\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current CPU temp${rst}\n\n"
        printf "    %s°C\n" "$tmp"
        exit 0 ;;

    earth-guard)
        load=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | sed 's/ //g' | cut -d. -f1)
        [ "${load:-0}" -gt 1 ] && ac="\033[38;5;130m" || ac="\033[38;5;108m"
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "EARTH GUARD    "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "CPU Load (Earth Tones) Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} Reads system load average\n"
        printf "    ${ac}◦${rst} Idle = moss green (restful earth)\n"
        printf "    ${ac}◦${rst} Busy = earthy brown (warm & heavy)\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Color states${rst}\n\n"
        printf "    \033[38;5;108m████\033[0m  load ≤1   Idle  — moss green\n"
        printf "    \033[38;5;130m████\033[0m  load >1   Busy  — earthy brown\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current load avg${rst}\n\n"
        printf "    %s\n" "$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')"
        exit 0 ;;

    pulse-check)
        load=$(uptime | awk -F'load average:' '{print $2}' | cut -d, -f1 | sed 's/ //g')
        hilo=$(echo "${load:-0} > 1.0" | bc -l 2>/dev/null || echo 0)
        [ "$hilo" -eq 1 ] && ac="\033[38;5;196m" || ac="\033[38;5;46m"
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "PULSE CHECK    "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "CPU Load Alarm Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} Monitors the 1-minute load average\n"
        printf "    ${ac}◦${rst} Below 1.0: calm electric green\n"
        printf "    ${ac}◦${rst} Above 1.0: alarm red with dark bg\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Color states${rst}\n\n"
        printf "    \033[38;5;46m████\033[0m  load ≤1.0   Calm  — green\n"
        printf "    \033[38;5;196m████\033[0m  load >1.0   Alert — red\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current load avg${rst}\n\n"
        printf "    %s\n" "$(uptime | awk -F'load average:' '{print $2}' | sed 's/^ *//')"
        exit 0 ;;

    heavy-metal)
        sz=$(du -s "$HOME/Downloads" 2>/dev/null | cut -f1)
        [ "${sz:-0}" -gt 5000000 ] && ac="\033[38;5;160m" || ac="\033[38;5;248m"
        sz_gb=$(echo "scale=1; ${sz:-0}/1024/1024" | bc 2>/dev/null || echo "?")
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "HEAVY METAL     "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "Downloads Folder Weight Theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}How it works${rst}\n\n"
        printf "    ${ac}◦${rst} Measures size of \$HOME/Downloads\n"
        printf "    ${ac}◦${rst} Light folder = silver/gray palette\n"
        printf "    ${ac}◦${rst} Heavy folder = deep red/dark palette\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Color states${rst}\n\n"
        printf "    \033[38;5;248m████\033[0m  <5 GB    Light  — silver gray\n"
        printf "    \033[38;5;160m████\033[0m  ≥5 GB    Heavy  — deep red\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Current Downloads size${rst}\n\n"
        printf "    %s GB\n" "$sz_gb"
        exit 0 ;;

    vaporwave)
        ac="\033[38;5;201m"
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "VAPORWAVE           "
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "80s Neon Aesthetic Theme         "
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Design${rst}\n\n"
        printf "    ${ac}◦${rst} Hot pink (201) + electric cyan (51)\n"
        printf "    ${ac}◦${rst} Deep charcoal background (233)\n"
        printf "    ${ac}◦${rst} Retro 80s aesthetic — always on\n"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Palette${rst}\n\n"
        printf "    \033[38;5;201m████\033[0m  Accent  — hot pink 201\n"
        printf "    \033[38;5;51m████\033[0m  Gold    — electric cyan 51\n"
        printf "    \033[38;5;255m████\033[0m  Text    — bright white 255\n"
        exit 0 ;;

    create_new)
        ac="\033[38;5;75m"
        printf "\n"
        printf "  ${ac}╭%s╮${rst}\n" "$bar"
        printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "✚  CREATE NEW THEME"
        printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "Build a fully custom theme"
        printf "  ${ac}╰%s╯${rst}\n" "$bar"
        printf "\n"
        printf "  ${ac}▸${rst} ${bld}Configure${rst}\n\n"
        for item in \
            "5-color palette (256-color ints)" \
            "FZF colors  (Quick / Custom / String)" \
            "Pipe & pointer characters" \
            "Progress bar fill icon" \
            "Preview position + size" \
            "GUI editor command"
        do
            printf "    ${ac}◦${rst} %s\n" "$item"
        done
        printf "\n"
        printf "  ${dim}Press Ctrl+/ to show color palette chart${rst}\n\n"
        printf "  ${dim}Saved to ~/.config/fish/themes/${rst}\n"
        exit 0 ;;
    "(no"|"") exit 0 ;;
esac

# ── Resolve colors from lookup or .theme file ──────────────────────────────
a=4; g=3; fg_n=7; gd=2; bd=1; bg_n=236
fzf_str=""
pipe_ch=" │ "; ptr_ch=""; bar_ch="#"; prev_pos="bottom"; prev_sz="70%"; tlabel=""
found=0
for entry in $_THEME_NUMS; do
    IFS=':' read -r tn ca cg cfn cgd cb cbgn <<< "$entry"
    if [[ "$tn" == "$name" ]]; then
        a=$ca; g=$cg; fg_n=$cfn; gd=$cgd; bd=$cb; bg_n=$cbgn; found=1; break
    fi
done
if [[ $found -eq 0 && -f "$CUSTOM_THEME_DIR/${name}.theme" ]]; then
    unset THEME_ACCENT THEME_GOLD THEME_FG THEME_GOOD THEME_BAD THEME_BG \
          THEME_LABEL THEME_PIPE THEME_POINTER THEME_BAR_ICON \
          THEME_PREVIEW_POS THEME_PREVIEW_SIZE THEME_FZF
    source "$CUSTOM_THEME_DIR/${name}.theme" 2>/dev/null
    a=${THEME_ACCENT:-4};  g=${THEME_GOLD:-3};   fg_n=${THEME_FG:-7}
    gd=${THEME_GOOD:-2};   bd=${THEME_BAD:-1};   bg_n=${THEME_BG:-236}
    fzf_str="${THEME_FZF:-}"
    [[ -n "$THEME_PIPE" ]]         && pipe_ch="$THEME_PIPE"
    [[ -n "$THEME_POINTER" ]]      && ptr_ch="$THEME_POINTER"
    [[ -n "$THEME_BAR_ICON" ]]     && bar_ch="$THEME_BAR_ICON"
    [[ -n "$THEME_PREVIEW_POS" ]]  && prev_pos="$THEME_PREVIEW_POS"
    [[ -n "$THEME_PREVIEW_SIZE" ]] && prev_sz="$THEME_PREVIEW_SIZE"
    [[ -n "$THEME_LABEL" ]]        && tlabel="$THEME_LABEL"
fi

# ── Derive FZF interface colors ────────────────────────────────────────────
# Helper: extract value from fzf color string "key:N" pairs
_fzf_val() {
    local key="$1" str="$2" val
    val=$(printf '%s' "$str" | tr '|,' '\n' | grep -m1 "^${key}:" | cut -d: -f2)
    printf '%s' "$val"
}
_abgp=$(( bg_n + 2 )); [[ $_abgp -gt 254 ]] && _abgp=238

if [[ -n "$fzf_str" ]]; then
    hl_n=$(_fzf_val "hl"   "$fzf_str");   [[ -z "$hl_n"   ]] && hl_n=$a
    fgp_n=$(_fzf_val "fg+" "$fzf_str");   [[ -z "$fgp_n"  ]] && fgp_n=255
    bgp_n=$(_fzf_val "bg+" "$fzf_str");   [[ -z "$bgp_n"  ]] && bgp_n=$_abgp
    hlp_n=$(_fzf_val "hl+" "$fzf_str");   [[ -z "$hlp_n"  ]] && hlp_n=$a
    info_n=$(_fzf_val "info" "$fzf_str"); [[ -z "$info_n" ]] && info_n=$gd
    prompt_n=$(_fzf_val "prompt" "$fzf_str"); [[ -z "$prompt_n" ]] && prompt_n=$a
    ptr_col=$(_fzf_val "pointer" "$fzf_str"); [[ -z "$ptr_col" ]] && ptr_col=$a
    mkr_n=$(_fzf_val "marker"  "$fzf_str"); [[ -z "$mkr_n"  ]] && mkr_n=$a
    spin_n=$(_fzf_val "spinner" "$fzf_str"); [[ -z "$spin_n" ]] && spin_n=$gd
    bdr_n=$(_fzf_val "border"  "$fzf_str"); [[ -z "$bdr_n"  ]] && bdr_n=$_abgp
    hdr_n=$(_fzf_val "header"  "$fzf_str"); [[ -z "$hdr_n"  ]] && hdr_n=$a
    lbl_n=$(_fzf_val "label"   "$fzf_str"); [[ -z "$lbl_n"  ]] && lbl_n=$a
    gut_n=$(_fzf_val "gutter"  "$fzf_str"); [[ -z "$gut_n"  ]] && gut_n=$_abgp
    qry_n=$(_fzf_val "query"   "$fzf_str"); [[ -z "$qry_n"  ]] && qry_n=255
    dis_n=$(_fzf_val "disabled" "$fzf_str"); [[ -z "$dis_n" ]] && dis_n=$_abgp
    pvfg_n=$(_fzf_val "preview-fg" "$fzf_str"); [[ -z "$pvfg_n" ]] && pvfg_n=$fg_n
    pvbg_n=$(_fzf_val "preview-bg" "$fzf_str"); [[ -z "$pvbg_n" ]] && pvbg_n=$bg_n
    pvbdr_n=$(_fzf_val "preview-border" "$fzf_str"); [[ -z "$pvbdr_n" ]] && pvbdr_n=$_abgp
    pvsc_n=$(_fzf_val "preview-scrollbar" "$fzf_str"); [[ -z "$pvsc_n" ]] && pvsc_n=$a
    pvlbl_n=$(_fzf_val "preview-label" "$fzf_str"); [[ -z "$pvlbl_n" ]] && pvlbl_n=$a
else
    # Derive from palette (follows standard theme formula)
    hl_n=$a; fgp_n=255; bgp_n=$_abgp; hlp_n=$a
    info_n=$gd; prompt_n=$a; ptr_col=$a; mkr_n=$a; spin_n=$gd
    bdr_n=$_abgp; hdr_n=$a; lbl_n=$a; gut_n=$_abgp
    qry_n=255; dis_n=$_abgp
    pvfg_n=$fg_n; pvbg_n=$bg_n; pvbdr_n=$_abgp; pvsc_n=$a; pvlbl_n=$a
fi

# ── ANSI color codes ───────────────────────────────────────────────────────
ac="\033[38;5;${a}m"
gc="\033[38;5;${g}m"
fc="\033[38;5;${fg_n}m"
dc="\033[38;5;${gd}m"
bc="\033[38;5;${bd}m"
if [[ "${USE_BG:-1}" == "1" ]]; then
    bgc="\033[48;5;${bg_n}m"
    bg_label="bg: $bg_n"
else
    bgc="\033[2m"
    bg_label="bg: terminal default (bg off)"
fi

# ── Per-theme subtitle & vibe (main themes) ───────────────────────────────
_subtitle="${tlabel}"
_vibe=""
case "$name" in
    dynamic)
        _subtitle="Your terminal's own configured palette"
        _vibe="Inherits colors directly from your terminal emulator|Adapts automatically to any terminal theme you have set|Perfect for terminals with rich or custom colorschemes" ;;
    nordic-night)
        _subtitle="Arctic ice blues on deep charcoal"
        _vibe="Pale cyan & ice blues inspired by nordic winter nights|High contrast — clean and readable for long sessions|Strong borders & vivid accent for a focused workflow" ;;
    dracula)
        _subtitle="Vivid lilac & hot pink on twilight charcoal"
        _vibe="The classic Dracula palette — sharp and unmistakable|High contrast without being harsh on the eyes|Vivid pink pointer & lilac highlights pop against the dark" ;;
    catppuccin)
        _subtitle="Soft lavender-blue pastels on warm mocha-brown"
        _vibe="Soothing and gentle — designed for eye comfort|Inspired by the Catppuccin Mocha palette|Muted enough for hours of use, distinct enough to navigate" ;;
    rose-pine)
        _subtitle="Dusty rose accents on a deep plum-dark background"
        _vibe="Warm, muted, and romantic — the Rosé Pine aesthetic|Rose gold highlights on a rich plum/mauve background|Refined and understated — beautiful for long sessions" ;;
    tokyo-night)
        _subtitle="Electric indigo & warm orange on deep navy"
        _vibe="Inspired by looking out over Tokyo on a rainy night|Deep navy background with electric blue-indigo highlights|Warm orange gold creates dramatic contrast" ;;
    monokai)
        _subtitle="Bold orange with lime green on warm dark grey"
        _vibe="The classic Monokai palette from Sublime Text|Energetic and vibrant — unmistakably Monokai|Orange prompt + lime good-state = clear visual language" ;;
    solarized)
        _subtitle="Teal-dark base with cyan & amber highlights"
        _vibe="The iconic Solarized Dark by Ethan Schoonover|Scientifically tuned — reduces eye strain in dark conditions|Amber gold pointer & teal borders feel calm and deliberate" ;;
    everforest)
        _subtitle="Sage green & amber on a comfortable forest dark"
        _vibe="Inspired by the Everforest theme by sainnhe|Earthy, warm, and easy on the eyes for long sessions|Forest green accents with soft amber gold — never fatiguing" ;;
    cyberpunk)
        _subtitle="Aggressive hot pink & electric cyan on near-black"
        _vibe="Maximum neon saturation — pure cyberpunk aesthetic|Hot pink borders, headers, and prompts — nothing subtle here|High energy — stands out the moment you open the launcher" ;;
    monochrome)
        _subtitle="Crisp whites through mid-greys to dark slate"
        _vibe="Pure achromatic — no hue, no distraction|Focus on content; the interface disappears into the background|Crisp and professional — ideal for minimal setups" ;;
    onedark)
        _subtitle="Cool steel blue & warm gold on near-black"
        _vibe="The Atom One Dark aesthetic — clean and balanced|Cool blue highlights pair naturally with warm gold secondary|A timeless dark theme that suits any workflow" ;;
    ocean)
        _subtitle="Electric cyan & seafoam green on abyssal navy"
        _vibe="A vivid deep-sea palette — luminous and bold|Pure blues and greens — no warm tones anywhere|Seafoam markers & cyan highlights feel alive and electric" ;;
    matrix)
        _subtitle="Phosphor green on pure black — the iconic look               "
        _vibe="Inspired by the cascading code rain in The Matrix|Single-hue green with varying brightness for depth|Maximum retro terminal energy — pure green on black" ;;
    cyber-blood)
        _subtitle="Deep crimson & amber on carbon black"
        _vibe="Dark and dangerous — monochromatic red with gold accent|Intense and dramatic — built for late-night sessions|Crimson borders & headers create a brooding atmosphere" ;;
    e-ink)
        _subtitle="Near-black text on bright paper white"
        _vibe="Inspired by e-ink displays and print aesthetics|Maximum contrast — no in-between greys|Great for bright environments or a document-style mindset" ;;
    vaporwave)
        _subtitle="Hot pink & electric cyan on deep charcoal"
        _vibe="Retro 80s synthwave aesthetic — always-on neon|Hot pink and cyan are a bold, complementary pairing|Nostalgia-core with a modern terminal twist" ;;
    mint)
        _subtitle="Soft sage green on deep charcoal"
        _vibe="Calm and cool — a clean minty green aesthetic|Sage accent pairs well with a dark neutral background|Restful on the eyes — great for long focused sessions" ;;
esac

# ── Name card ─────────────────────────────────────────────────────────────
printf "\n"
printf "  ${ac}╭%s╮${rst}\n" "$bar"
printf "  ${ac}│${rst}  ${bld}${ac}%-*s${rst}  ${ac}│${rst}\n" "$inner" "${name^^}"
[[ -n "$_subtitle" ]] && \
    printf "  ${ac}│${rst}  ${dim}%-*s${rst}  ${ac}│${rst}\n" "$inner" "$_subtitle"
printf "  ${ac}╰%s╯${rst}\n" "$bar"
printf "\n"

# ── Vibe section (main themes) ─────────────────────────────────────────────
if [[ -n "$_vibe" ]]; then
    printf "  ${ac}▸${rst} ${bld}Aesthetic${rst}\n\n"
    IFS='|' read -ra _vlines <<< "$_vibe"
    for _vl in "${_vlines[@]}"; do
        printf "    ${ac}◦${rst} %s\n" "$_vl"
    done
    printf "\n"
fi

# ── Palette ────────────────────────────────────────────────────────────────
printf "  ${ac}▸${rst} ${bld}Palette${rst}  ${dim}%s${rst}\n\n" "$(printf '%*s' "$((w-18))" '' | tr ' ' '─')"
_crow "Accent"    "$a"    "headers · highlights · prompt"
_crow "Gold"      "$g"    "favorites ★ · update icons"
_crow "Text"      "$fg_n" "main list / body text"
_crow "Good"      "$gd"   "up-to-date · success"
_crow "Bad"       "$bd"   "errors · alert states"
printf "\n"

# ── Background swatch ─────────────────────────────────────────────────────
printf "  ${ac}▸${rst} ${bld}Background${rst}  ${dim}%s${rst}\n\n" "$(printf '%*s' "$((w-22))" '' | tr ' ' '─')"
printf "    ${bgc}  %-*s  ${rst}\n" "$((w-12))" "$bg_label"
printf "\n"

# ── Custom settings (if non-default) ──────────────────────────────────────
_hs=0
[[ "$pipe_ch" != " │ " || -n "$ptr_ch" || "$bar_ch" != "#" || \
   "$prev_pos" != "bottom" || "$prev_sz" != "70%" ]] && _hs=1
if [[ $_hs -eq 1 ]]; then
    printf "  ${ac}▸${rst} ${bld}Settings${rst}  ${dim}%s${rst}\n\n" "$(printf '%*s' "$((w-19))" '' | tr ' ' '─')"
    printf "    ${dim}Pipe    ${rst}  ${ac}%s${rst}\n" "$pipe_ch"
    [[ -n "$ptr_ch" ]] && printf "    ${dim}Cursor  ${rst}  ${ac}%s${rst}\n" "$ptr_ch"
    printf "    ${dim}Bar     ${rst}  ${ac}%s${rst}\n" "$bar_ch"
    printf "    ${dim}Preview ${rst}  ${ac}%-8s${rst}  ${dim}%s${rst}\n" "$prev_pos" "$prev_sz"
fi
PREV_EOF

    # Export lookup table + dir + bg state so the fzf preview subprocess can access them
    export _THEME_NUMS CUSTOM_THEME_DIR USE_BG SPECIAL_THEME_ORDER

    # ─────────────────────────────────────────────────────────────────────────
    while true; do
        # ── Tab bar header ───────────
        local full_h="" _i
        for _i in "${!TSEC_NAMES[@]}"; do
            if [[ $_i -eq $sec ]]; then
                full_h+="${BOLD}${FG}[ ${TSEC_NAMES[$_i]} ]${RESET} "
            else
                full_h+="${DIM}  ${TSEC_NAMES[$_i]}  ${RESET} "
            fi
        done

        # Active theme swatch + Info Panel
        _lookup_nums "$CURRENT_THEME"
        local _cur_sw; _cur_sw=$(_swatch "$_sw_a" "$_sw_g" "$_sw_f" "$_sw_gd" "$_sw_b")
        local _cur_label="${THEME_LABELS[$CURRENT_THEME]:-}"
        local _hdr2="${BOLD}${ACCENT}  ◈ ${CURRENT_THEME}${RESET}  ${_cur_sw}${DIM}  ${_cur_label}${RESET}"
        local _hdr3="${DIM}  ────────────────────────────────────────────────────────────────${RESET}"
        local _theme_legend="${DIM}  [Enter] Apply  •  [Ctrl+E] Edit  •  [Ctrl+F] Fork  •  [Ctrl+D] Delete  •  [←/→] Tabs  •  [Ctrl+/] Help ${RESET}"

        # ── Build list ───────────────────────────────────────────────────────
        local list=""
        local formatted_line=""
        
        case $sec in
            0)  # Main Themes
                for name in "${THEME_ORDER[@]}"; do
                    [[ "$name" == "feeling-lucky" ]] && continue
                    local marker="  "
                    [[ "$name" == "$CURRENT_THEME" ]] && marker="${ACCENT}${BOLD}◆${RESET} "
                    _lookup_nums "$name"
                    local sw; sw=$(_swatch "$_sw_a" "$_sw_g" "$_sw_f" "$_sw_gd" "$_sw_b")
                    printf -v formatted_line "%s${BOLD}%-18s${RESET}  %s   ${DIM}%s${RESET}\n" "$marker" "$name" "$sw" "${THEME_LABELS[$name]}"
                    list+="$formatted_line"
                done
                ;;
            1)  # Special Themes
                printf -v formatted_line "${DIM}  ─ Reactive & Sensor-Aware ──────────────────────────────────────${RESET}\n"
                list+="$formatted_line"
                for name in "${SPECIAL_THEME_ORDER[@]}"; do
                    local marker="  "
                    [[ "$name" == "$CURRENT_THEME" ]] && marker="${ACCENT}${BOLD}◆${RESET} "
                    # Pick a representative accent for swatch from the theme
                    local _spc_a _spc_g _spc_f _spc_gd _spc_b
                    case "$name" in
                        chameleon)    _spc_a=172; _spc_g=220; _spc_f=250; _spc_gd=2;   _spc_b=1  ;;
                        chronos-ultra)_spc_a=209; _spc_g=220; _spc_f=250; _spc_gd=2;   _spc_b=1  ;;
                        skyline)      _spc_a=214; _spc_g=75;  _spc_f=255; _spc_gd=2;   _spc_b=1  ;;
                        volt)         _spc_a=46;  _spc_g=220; _spc_f=255; _spc_gd=10;  _spc_b=196;;
                        connection)   _spc_a=2;   _spc_g=3;   _spc_f=7;   _spc_gd=2;   _spc_b=1  ;;
                        storage)      _spc_a=34;  _spc_g=214; _spc_f=7;   _spc_gd=34;  _spc_b=196;;
                        thermal)      _spc_a=81;  _spc_g=3;   _spc_f=7;   _spc_gd=2;   _spc_b=1  ;;
                        earth-guard)  _spc_a=108; _spc_g=178; _spc_f=223; _spc_gd=2;   _spc_b=1  ;;
                        pulse-check)  _spc_a=46;  _spc_g=3;   _spc_f=255; _spc_gd=46;  _spc_b=196;;
                        heavy-metal)  _spc_a=248; _spc_g=3;   _spc_f=250; _spc_gd=2;   _spc_b=160;;
                        *)            _spc_a=4;   _spc_g=3;   _spc_f=7;   _spc_gd=2;   _spc_b=1  ;;
                    esac
                    local sw; sw=$(_swatch "$_spc_a" "$_spc_g" "$_spc_f" "$_spc_gd" "$_spc_b")
                    printf -v formatted_line "%s${BOLD}%-18s${RESET}  %s   ${DIM}%s${RESET}\n" "$marker" "$name" "$sw" "${THEME_LABELS[$name]}"
                    list+="$formatted_line"
                done
                ;;
            2)  # Feeling Lucky?
                # ── Action entry ─────────────────────────────────────────────
                local fl_marker="  "
                [[ "feeling-lucky" == "$CURRENT_THEME" ]] && fl_marker="${YELLOW}${BOLD}◆${RESET} "
                local dice_sw
                dice_sw=$(printf "\033[38;5;196m▌\033[38;5;220m▌\033[38;5;46m▌\033[38;5;51m▌\033[38;5;201m▌\033[0m")
                printf -v formatted_line "%s${BOLD}${YELLOW}%-18s${RESET}  ${DIM}· · · · · · · ·${RESET}  %s   ${DIM}Roll New Random Theme${RESET}\n" \
                    "$fl_marker" "feeling-lucky" "$dice_sw"
                list+="$formatted_line"
                
                # ── Saved Rolls divider ──────────────────────────────────────
                printf -v formatted_line "${DIM}  ─ Saved Rolls ──────────────────────────────────────────────────${RESET}\n"
                list+="$formatted_line"
                
                local _lhas=0
                for _cf in "$CUSTOM_THEME_DIR"/lucky-*.theme; do
                    [[ -f "$_cf" ]] || continue
                    local _cn; _cn=$(basename "$_cf" .theme)
                    local marker="  "
                    [[ "$_cn" == "$CURRENT_THEME" ]] && marker="${ACCENT}${BOLD}◆${RESET} "
                    _lookup_nums "$_cn"
                    local sw; sw=$(_swatch "$_sw_a" "$_sw_g" "$_sw_f" "$_sw_gd" "$_sw_b")
                    printf -v formatted_line "%s${BOLD}%-22s${RESET}  %s   ${DIM}%s${RESET}\n" "$marker" "$_cn" "$sw" "${THEME_LABELS[$_cn]:-Lucky Theme}"
                    list+="$formatted_line"
                    _lhas=1
                done
                unset _cf _cn
                [[ $_lhas -eq 0 ]] && list+="${DIM}     (no lucky themes rolled yet — press Enter on the entry above)${RESET}"$'\n'
                ;;
            3)  # Create New
                # ── Action entry ─────────────────────────────────────────────
                printf -v formatted_line "${ACCENT}${BOLD}✚${RESET} ${BOLD}${ACCENT}%-18s${RESET}  ${DIM}· · · · · · · ·${RESET}     ${DIM}🛠  Build New Custom Theme${RESET}\n" "create_new"
                list+="$formatted_line"
                
                # ── Custom Themes divider ────────────────────────────────────
                printf -v formatted_line "${DIM}  ─ Custom Themes ────────────────────────────────────────────────${RESET}\n"
                list+="$formatted_line"
                
                local _has=0
                for _cf in "$CUSTOM_THEME_DIR"/*.theme; do
                    [[ -f "$_cf" ]] || continue
                    local _cn; _cn=$(basename "$_cf" .theme)
                    local _inb=0
                    for _bt in "${THEME_ORDER[@]}" "${SPECIAL_THEME_ORDER[@]}"; do [[ "$_bt" == "$_cn" ]] && _inb=1 && break; done
                    [[ $_inb -eq 1 ]] && continue
                    [[ "$_cn" == lucky-* ]] && continue
                    local marker="  "
                    [[ "$_cn" == "$CURRENT_THEME" ]] && marker="${ACCENT}${BOLD}◆${RESET} "
                    _lookup_nums "$_cn"
                    local sw; sw=$(_swatch "$_sw_a" "$_sw_g" "$_sw_f" "$_sw_gd" "$_sw_b")
                    printf -v formatted_line "%s${BOLD}%-22s${RESET}  %s   ${DIM}%s${RESET}\n" "$marker" "$_cn" "$sw" "${THEME_LABELS[$_cn]:-Custom}"
                    list+="$formatted_line"
                    _has=1
                done
                unset _cf _cn _bt _inb
                [[ $_has -eq 0 ]] && list+="${DIM}     (no custom themes yet — press Enter on the entry above to create one)${RESET}"$'\n'
                ;;
        esac

        local res
        res=$(printf '%s' "$list" | sed '/^$/d' | fzf --ansi \
            --height=90% --reverse --border=rounded \
            --border-label-pos=bottom --border-label="$_theme_legend" \
            --header="${full_h}"$'\n'"${DIM}  ────────────────────────────────────────────────────────────────${RESET}"$'\n'"${_hdr2}"$'\n'"${_hdr3}" \
            --prompt="󰔎 Search: " --no-multi \
            --preview="bash '$_ptmp' {}" \
            --preview-window="right:50%:wrap" \
            --bind "right:become(echo __NEXT__)" \
            --bind "left:become(echo __PREV__)" \
            --bind "ctrl-/:change-preview-window(99%|)+preview(bash '$_ptmp' HELP {})" \
            --bind "ctrl-e:become(echo __EDIT__; echo {})" \
            --bind "ctrl-d:become(echo __DEL__; echo {})" \
            --bind "ctrl-f:become(echo __FORK__; echo {})")

        # ── Navigation ───────────────────────────────────────────────────────
        if   [[ "$res" == "__NEXT__" ]]; then sec=$(( (sec + 1) % 4 )); continue
        elif [[ "$res" == "__PREV__" ]]; then sec=$(( (sec - 1 + 4) % 4 )); continue
        elif [[ -z "$res" ]]; then return
        fi

        # ── Multi-line sentinel check (ctrl-e / ctrl-d / ctrl-f) ──────────────
        local _line1; _line1=$(printf '%s' "$res" | head -n1)
        local _line2; _line2=$(printf '%s' "$res" | tail -n+2)

        if [[ "$_line1" == "__DEL__" || "$_line1" == "__FORK__" || "$_line1" == "__EDIT__" ]]; then
            local _act_str; _act_str=$(printf '%s' "$_line2" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
            local _act_name; _act_name=$(echo "$_act_str" | awk '{print $1}')
            
            # Strip icons for actions
            [[ "$_act_name" == "◆" || "$_act_name" == "✦" || "$_act_name" == "✚" ]] && _act_name=$(echo "$_act_str" | awk '{print $2}')
            
            if [[ "$_line1" == "__EDIT__" ]]; then
                local _edit_file="$CUSTOM_THEME_DIR/${_act_name}.theme"
                if [[ -f "$_edit_file" ]]; then
                    if command -v $GUI_EDITOR >/dev/null; then
                        $GUI_EDITOR "$_edit_file" &
                    else
                        nano "$_edit_file" < /dev/tty
                    fi
                else
                    printf "\n${DIM}  Built-in themes cannot be edited directly. Fork it first (Ctrl+F).${RESET}\n" >/dev/tty; sleep 1.5
                fi
                continue

            elif [[ "$_line1" == "__DEL__" ]]; then
                local _del_file="$CUSTOM_THEME_DIR/${_act_name}.theme"
                if [[ -f "$_del_file" ]]; then
                    printf "\n${BOLD}${BAD}  Delete '${_act_name}'? [y/N]:${RESET} " >/dev/tty
                    local _conf; IFS= read -r _conf </dev/tty
                    if [[ "${_conf,,}" == "y" ]]; then
                        rm -f "$_del_file"
                        unset "THEME_LABELS[$_act_name]"
                        if [[ "$CURRENT_THEME" == "$_act_name" ]]; then
                            CURRENT_THEME="dynamic"; apply_theme "dynamic"
                            echo "$CURRENT_THEME" > "$THEME_FILE"
                        fi
                        printf "${GOOD}  ✔ Deleted.${RESET}\n" >/dev/tty; sleep 0.4
                    fi
                else
                    printf "\n${DIM}  Built-in themes cannot be deleted.${RESET}\n" >/dev/tty; sleep 0.7
                fi
                continue

            else # FORK
                [[ "$_act_name" == "create_new" || -z "$_act_name" ]] && continue
                fork_theme "$_act_name"
                continue
            fi
        fi

        # ── Parse normal single-line selection ───────────────────────────────
        local stripped chosen
        stripped=$(printf '%s' "$res" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
        chosen=$(echo "$stripped" | awk '{print $1}')
        
        # Strip indicator characters properly
        [[ "$chosen" == "◆" || "$chosen" == "✦" || "$chosen" == "✚" ]] && chosen=$(echo "$stripped" | awk '{print $2}')
        [[ -z "$chosen" ]] && continue
        
        # Skip separator / decoration lines — valid slugs are [a-zA-Z0-9_-] only
        [[ ! "$chosen" =~ ^[a-zA-Z0-9][a-zA-Z0-9_-]*$ ]] && continue

        case "$chosen" in
            feeling-lucky)
                USE_BG=1; apply_theme "feeling-lucky"
                echo "$CURRENT_THEME" > "$THEME_FILE" 
                ;;
            create_new)
                create_new_theme; return 
                ;;
            *)
                CURRENT_THEME="$chosen"
                echo "$CURRENT_THEME" > "$THEME_FILE"
                USE_BG=1; apply_theme "$CURRENT_THEME" 
                ;;
        esac
        export ACCENT GOLD FG BLUE FZF_DEFAULT_OPTS CURRENT_THEME USE_BG BAD \
               PIPE POINTER PREVIEW_POSITION PREVIEW_SIZE BAR_ICON
        return
    done
}

# ── Fork / duplicate any theme ────────────────────────────────────────────────
fork_theme() {
    local src="$1"
    local src_file="$CUSTOM_THEME_DIR/${src}.theme"

    printf "\n${BOLD}${ACCENT}  Fork: '${src}'${RESET}\n" >/dev/tty
    printf "${BOLD}  New name${RESET}${DIM} (slug — letters, digits, hyphens):${RESET}  " >/dev/tty
    local new_name; IFS= read -r new_name </dev/tty
    new_name=$(echo "$new_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
    if [[ -z "$new_name" ]]; then printf "${DIM}  Aborted.${RESET}\n" >/dev/tty; return; fi

    local new_file="$CUSTOM_THEME_DIR/${new_name}.theme"

    if [[ -f "$src_file" ]]; then
        cp "$src_file" "$new_file"
        sed -i "s/^THEME_LABEL=.*/THEME_LABEL=\"${new_name} (fork of ${src})\"/" "$new_file"
    else
        # Built-in: derive palette numbers from lookup table
        local _fa=4 _fg_v=3 _ff=7 _fgd=2 _fb=1 _fbg=236 _e
        for _e in $_THEME_NUMS; do
            IFS=':' read -r _tn _ca _cg _cf _cgd _cb _cbgn <<< "$_e"
            if [[ "$_tn" == "$src" ]]; then
                _fa=$_ca; _fg_v=$_cg; _ff=$_cf; _fgd=$_cgd; _fb=$_cb; _fbg=$_cbgn; break
            fi
        done

        local _sv_ACCENT="$ACCENT" _sv_GOLD="$GOLD" _sv_FG="$FG"
        local _sv_GOOD="$GOOD" _sv_BAD="$BAD" _sv_BG="$BG_COLOR" _sv_FZF="$_FZF"
        local _sv_PREV_POS="$PREVIEW_POSITION" _sv_PREV_SZ="$PREVIEW_SIZE"
        local _sv_PIPE="$PIPE" _sv_POINTER="$POINTER" _sv_BAR="$BAR_ICON"

        # Call apply_theme to get the exact, fully-specified _FZF string
        # (this is the only way to capture theme-specific values like border colors)
        apply_theme "$src"
        local _fork_FZF="$_FZF"

        # Restore the previously active theme state
        ACCENT="$_sv_ACCENT"; GOLD="$_sv_GOLD"; FG="$_sv_FG"
        GOOD="$_sv_GOOD"; BAD="$_sv_BAD"; BG_COLOR="$_sv_BG"; _FZF="$_sv_FZF"
        PREVIEW_POSITION="$_sv_PREV_POS"; PREVIEW_SIZE="$_sv_PREV_SZ"
        PIPE="$_sv_PIPE"; POINTER="$_sv_POINTER"; BAR_ICON="$_sv_BAR"

        cat > "$new_file" <<EOF
# Theme: ${new_name} (forked from ${src})
# Created: $(date +"%Y-%m-%d")
THEME_LABEL="${new_name} (fork of ${src})"
THEME_ACCENT=${_fa}
THEME_GOLD=${_fg_v}
THEME_FG=${_ff}
THEME_GOOD=${_fgd}
THEME_BAD=${_fb}
THEME_BG=${_fbg}
THEME_FZF="${_fork_FZF}"
THEME_POINTER=""
THEME_PIPE=" │ "
THEME_GUI_EDITOR="${GUI_EDITOR}"
THEME_PREVIEW_POS="${PREVIEW_POSITION}"
THEME_PREVIEW_SIZE="${PREVIEW_SIZE}"
THEME_BAR_ICON="${BAR_ICON}"
EOF
    fi

    THEME_LABELS["$new_name"]="${new_name} (fork of ${src})"
    printf "${GOOD}  ✔ Forked as '${new_name}'${RESET}${DIM} — Ctrl+E to edit it${RESET}\n" >/dev/tty; sleep 0.6
}

# ── Create New Theme ──────────────────────────────────────────────────────────
create_new_theme() {
    local themes_dir="$CUSTOM_THEME_DIR"
    mkdir -p "$themes_dir"

    # Banner
    echo -e "\n${BOLD}${ACCENT}  ✚  Create New Theme${RESET}" >/dev/tty
    echo -e "${DIM}  ─────────────────────────────────────────────────────────${RESET}" >/dev/tty
    echo -e "${DIM}  Enter a 256-color number for each field.${RESET}" >/dev/tty
    echo -e "${DIM}  Press Enter alone to keep the shown default.${RESET}\n" >/dev/tty

    # ── Identity ────────────────────────────────────────────────────────────
    echo -e "${BOLD}${ACCENT}── Identity ────────────────────────────────────────${RESET}" >/dev/tty
    printf "${BOLD}  Theme name  ${RESET}${DIM}(slug — letters, digits, hyphens):${RESET}  " >/dev/tty
    local theme_name; IFS= read -r theme_name </dev/tty
    theme_name=$(echo "$theme_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
    if [[ -z "$theme_name" ]]; then echo "  Aborted (empty name)." >/dev/tty; return; fi

    printf "${BOLD}  Description ${RESET}${DIM}(tagline shown in picker):${RESET}  " >/dev/tty
    local theme_label; IFS= read -r theme_label </dev/tty
    [[ -z "$theme_label" ]] && theme_label="$theme_name"

    # ── Text / tput colours ─────────────────────────────────────────────────
    echo -e "\n${BOLD}${ACCENT}── Text Colors ─────────────────────────────────────${RESET}" >/dev/tty
    printf "${BOLD}  ACCENT${RESET}  ${DIM}(headers, highlights, prompt  — default 4):${RESET}  " >/dev/tty
    local accent_num; IFS= read -r accent_num </dev/tty; [[ -z "$accent_num" ]] && accent_num=4
    printf "  \033[38;5;${accent_num}m██████████\033[0m  ${DIM}(%d)${RESET}\n" "$accent_num" >/dev/tty

    printf "${BOLD}  GOLD  ${RESET}  ${DIM}(favorites ★, update icons    — default 3):${RESET}  " >/dev/tty
    local gold_num; IFS= read -r gold_num </dev/tty; [[ -z "$gold_num" ]] && gold_num=3
    printf "  \033[38;5;${gold_num}m██████████\033[0m  ${DIM}(%d)${RESET}\n" "$gold_num" >/dev/tty

    printf "${BOLD}  FG    ${RESET}  ${DIM}(main list / body text        — default 7):${RESET}  " >/dev/tty
    local fg_num; IFS= read -r fg_num </dev/tty; [[ -z "$fg_num" ]] && fg_num=7
    printf "  \033[38;5;${fg_num}m██████████\033[0m  ${DIM}(%d)${RESET}\n" "$fg_num" >/dev/tty

    printf "${BOLD}  GOOD  ${RESET}  ${DIM}(up-to-date, success icons    — default 2):${RESET}  " >/dev/tty
    local good_num; IFS= read -r good_num </dev/tty; [[ -z "$good_num" ]] && good_num=2
    printf "  \033[38;5;${good_num}m██████████\033[0m  ${DIM}(%d)${RESET}\n" "$good_num" >/dev/tty

    printf "${BOLD}  BAD   ${RESET}  ${DIM}(errors, alert states         — default 1):${RESET}  " >/dev/tty
    local bad_num; IFS= read -r bad_num </dev/tty; [[ -z "$bad_num" ]] && bad_num=1
    printf "  \033[38;5;${bad_num}m██████████\033[0m  ${DIM}(%d)${RESET}\n" "$bad_num" >/dev/tty

    # ── Background ──────────────────────────────────────────────────────────
    echo -e "\n${BOLD}${ACCENT}── Background ──────────────────────────────────────${RESET}" >/dev/tty
    printf "${BOLD}  BG    ${RESET}  ${DIM}(fzf pane bg; -1 = terminal default  — default 236):${RESET}  " >/dev/tty
    local bg_num; IFS= read -r bg_num </dev/tty; [[ -z "$bg_num" ]] && bg_num=236
    printf "  \033[48;5;${bg_num}m    bg: %-3d    \033[0m\n" "$bg_num" >/dev/tty

    # ── FZF colours ─────────────────────────────────────────────────────────
    echo -e "\n${BOLD}${ACCENT}── FZF Colors ──────────────────────────────────────${RESET}" >/dev/tty
    echo -e "${DIM}  Q) Quick  — auto-derive from your choices above${RESET}" >/dev/tty
    echo -e "${DIM}  C) Custom — set every fzf color element individually${RESET}" >/dev/tty
    echo -e "${DIM}  S) String — paste a full fzf color string${RESET}" >/dev/tty
    printf "${BOLD}  Mode ${RESET}${DIM}[Q/C/S — default Q]:${RESET}  " >/dev/tty
    local fzf_mode; IFS= read -r fzf_mode </dev/tty
    fzf_mode="${fzf_mode,,}"; [[ -z "$fzf_mode" ]] && fzf_mode="q"

    local fzf_colors
    local _auto_bgp=$(( bg_num + 2 )); [[ $_auto_bgp -gt 254 || $bg_num -lt 0 ]] && _auto_bgp=238

    if [[ "$fzf_mode" == "c" ]]; then
        echo -e "\n${DIM}  Enter each fzf color (256-color int). Enter = default shown.${RESET}" >/dev/tty
        local fzf_fg fzf_hl fzf_fgp fzf_bgp fzf_hlp fzf_info fzf_prompt fzf_ptr fzf_spin fzf_bdr fzf_hdr
        local fzf_lbl fzf_gutter fzf_marker fzf_query fzf_disabled
        local fzf_pvfg fzf_pvbg fzf_pvbdr fzf_pvscroll fzf_pvlbl

        printf "  ${BOLD}fg      ${RESET}${DIM}(list text          — default ${fg_num}):${RESET}  "      >/dev/tty
        IFS= read -r fzf_fg    </dev/tty; [[ -z "$fzf_fg" ]]    && fzf_fg=$fg_num

        printf "  ${BOLD}hl      ${RESET}${DIM}(match highlight    — default ${accent_num}):${RESET}  "  >/dev/tty
        IFS= read -r fzf_hl    </dev/tty; [[ -z "$fzf_hl" ]]    && fzf_hl=$accent_num

        printf "  ${BOLD}fg+     ${RESET}${DIM}(selected text      — default 255):${RESET}  "            >/dev/tty
        IFS= read -r fzf_fgp   </dev/tty; [[ -z "$fzf_fgp" ]]   && fzf_fgp=255

        printf "  ${BOLD}bg+     ${RESET}${DIM}(selected bg        — default ${_auto_bgp}):${RESET}  "  >/dev/tty
        IFS= read -r fzf_bgp   </dev/tty; [[ -z "$fzf_bgp" ]]   && fzf_bgp=$_auto_bgp

        printf "  ${BOLD}hl+     ${RESET}${DIM}(selected match     — default ${accent_num}):${RESET}  " >/dev/tty
        IFS= read -r fzf_hlp   </dev/tty; [[ -z "$fzf_hlp" ]]   && fzf_hlp=$accent_num

        printf "  ${BOLD}info    ${RESET}${DIM}(counter / info     — default ${good_num}):${RESET}  "   >/dev/tty
        IFS= read -r fzf_info  </dev/tty; [[ -z "$fzf_info" ]]  && fzf_info=$good_num

        printf "  ${BOLD}prompt  ${RESET}${DIM}(prompt color       — default ${accent_num}):${RESET}  " >/dev/tty
        IFS= read -r fzf_prompt </dev/tty; [[ -z "$fzf_prompt" ]] && fzf_prompt=$accent_num

        printf "  ${BOLD}pointer ${RESET}${DIM}(cursor arrow       — default ${accent_num}):${RESET}  " >/dev/tty
        IFS= read -r fzf_ptr   </dev/tty; [[ -z "$fzf_ptr" ]]   && fzf_ptr=$accent_num

        printf "  ${BOLD}marker  ${RESET}${DIM}(multi-select mark  — default ${accent_num}):${RESET}  " >/dev/tty
        IFS= read -r fzf_marker </dev/tty; [[ -z "$fzf_marker" ]] && fzf_marker=$accent_num

        printf "  ${BOLD}spinner ${RESET}${DIM}(loading spinner    — default ${good_num}):${RESET}  "   >/dev/tty
        IFS= read -r fzf_spin  </dev/tty; [[ -z "$fzf_spin" ]]  && fzf_spin=$good_num

        printf "  ${BOLD}border  ${RESET}${DIM}(border lines       — default ${_auto_bgp}):${RESET}  "  >/dev/tty
        IFS= read -r fzf_bdr   </dev/tty; [[ -z "$fzf_bdr" ]]   && fzf_bdr=$_auto_bgp

        printf "  ${BOLD}header  ${RESET}${DIM}(header text        — default ${accent_num}):${RESET}  " >/dev/tty
        IFS= read -r fzf_hdr   </dev/tty; [[ -z "$fzf_hdr" ]]   && fzf_hdr=$accent_num

        printf "  ${BOLD}label   ${RESET}${DIM}(border label       — default ${accent_num}):${RESET}  " >/dev/tty
        IFS= read -r fzf_lbl   </dev/tty; [[ -z "$fzf_lbl" ]]   && fzf_lbl=$accent_num

        printf "  ${BOLD}gutter  ${RESET}${DIM}(left gutter bg     — default ${_auto_bgp}):${RESET}  " >/dev/tty
        IFS= read -r fzf_gutter </dev/tty; [[ -z "$fzf_gutter" ]] && fzf_gutter=$_auto_bgp

        printf "  ${BOLD}query   ${RESET}${DIM}(typed query text   — default 255):${RESET}  "           >/dev/tty
        IFS= read -r fzf_query  </dev/tty; [[ -z "$fzf_query" ]]  && fzf_query=255

        printf "  ${BOLD}disabled${RESET}${DIM}(query when no live — default 241):${RESET}  "           >/dev/tty
        IFS= read -r fzf_disabled </dev/tty; [[ -z "$fzf_disabled" ]] && fzf_disabled=241

        echo -e "\n  ${DIM}── Preview window colors ──────────────────────────────────${RESET}" >/dev/tty

        printf "  ${BOLD}preview-fg    ${RESET}${DIM}(preview text   — default ${fg_num}):${RESET}  "   >/dev/tty
        IFS= read -r fzf_pvfg   </dev/tty; [[ -z "$fzf_pvfg" ]]   && fzf_pvfg=$fg_num

        printf "  ${BOLD}preview-bg    ${RESET}${DIM}(preview bg     — default ${bg_num}):${RESET}  "   >/dev/tty
        IFS= read -r fzf_pvbg   </dev/tty; [[ -z "$fzf_pvbg" ]]   && fzf_pvbg=$bg_num

        printf "  ${BOLD}preview-border${RESET}${DIM}(preview border — default ${_auto_bgp}):${RESET}  " >/dev/tty
        IFS= read -r fzf_pvbdr  </dev/tty; [[ -z "$fzf_pvbdr" ]]  && fzf_pvbdr=$_auto_bgp

        printf "  ${BOLD}preview-scrollbar${RESET}${DIM}(scrollbar   — default ${accent_num}):${RESET}  " >/dev/tty
        IFS= read -r fzf_pvscroll </dev/tty; [[ -z "$fzf_pvscroll" ]] && fzf_pvscroll=$accent_num

        printf "  ${BOLD}preview-label ${RESET}${DIM}(preview label  — default ${accent_num}):${RESET}  " >/dev/tty
        IFS= read -r fzf_pvlbl  </dev/tty; [[ -z "$fzf_pvlbl" ]]  && fzf_pvlbl=$accent_num

        fzf_colors="fg:${fzf_fg},hl:${fzf_hl}:bold|fg+:${fzf_fgp}:bold,bg+:${fzf_bgp},hl+:${fzf_hlp}:bold|info:${fzf_info}:dim,prompt:${fzf_prompt}:bold,pointer:${fzf_ptr}:bold,spinner:${fzf_spin}:dim|border:${fzf_bdr}:bold,header:${fzf_hdr}:bold,label:${fzf_lbl}:bold,gutter:${fzf_gutter}:dim|marker:${fzf_marker}:bold,query:${fzf_query}:bold,disabled:${fzf_disabled}:dim,preview-fg:${fzf_pvfg},preview-bg:${fzf_pvbg},preview-border:${fzf_pvbdr}:bold,preview-scrollbar:${fzf_pvscroll},preview-label:${fzf_pvlbl}:bold"

    elif [[ "$fzf_mode" == "s" ]]; then
        echo -e "${DIM}  Format: fg:N,hl:N|fg+:N,bg+:N,hl+:N|info:N,prompt:N,pointer:N,spinner:N|border:N,header:N,label:N,gutter:N|marker:N,query:N,disabled:N,preview-fg:N,preview-bg:N,preview-border:N,preview-scrollbar:N,preview-label:N${RESET}" >/dev/tty
        printf "  ${BOLD}FZF string:${RESET}  " >/dev/tty
        IFS= read -r fzf_colors </dev/tty
        [[ -z "$fzf_colors" ]] && fzf_colors="fg:${fg_num},hl:${accent_num}:bold|fg+:255:bold,bg+:${_auto_bgp},hl+:${accent_num}:bold|info:${good_num}:dim,prompt:${accent_num}:bold,pointer:${accent_num}:bold,spinner:${good_num}:dim|border:${_auto_bgp}:bold,header:${accent_num}:bold,label:${accent_num}:bold,gutter:${_auto_bgp}:dim|marker:${accent_num}:bold,query:255:bold,disabled:${_auto_bgp}:dim,preview-fg:${fg_num},preview-bg:${bg_num},preview-border:${_auto_bgp}:bold,preview-scrollbar:${accent_num},preview-label:${accent_num}:bold"
    else
        fzf_colors="fg:${fg_num},hl:${accent_num}:bold|fg+:255:bold,bg+:${_auto_bgp},hl+:${accent_num}:bold|info:${good_num}:dim,prompt:${accent_num}:bold,pointer:${accent_num}:bold,spinner:${good_num}:dim|border:${_auto_bgp}:bold,header:${accent_num}:bold,label:${accent_num}:bold,gutter:${_auto_bgp}:dim|marker:${accent_num}:bold,query:255:bold,disabled:${_auto_bgp}:dim,preview-fg:${fg_num},preview-bg:${bg_num},preview-border:${_auto_bgp}:bold,preview-scrollbar:${accent_num},preview-label:${accent_num}:bold"
    fi

    # ── Misc ─────────────────────────────────────────────────────────────────
    echo -e "\n${BOLD}${ACCENT}── Misc ─────────────────────────────────────────────${RESET}" >/dev/tty
    printf "${BOLD}  Pointer char${RESET}  ${DIM}(cursor symbol — blank = fzf default ▶):${RESET}  " >/dev/tty
    local pointer_char; IFS= read -r pointer_char </dev/tty

    printf "${BOLD}  Pipe char   ${RESET}  ${DIM}(column separator — blank = keep current '${PIPE}'):${RESET}  " >/dev/tty
    local pipe_char; IFS= read -r pipe_char </dev/tty
    [[ -z "$pipe_char" ]] && pipe_char="$PIPE"

    printf "${BOLD}  Bar icon    ${RESET}  ${DIM}(progress bar fill — blank = keep current '${BAR_ICON}'):${RESET}  " >/dev/tty
    local bar_icon_val; IFS= read -r bar_icon_val </dev/tty
    [[ -z "$bar_icon_val" ]] && bar_icon_val="$BAR_ICON"

    # ── Display & Editor ─────────────────────────────────────────────────────
    echo -e "\n${BOLD}${ACCENT}── Display & Editor ─────────────────────────────────${RESET}" >/dev/tty
    printf "${BOLD}  GUI Editor  ${RESET}  ${DIM}(for Ctrl+E — default ${GUI_EDITOR}):${RESET}  " >/dev/tty
    local gui_editor_val; IFS= read -r gui_editor_val </dev/tty
    [[ -z "$gui_editor_val" ]] && gui_editor_val="$GUI_EDITOR"

    printf "${BOLD}  Preview pos ${RESET}  ${DIM}(bottom/right/top/left — default ${PREVIEW_POSITION}):${RESET}  " >/dev/tty
    local preview_pos_val; IFS= read -r preview_pos_val </dev/tty
    [[ -z "$preview_pos_val" ]] && preview_pos_val="$PREVIEW_POSITION"
    case "$preview_pos_val" in bottom|right|top|left) ;; *) preview_pos_val="$PREVIEW_POSITION" ;; esac

    printf "${BOLD}  Preview size${RESET}  ${DIM}(10–90, no %% needed — default ${PREVIEW_SIZE}):${RESET}  " >/dev/tty
    local preview_size_val; IFS= read -r preview_size_val </dev/tty
    if [[ -z "$preview_size_val" ]]; then
        preview_size_val="$PREVIEW_SIZE"
    else
        preview_size_val="${preview_size_val//%/}%"
    fi

    # ── Palette preview + confirmation ───────────────────────────────────────
    echo -e "\n${BOLD}${ACCENT}── Preview ──────────────────────────────────────────${RESET}" >/dev/tty
    printf "  \033[38;5;${accent_num}m████\033[0m  ${BOLD}Accent${RESET}  ${DIM}(%d)${RESET}\n" "$accent_num" >/dev/tty
    printf "  \033[38;5;${gold_num}m████\033[0m  ${BOLD}Gold  ${RESET}  ${DIM}(%d)${RESET}\n"   "$gold_num"   >/dev/tty
    printf "  \033[38;5;${fg_num}m████\033[0m  ${BOLD}Text  ${RESET}  ${DIM}(%d)${RESET}\n"     "$fg_num"     >/dev/tty
    printf "  \033[38;5;${good_num}m████\033[0m  ${BOLD}Good  ${RESET}  ${DIM}(%d)${RESET}\n"   "$good_num"   >/dev/tty
    printf "  \033[38;5;${bad_num}m████\033[0m  ${BOLD}Bad   ${RESET}  ${DIM}(%d)${RESET}\n"    "$bad_num"    >/dev/tty
    printf "  \033[48;5;${bg_num}m    bg: %-3d    \033[0m\n" "$bg_num" >/dev/tty
    echo "" >/dev/tty
    
    printf "${BOLD}  Save theme '${theme_name}'? [Y/n]:${RESET} " >/dev/tty
    local _save_ok; IFS= read -r _save_ok </dev/tty
    if [[ "${_save_ok,,}" == "n" ]]; then
        printf "${DIM}  Cancelled.${RESET}\n" >/dev/tty; return
    fi

    # ── Write the .theme file ─────────────────────────────────────────────────
    local outfile="$themes_dir/${theme_name}.theme"
    cat > "$outfile" <<EOF
# Theme: ${theme_name}
# Created: $(date +"%Y-%m-%d")
THEME_LABEL="${theme_label}"
THEME_ACCENT=${accent_num}
THEME_GOLD=${gold_num}
THEME_FG=${fg_num}
THEME_GOOD=${good_num}
THEME_BAD=${bad_num}
THEME_BG=${bg_num}
THEME_FZF="${fzf_colors}"
THEME_POINTER="${pointer_char}"
THEME_PIPE="${pipe_char}"
THEME_GUI_EDITOR="${gui_editor_val}"
THEME_PREVIEW_POS="${preview_pos_val}"
THEME_PREVIEW_SIZE="${preview_size_val}"
THEME_BAR_ICON="${bar_icon_val}"
EOF

    printf "\n${GOOD}  ✔ Theme '${theme_name}' saved.${RESET}  ${DIM}${outfile}${RESET}\n" >/dev/tty
    sleep 0.8

    THEME_LABELS["$theme_name"]="$theme_label"
    CURRENT_THEME="$theme_name"
    echo "$CURRENT_THEME" > "$THEME_FILE"
    USE_BG=1; apply_theme "$CURRENT_THEME"
    export ACCENT GOLD FG BLUE FZF_DEFAULT_OPTS CURRENT_THEME USE_BG BAD POINTER
}

export -f apply_theme show_theme_picker fork_theme _swatch _lookup_nums create_new_theme
export SPECIAL_THEME_ORDER
export LUCKY_PIPES LUCKY_POINTERS LUCKY_BAR_ICONS
export _THEME_NUMS

# ============================================================
# ARRAY_DEFS — dynamic snapshot for subshell contexts
# ============================================================
# Functions called inside fzf (subshells) cannot access parent
# shell arrays directly. ARRAY_DEFS captures all arrays loaded
# from DATA_FILE so they can be eval'd where needed.
# ============================================================
_adf_vars=(ALIASES CATEGORY_DEFS SUBCATEGORY_DEFS)
for _adf_def in "${CATEGORY_DEFS[@]}" "${SUBCATEGORY_DEFS[@]}"; do
    IFS="|" read -r _ _ _adf_var <<< "$_adf_def"
    [[ -n "$_adf_var" ]] && _adf_vars+=("$_adf_var")
done
ARRAY_DEFS=$(declare -p "${_adf_vars[@]}" 2>/dev/null)
unset _adf_vars _adf_def _adf_var

# ============================================================
# LOGIC FUNCTIONS
# ============================================================

# ── Grouping & Classification ─────────────────────────────────
in_group() {
    local name="$1"; shift
    local group=("$@")
    for item in "${group[@]}"; do [[ "$item" == "$name" ]] && return 0; done
    return 1
}

category_of() {
    local name="$1"
    local _def _icon _label _var
    for _def in "${CATEGORY_DEFS[@]}"; do
        IFS="|" read -r _icon _label _var <<< "$_def"
        local -n _cat_arr="$_var" 2>/dev/null || continue
        in_group "$name" "${_cat_arr[@]}" && echo "$_label" && return
    done
    echo "Other"
}

subcategory_of() {
    local name="$1"
    local _def _icon _label _var
    for _def in "${SUBCATEGORY_DEFS[@]}"; do
        IFS="|" read -r _icon _label _var <<< "$_def"
        local -n _sub_arr="$_var" 2>/dev/null || continue
        in_group "$name" "${_sub_arr[@]}" && echo "$_label" && return
    done
    echo "General"
}

display_name_of() { [[ -n "${ALIASES[$1]}" ]] && echo "${ALIASES[$1]}" || echo "$1"; }
is_fav() { grep -q "^$1$" "$FAVORITES_FILE"; }

str_repeat() {
    local char="$1"
    local count="$2"
    [[ "$count" -gt 0 ]] && printf "%${count}s" | tr ' ' "$char"
}

# ── Status Labels ─────────────────────────────────────────────
get_status_label() {
    local link="$1"
    local remote_ver="$2"
    local status_raw="$3"
    
    if [[ "$status_raw" == "UPDATE_AVAIL" ]]; then
        echo "${BOLD}${GOLD}󱄋 Update Available!${RESET}"
    elif [[ "$link" == *"github.com"* && "$remote_ver" == "N/A" && "$status_raw" != "PENDING" ]]; then
        echo "${DIM}󰜺 No Release Found${RESET}"
    elif [[ "$status_raw" == "UPDATED" ]]; then
        echo "${BOLD}${GOOD}󰄬 Up to Date${RESET}"
    elif [[ -z "$link" ]]; then
        echo "${DIM}󰅙 No Link${RESET}"
    elif [[ "$status_raw" == "PENDING" ]]; then
        if [[ "$link" != *"github.com"* ]]; then
            echo "${BOLD}${DIM}󰌌 External Link${RESET}"
        else
            echo "${DIM}󰑮 Pending Scan${RESET}"
        fi
    else
        echo "${BAD}${DIM}${status_raw}${RESET}"
    fi
}

get_status_label_themed() {
    local link="$1"
    local remote_ver="$2"
    local status_raw="$3"

    if [[ "$status_raw" == "UPDATE_AVAIL" ]]; then
        echo "${BOLD}${GOLD}󱄋 Update Available!${RESET}"
    elif [[ "$link" == *"github.com"* && "$remote_ver" == "N/A" && "$status_raw" != "PENDING" ]]; then
        echo "${DIM}󰜺 No Release Found${RESET}"
    elif [[ "$status_raw" == "UPDATED" ]]; then
        echo "${BOLD}${GOOD}󰄬 Up to Date${RESET}"
    elif [[ -z "$link" ]]; then
        echo "${DIM}󰅙 No Link${RESET}"
    elif [[ "$status_raw" == "PENDING" ]]; then
        if [[ "$link" != *"github.com"* ]]; then
            echo "${BOLD}${DIM}󰌌 External Link${RESET}"
        else
            echo "${DIM}󰑮 Pending Scan${RESET}"
        fi
    else
        echo "${DIM}${status_raw}${RESET}"
    fi
}

# ── Update Checking & Progress ────────────────────────────────
check_update() {
    local fn="$1"
    local file="$FISH_FUNCTIONS_DIR/$fn.fish"
    local link=$(grep -Po "(?<=--link\s\")[^\"]*" "$file")
    [[ -z "$link" ]] && return
    
    local remote_date=""
    local remote_ver="N/A"
    
    if [[ "$link" == *"github.com"* ]]; then
        repo=$(echo "$link" | sed -E 's|https?://github.com/||' | sed 's|/$||' | cut -d'/' -f1,2)
        api_res=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" --connect-timeout 2 "https://api.github.com/repos/$repo/releases/latest")
        remote_date=$(echo "$api_res" | jq -r '.published_at // empty' | cut -d'T' -f1)
        remote_ver=$(echo "$api_res" | jq -r '.tag_name // empty')
        
        if [[ -z "$remote_date" || "$remote_date" == "null" ]]; then
            api_res=$(curl -s -H "Authorization: Bearer $GITHUB_TOKEN" --connect-timeout 2 "https://api.github.com/repos/$repo")
            remote_date=$(echo "$api_res" | jq -r '.pushed_at // empty' | cut -d'T' -f1)
        fi
        [[ -z "$remote_ver" || "$remote_ver" == "null" ]] && remote_ver="N/A"
    else
        remote_raw=$(curl -sI -L --connect-timeout 2 "$link" | grep -i "last-modified" | cut -d':' -f2- | xargs)
        [[ -n "$remote_raw" ]] && remote_date=$(date -d "$remote_raw" +"%Y-%m-%d" 2>/dev/null)
        
        remote_ver=$(curl -Ls -o /dev/null -w "%{url_effective}" "$link" | grep -oP '\d+\.\d+(\.\d+)?' | tail -n 1)
        if [[ -z "$remote_ver" ]]; then
            remote_ver=$(curl -sI -L --connect-timeout 2 "$link" | grep -i "^etag:" | cut -d'"' -f2 | head -c 8)
        fi
        [[ -z "$remote_ver" ]] && remote_ver="N/A"
    fi
    
    if [[ -n "$remote_date" && "$remote_date" != "null" ]]; then
        echo "$remote_date" > "$UPDATE_CACHE/$fn.remote_date"
        echo "$remote_ver" > "$UPDATE_CACHE/$fn.remote_ver"
        local_sec=$(date -r "$file" +%s)
        remote_sec=$(date -d "$remote_date" +%s)
        if [[ "$remote_sec" -gt "$local_sec" ]]; then
            echo "UPDATE_AVAIL" > "$UPDATE_CACHE/$fn.status"
        else
            echo "UPDATED" > "$UPDATE_CACHE/$fn.status"
        fi
    fi
}

scan_all_updates_with_progress() {
    echo -e "${BOLD}Scanning all linked functions for updates...${RESET}"
    local temp_dir=$(mktemp -d)
    local all_files=($(find "$FISH_FUNCTIONS_DIR" -maxdepth 1 -type f -name "*.fish"))
    local total=${#all_files[@]}
    
    if [[ $total -eq 0 ]]; then return; fi

    for file in "${all_files[@]}"; do
        local fn=$(basename "$file" .fish)
        ( check_update "$fn"; touch "$temp_dir/$fn" ) &
    done

    while true; do
        local completed=$(find "$temp_dir" -type f | wc -l)
        local percent=$(( completed * 100 / total ))
        local hashes=$(( percent / 2 ))
        local spaces=$(( 50 - hashes ))
        
        local bar_str="" _bi
        for (( _bi=0; _bi<hashes; _bi++ )); do bar_str+="${BAR_ICON:-#}"; done
        local spaces_str=$(str_repeat ' ' "$spaces")
        
        printf "\r\033[K${ACCENT}${BOLD}Progress:${RESET} [${ACCENT}%s${RESET}%s] %3d%% (%d/%d)" "$bar_str" "$spaces_str" "$percent" "$completed" "$total"
            
        if [[ "$completed" -ge "$total" ]]; then break; fi
        sleep 0.1
    done
    printf "\n"
    rm -rf "$temp_dir"
}

# ── Category & Subcategory View Builders ─────────────────────
get_category_view() {
    eval "$ARRAY_DEFS"
    local all_files=$(find "$FISH_FUNCTIONS_DIR" -maxdepth 1 -type f -name "*.fish" -exec basename {} .fish \;)
    local other_count=0
    for f in $all_files; do [[ $(category_of "$f") == "Other" ]] && ((other_count++)); done
    local _def _icon _label _var
    for _def in "${CATEGORY_DEFS[@]}"; do
        IFS="|" read -r _icon _label _var <<< "$_def"
        local -n _cv_arr="$_var" 2>/dev/null || continue
        printf "%s %-30s (%d)\n" "$_icon" "$_label" "${#_cv_arr[@]}"
    done
    printf "󰚗 %-30s (%d)\n" "Other" "$other_count"
}

get_subcategory_view() {
    eval "$ARRAY_DEFS"
    local all_files=$(find "$FISH_FUNCTIONS_DIR" -maxdepth 1 -type f -name "*.fish" -exec basename {} .fish \;)
    local general_count=0
    for f in $all_files; do [[ $(subcategory_of "$f") == "General" ]] && ((general_count++)); done
    local _def _icon _label _var
    for _def in "${SUBCATEGORY_DEFS[@]}"; do
        IFS="|" read -r _icon _label _var <<< "$_def"
        local -n _sv_arr="$_var" 2>/dev/null || continue
        printf "%s %-30s (%d)\n" "$_icon" "$_label" "${#_sv_arr[@]}"
    done
    printf "󰘳 %-30s (%d)\n" "General" "$general_count"
}

show_update_list() {
    while true; do
        local list=$(
            local counter=1
            find "$FISH_FUNCTIONS_DIR" -maxdepth 1 -type f -name "*.fish" | sort | while read -r file; do
                fn=$(basename "$file" .fish)
                link=$(grep -Po "(?<=--link\s\")[^\"]*" "$file")
                local_date=$(date -r "$file" +"%Y-%m-%d")
                local_ver=$(grep -Po "(?<=--version\s\")[^\"]*" "$file" || echo "N/A")
                remote_date=$(cat "$UPDATE_CACHE/$fn.remote_date" 2>/dev/null || echo "---")
                remote_ver=$(cat "$UPDATE_CACHE/$fn.remote_ver" 2>/dev/null || echo "N/A")
                status_raw=$(cat "$UPDATE_CACHE/$fn.status" 2>/dev/null || echo "PENDING")
                
                status=$(get_status_label_themed "$link" "$remote_ver" "$status_raw")
                
                lv="${local_ver:0:10}"
                rv="${remote_ver:0:10}"
                
                printf " %3d ${PIPE} %-24s ${PIPE} %-10s ${DIM}│${RESET} %-10s ${PIPE} %-10s ${DIM}│${RESET} %-10s ${PIPE} %s\n" \
                    "$counter" "$fn" "$local_date" "$lv" "$remote_date" "$rv" "$status"
                ((counter++))
            done
        )
        header="${BOLD}$(printf " %3s ${PIPE} %-24s   ${PIPE} %-23s     ${PIPE} %-23s     ${PIPE} %s" "No." "  FUNCTION" "    (Date │ Ver)" "    (Date │ Ver)" "󱖫  STATUS")${RESET}"
        res=$(echo "$list" | fzf --ansi --height=100% --reverse --border \
            --header="$header" --prompt="󰚰  Update List (Tab to Scan All, Enter/Ctrl+C to Back): " \
            --bind "tab:become(echo SCAN_ALL)")
        if [[ "$res" == "SCAN_ALL" ]]; then
            scan_all_updates_with_progress
        else
            break
        fi
    done
}

export -f in_group category_of subcategory_of display_name_of is_fav get_category_view get_subcategory_view get_status_label get_status_label_themed check_update show_update_list scan_all_updates_with_progress str_repeat

# ── Notes Helpers ─────────────────────────────────────────────
get_note()  { grep "^${1}=" "$NOTES_FILE" 2>/dev/null | cut -d'=' -f2-; }
save_note() {
    local fn="$1" text="$2"
    if [[ -z "$text" ]]; then
        sed -i "/^${fn}=/d" "$NOTES_FILE"
    elif grep -q "^${fn}=" "$NOTES_FILE"; then
        sed -i "s|^${fn}=.*|${fn}=${text}|" "$NOTES_FILE"
    else
        echo "${fn}=${text}" >> "$NOTES_FILE"
    fi
}
edit_note() {
    local fn="$1"
    local current; current=$(get_note "$fn")
    printf "${BOLD}Note for '%s'${RESET} ${DIM}(blank to clear)${RESET}\nCurrent: %s\nNew: " \
        "$fn" "${current:-(none)}" >/dev/tty
    local new_note; IFS= read -r new_note </dev/tty
    save_note "$fn" "$new_note"
}
export -f get_note save_note edit_note
export FISH_FUNCTIONS_DIR FAVORITES_FILE HISTORY_FILE NOTES_FILE THEME_FILE PIPE POINTER BAR_ICON PREVIEW_POSITION PREVIEW_SIZE RESET BOLD DIM ACCENT GOLD GOOD BAD GITHUB_TOKEN BLUE GREEN YELLOW RED UPDATE_CACHE FG GUI_EDITOR ARRAY_DEFS CURRENT_THEME USE_BG CUSTOM_THEME_DIR DATA_FILE CATEGORY_DEFS SUBCATEGORY_DEFS
# Export all category and subcategory arrays loaded from DATA_FILE
for _exp_def in "${CATEGORY_DEFS[@]}" "${SUBCATEGORY_DEFS[@]}"; do
    IFS="|" read -r _ _ _exp_var <<< "$_exp_def"
    [[ -n "$_exp_var" ]] && export "${_exp_var}"
done
unset _exp_def _exp_var

# ============================================================
# UI LOGIC
# ============================================================
calculate_widths() {
    max_app=0; max_cmd=0; max_cat=0; max_sub=0
    while read -r fn; do
        app=$(display_name_of "$fn")
        cat=$(category_of "$fn")
        sub=$(subcategory_of "$fn")
        (( ${#app} > max_app )) && max_app=${#app}
        (( ${#fn} > max_cmd )) && max_cmd=${#fn}
        (( ${#cat} > max_cat )) && max_cat=${#cat}
        (( ${#sub} > max_sub )) && max_sub=${#sub}
    done < <(find "$FISH_FUNCTIONS_DIR" -maxdepth 1 -type f -name "*.fish" -exec basename {} .fish \;)
    export W_APP=$max_app W_CMD=$max_cmd W_CAT=$((max_cat + 2)) W_SUB=$max_sub
}
calculate_widths

# ── Menu Builder ─────────────────────────────────────────────
build_menu() {
    local filter="$1"
    local sub_filter="$2"
    local rec_type="$3"
    local counter=1
    if [[ "$filter" == "REC" ]]; then
        if [[ "$rec_type" == "FILE" ]]; then
            items=$(find "$FISH_FUNCTIONS_DIR" -type f -name "*.fish" -printf "%T@ %f\n" | sort -nr | head -n 10 | cut -d' ' -f2- | sed 's/\.fish$//')
        else
            items=$(cat "$HISTORY_FILE")
        fi
    elif [[ "$filter" == "UPD" ]]; then
        items=$(find "$UPDATE_CACHE" -name "*.status" -exec grep -l "UPDATE_AVAIL" {} + | xargs -I{} basename {} .status | sort)
    else
        items=$(find "$FISH_FUNCTIONS_DIR" -type f -name "*.fish" -exec basename {} .fish \; | sort)
    fi
    echo "$items" | while read fn; do
        [[ -z "$fn" ]] && continue
        
        is_fav "$fn" && is_favorite=1 || is_favorite=0
        if [[ "$filter" == "FAV" && $is_favorite -eq 0 ]]; then continue; fi
        
        app=$(display_name_of "$fn"); cat=$(category_of "$fn"); sub=$(subcategory_of "$fn")
        if [[ -n "$sub_filter" && "$sub_filter" != "ALL" ]]; then
            [[ "${sub^^}" != "${sub_filter^^}" && "${cat^^}" != "${sub_filter^^}" ]] && continue
        fi
        
        fav_mark=" "
        [[ $is_favorite -eq 1 ]] && fav_mark="${GOLD}★${RESET}"
        
        update_icon=" "
        if [[ -f "$UPDATE_CACHE/$fn.status" ]] && grep -q "UPDATE_AVAIL" "$UPDATE_CACHE/$fn.status"; then
            update_icon="${GOLD}󱄋${RESET}"
        fi
        
        printf " %s %s %3d ${PIPE}%-*s${PIPE}%-*s${PIPE}${DIM}%-*s${RESET}${PIPE}${DIM}%-*s${RESET}\n" \
          "$fav_mark" "$update_icon" "$counter" "$W_APP" "$app" "$W_CMD" "$fn" "$W_CAT" "$cat" "$W_SUB" "$sub"
        ((counter++))
    done
}
export -f build_menu

# ── History Tracking ──────────────────────────────────────────
update_history() {
    local cmd_name="$1"
    (echo "$cmd_name"; grep -v "^$cmd_name$" "$HISTORY_FILE") | head -n 10 > "$HISTORY_FILE.tmp"
    mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}

# ============================================================
# MAIN LOOP
# ============================================================
MODES=("ALL" "REC" "FAV" "UPD")
TAB_NAMES=(" 󰄬 ALL " " 󰄉 RECENT " " 󰓏 FAVORITES " " 󰚰 UPDATES ")
IDX=0
SUB_FILTER="ALL"
REC_TYPE="APP" 

rm -f /tmp/launcher_help

PENDING_UPDATES=$(find "$UPDATE_CACHE" -name "*.status" -exec grep -l "UPDATE_AVAIL" {} + 2>/dev/null | wc -l)

while true; do
    CURRENT_MODE=${MODES[$IDX]}
    
    DISPLAY_TAB_NAMES=("${TAB_NAMES[@]}")
    if [[ "$REC_TYPE" == "FILE" ]]; then
        DISPLAY_TAB_NAMES[1]=" 󰁫 RECENT "
    else
        DISPLAY_TAB_NAMES[1]=" 󰄉 RECENT "
    fi
    
    if [[ "$PENDING_UPDATES" -gt 0 ]]; then
        DISPLAY_TAB_NAMES[3]=" 󱄋 UPDATES ${DIM}(${PENDING_UPDATES})${RESET}"
    else
        DISPLAY_TAB_NAMES[3]=" 󰚰 UPDATES "
    fi

    TAB_BAR=""
    for i in "${!MODES[@]}"; do
        if [ "$i" -eq "$IDX" ]; then
            if [ "$i" -eq 3 ] && [[ "$PENDING_UPDATES" -gt 0 ]]; then
                TAB_BAR="${TAB_BAR}${BOLD}${FG}[ 󱄋 UPDATES ${DIM}(${PENDING_UPDATES})${RESET}${BOLD}${FG} ]${RESET} "
            else
                TAB_BAR="${TAB_BAR}${BOLD}${FG}[${DISPLAY_TAB_NAMES[$i]}]${RESET} "
            fi
        else
            if [ "$i" -eq 3 ] && [[ "$PENDING_UPDATES" -gt 0 ]]; then
                TAB_BAR="${TAB_BAR}${DIM} 󱄋 UPDATES (${PENDING_UPDATES}) ${RESET} "
            else
                TAB_BAR="${TAB_BAR}${DIM} ${DISPLAY_TAB_NAMES[$i]} ${RESET} "
            fi
        fi
    done

    FILTER_STATUS=""
    [[ -n "$SUB_FILTER" && "$SUB_FILTER" != "ALL" ]] && FILTER_STATUS=" ${GOLD}(Filtered: $SUB_FILTER)${RESET}"

    HEADER_BAR="${TAB_BAR}${FILTER_STATUS}${DIM}${RESET}"
    COLUMN_HEADER="${BOLD}$(printf "      No ${PIPE}%-*s${PIPE}%-*s${PIPE}%-*s${PIPE}%-*s" "$W_APP" "Application" "$W_CMD" "Command" "$W_CAT" "Category" "$W_SUB" "Subcategory")${RESET}"

    WIN_OPTS="$PREVIEW_POSITION:$PREVIEW_SIZE:wrap"

    HELP_TEXT="
  ${BOLD}${ACCENT}── LAUNCHER HELP ───────────────────────────${RESET} 

  ${BOLD}CORE COMMANDS${RESET}
  ${ACCENT}Enter${RESET}            Launch selected application
  ${ACCENT}Alt/Ctrl + a${RESET}     Launch with custom arguments
  ${ACCENT}Ctrl + e${RESET}         Edit fish function file (GUI/nano)
  ${ACCENT}Ctrl + n${RESET}         Add / edit note for selected app
  ${ACCENT}Ctrl + f${RESET}         Toggle Favorite (★)
  ${ACCENT}Ctrl + t${RESET}         Open Theme Picker
  ${ACCENT}Ctrl + b${RESET}         Toggle background color on/off
  ${ACCENT}Ctrl + h${RESET}         Toggle app help text in preview
  ${ACCENT}Ctrl + r${RESET}         Reset filters / return to All
  ${ACCENT}Ctrl + /${RESET}         Show this help menu
  ${ACCENT}Ctrl + c / Esc${RESET}   Back / Exit

  ${BOLD}TABS & FILTERS${RESET}
  ${ACCENT}←  /  →${RESET}          Switch tabs (All / Recent / Favs / Updates)
  ${ACCENT}Tab on All${RESET}        Open category / subcategory filter
  ${ACCENT}Tab on Recent${RESET}     Toggle Recent mode (󰄉 Apps ↔ 󰁫 Files)
  ${ACCENT}Tab on Updates${RESET}    Open Update List Summary

  ${BOLD}PREVIEW WINDOW${RESET}
  ${ACCENT}Alt + p${RESET}           Cycle preview direction (↓ → ↑ ←)
  ${ACCENT}Alt + i${RESET}           Increase preview size
  ${ACCENT}Alt + d${RESET}           Decrease preview size

  ${BOLD}THEME PICKER  ${DIM}(Ctrl+T to open)${RESET}
  ${ACCENT}Enter${RESET}             Apply selected theme
  ${ACCENT}Ctrl + e${RESET}          Edit theme file (custom themes only)
  ${ACCENT}Ctrl + f${RESET}          Fork (duplicate) any theme
  ${ACCENT}Ctrl + d${RESET}          Delete theme (custom/lucky themes only)
  ${ACCENT}←  /  →${RESET}          Switch picker tabs (Main / Lucky / Create)

  ${BOLD}FZF INTERFACE ELEMENTS${RESET}
  ${DIM}fg${RESET}               Normal text
  ${DIM}bg${RESET}               Normal background
  ${DIM}hl${RESET}               Highlighted substrings (search matches)
  ${DIM}fg+${RESET}              Text on currently selected line
  ${DIM}bg+${RESET}              Background of currently selected line
  ${DIM}hl+${RESET}              Highlighted substrings on selected line
  ${DIM}info${RESET}             Match counter (e.g. 10/100)
  ${DIM}prompt${RESET}           Prompt indicator (default >)
  ${DIM}pointer${RESET}          Current line pointer (default >)
  ${DIM}marker${RESET}           Multi-select marker (default >)
  ${DIM}spinner${RESET}          Streaming input indicator
  ${DIM}header${RESET}           Header text
  ${DIM}gutter${RESET}           Left gutter (pointer / marker space)
  ${DIM}query${RESET}            Query string you are actively typing
  ${DIM}disabled${RESET}         Query color when search is disabled
  ${DIM}border${RESET}           Border around the fzf window
  ${DIM}label${RESET}            Label text embedded in the border
  ${DIM}preview-fg${RESET}       Text inside the preview window
  ${DIM}preview-bg${RESET}       Background of the preview window
  ${DIM}preview-border${RESET}   Border surrounding the preview window
  ${DIM}preview-scrollbar${RESET} Scrollbar inside the preview window
  ${DIM}preview-label${RESET}    Label in the preview window border

  ${ACCENT}────────────────────────────────────────────${RESET}

  ${BOLD}DATA FILE${RESET}
  ${DIM}Apps, aliases, categories, subcategories,${RESET}
  ${DIM}and your GitHub token are defined in: ${RESET}${BOLD}${DIM}${DATA_FILE}${RESET}
  ${DIM}Edit that file to add/remove apps or groups.${RESET}

  ${ACCENT}────────────────────────────────────────────${RESET}
"
    PREVIEW_CMD='
        real_fn=$(echo {} | awk -F "│" "{print \$3}" | xargs)
        
        if [[ -f "/tmp/launcher_help" ]]; then
            echo -e "'$BOLD$ACCENT' 󰋖 Help for $real_fn'$RESET'\n"
            timeout 8 fish -c "if type $real_fn >/dev/null 2>&1; $real_fn --help 2>&1 || $real_fn -h 2>&1 || $real_fn help 2>&1; else echo \"'$DIM'No help text found.'$RESET'\"; end" </dev/null 2>&1 | head -120
            exit 0
        fi
        
        display_fn=$(echo {} | awk -F "│" "{print \$2}" | xargs)
        category=$(echo {} | awk -F "│" "{print \$4}" | xargs)
        subcategory=$(echo {} | awk -F "│" "{print \$5}" | xargs)
        file="'"$FISH_FUNCTIONS_DIR"'/$real_fn.fish"
        
        local_date="---"
        local_ver="N/A"
        desc="'$DIM'No description available.'$RESET'"
        
        if [[ -f "$file" ]]; then
            extracted_desc=$(grep -Po "(?<=--description\s\")[^\"]*" "$file")
            [[ -n "$extracted_desc" ]] && desc="$extracted_desc"
            link=$(grep -Po "(?<=--link\s\")[^\"]*" "$file")
            local_date=$(date -r "$file" +"%Y-%m-%d")
            local_ver=$(grep -Po "(?<=--version\s\")[^\"]*" "$file" || echo "N/A")
        fi
        
        fav_text=""
        if grep -q "^$real_fn$" "'"$FAVORITES_FILE"'"; then fav_text="  '$GOLD'★ Favorite'$RESET'"; fi
        
        echo -e "\n'$BOLD$ACCENT' 󰀻 $display_fn$fav_text'$RESET'"
        echo -e "'$DIM' ────────────────────────────────────────────────────────'$RESET'"
        printf "  '$BOLD'%-15s'$RESET' %s\n" " Command:" "  $real_fn"
        printf "  '$BOLD'%-15s'$RESET' %s\n" " Category:" "  $category"
        printf "  '$BOLD'%-15s'$RESET' %s\n" " Subcategory:" " $subcategory"
        printf "  '$BOLD'%-15s'$RESET' %s\n" "󰧮 Fish file:" "  $file"
        echo -e "'$DIM' ────────────────────────────────────────────────────────'$RESET'"
        echo -e "  '$BOLD' Description:'$RESET'\n  $desc\n"
        
        if [[ -n "$link" ]]; then
            remote_date=$(cat "'"$UPDATE_CACHE"'/$real_fn.remote_date" 2>/dev/null || echo "---")
            remote_ver=$(cat "'"$UPDATE_CACHE"'/$real_fn.remote_ver" 2>/dev/null || echo "N/A")
            status_raw=$(cat "'"$UPDATE_CACHE"'/$real_fn.status" 2>/dev/null || echo "PENDING")
            
            status_text=$(get_status_label_themed "$link" "$remote_ver" "$status_raw")
            
            echo -e "'$BOLD$ACCENT' 󰚰 Update Information'$RESET'"
            echo -e "'$DIM' ╭────────────────────────────────────────────────────────╮'$RESET'"
            printf "'$DIM' │'$RESET' '$BOLD' Link:   '$RESET' %s\n" "$link"
            printf "'$DIM' │'$RESET' '$BOLD' Local:  '$RESET' %-12s '$DIM'│'$RESET' %s\n" "$local_date" "$local_ver"
            if [[ "$remote_date" != "---" ]]; then
                printf "'$DIM' │'$RESET' '$BOLD' Remote: '$RESET' %-12s '$DIM'│'$RESET' %s\n" "$remote_date" "$remote_ver"
            fi
            printf "'$DIM' │'$RESET' '$BOLD'󱖫 Status: '$RESET' %s\n" "$status_text"
            echo -e "'$DIM' ╰────────────────────────────────────────────────────────╯'$RESET'"
        fi

        note=$(get_note "$real_fn")
        if [[ -n "$note" ]]; then
            echo -e "  '$BOLD$ACCENT'󰍨 Note:'$RESET'"
            echo -e "  $note\n"
        fi
    '

    # ── Bottom keybind legend (shown in the fzf border) ──────────────────
    FZF_BOTTOM_LEGEND="${DIM} 󰌌 [Enter] Launch  •  [←/→] Tabs  •  [Tab] Filter  •  [Ctrl+T] Theme  •  [Ctrl+/] Help ${RESET}"

    selection=$(build_menu "$CURRENT_MODE" "$SUB_FILTER" "$REC_TYPE" | fzf \
        --ansi \
        --border=rounded --border-label-pos=bottom --border-label="$FZF_BOTTOM_LEGEND" \
        --header="$HEADER_BAR"$'\n'"$COLUMN_HEADER" \
        --prompt="󰍉 Search: " \
        --reverse --height=100% \
        --preview-window="$WIN_OPTS" \
        --preview "$PREVIEW_CMD" \
        --bind "right:become(echo 'NEXT_MODE')" \
        --bind "left:become(echo 'PREV_MODE')" \
        --bind "tab:become(echo 'TOGGLE_TAB')" \
        --bind "ctrl-r:become(echo 'RESET_FILTER')" \
        --bind "ctrl-t:become(echo 'PICK_THEME')" \
        --bind "ctrl-b:become(echo 'TOGGLE_BG')" \
        --bind "alt-p:become(echo 'CYCLE_PREVIEW_DIR')" \
        --bind "alt-i:become(echo 'PREVIEW_GROW')" \
        --bind "alt-d:become(echo 'PREVIEW_SHRINK')" \
        --bind "ctrl-n:execute(fn=\$(echo {} | awk -F '│' ' {print \$3} ' | xargs); edit_note \"\$fn\")+refresh-preview" \
        --bind "ctrl-e:execute(fn=\$(echo {} | awk -F '│' ' {print \$3} ' | xargs); if command -v $GUI_EDITOR >/dev/null; then $GUI_EDITOR \"$FISH_FUNCTIONS_DIR/\$fn.fish\" & else nano \"$FISH_FUNCTIONS_DIR/\$fn.fish\" < /dev/tty; fi)" \
        --bind "ctrl-f:execute(fn=\$(echo {} | awk -F '│' ' {print \$3} ' | xargs); if grep -q \"^\$fn\$\" \"$FAVORITES_FILE\"; then grep -v \"^\$fn\$\" \"$FAVORITES_FILE\" > \"$FAVORITES_FILE.tmp\" && mv \"$FAVORITES_FILE.tmp\" \"$FAVORITES_FILE\"; else echo \"\$fn\" >> \"$FAVORITES_FILE\"; fi)+reload(build_menu $CURRENT_MODE '$SUB_FILTER' $REC_TYPE)" \
        --bind "ctrl-h:execute-silent(if [ -f /tmp/launcher_help ]; then rm -f /tmp/launcher_help; else touch /tmp/launcher_help; fi)+refresh-preview" \
        --bind "ctrl-/:change-preview-window(99%|)+preview(echo \"$HELP_TEXT\")" \
        --bind "ctrl-a:become(
            real_fn=\$(echo {} | awk -F '│' '{print \$3}' | xargs);
            read -p \"Args for \$real_fn: \" tags;
            echo \"RUN:\$real_fn \$tags\"
        )" \
        --bind "alt-a:become(
            real_fn=\$(echo {} | awk -F '│' ' {print \$3} ' | xargs);
            read -p \"Args for \$real_fn: \" tags;
            echo \"RUN:\$real_fn \$tags\"
        )" \
        --bind "enter:become(echo \"RUN:\$(echo {} | awk -F '│' ' {print \$3} ' | xargs)\")")

    if [[ "$selection" == "NEXT_MODE" ]]; then
        IDX=$(( (IDX + 1) % ${#MODES[@]} ))
    elif [[ "$selection" == "PREV_MODE" ]]; then
        IDX=$(( (IDX - 1 + ${#MODES[@]}) % ${#MODES[@]} ))
    elif [[ "$selection" == "RESET_FILTER" ]]; then
        SUB_FILTER="ALL"
    elif [[ "$selection" == "PICK_THEME" ]]; then
        show_theme_picker
        export ACCENT GOLD FG BLUE FZF_DEFAULT_OPTS CURRENT_THEME BAD
    elif [[ "$selection" == "TOGGLE_BG" ]]; then
        [[ "$USE_BG" == "1" ]] && USE_BG=0 || USE_BG=1
        apply_theme "$CURRENT_THEME"
        export ACCENT GOLD FG BLUE FZF_DEFAULT_OPTS USE_BG BAD
    elif [[ "$selection" == "CYCLE_PREVIEW_DIR" ]]; then
        case "$PREVIEW_POSITION" in
            bottom) PREVIEW_POSITION="right"  ;;
            right)  PREVIEW_POSITION="top"    ;;
            top)    PREVIEW_POSITION="left"   ;;
            left)   PREVIEW_POSITION="bottom" ;;
        esac
    elif [[ "$selection" == "PREVIEW_GROW" ]]; then
        _pct=${PREVIEW_SIZE%\%}
        _pct=$(( _pct + 5 ))
        [[ $_pct -gt 90 ]] && _pct=90
        PREVIEW_SIZE="${_pct}%"
    elif [[ "$selection" == "PREVIEW_SHRINK" ]]; then
        _pct=${PREVIEW_SIZE%\%}
        _pct=$(( _pct - 5 ))
        [[ $_pct -lt 10 ]] && _pct=10
        PREVIEW_SIZE="${_pct}%"
    elif [[ "$selection" == "TOGGLE_TAB" ]]; then
        if [[ "$CURRENT_MODE" == "REC" ]]; then
            [[ "$REC_TYPE" == "APP" ]] && REC_TYPE="FILE" || REC_TYPE="APP"
        elif [[ "$CURRENT_MODE" == "UPD" ]]; then
            scan_all_updates_with_progress
            show_update_list
            PENDING_UPDATES=$(find "$UPDATE_CACHE" -name "*.status" -exec grep -l "UPDATE_AVAIL" {} + 2>/dev/null | wc -l)
        elif [[ "$CURRENT_MODE" == "ALL" ]]; then
             selection=$(
                sub_idx=0
                while true; do
                    if [ $sub_idx -eq 0 ]; then
                        full_h="${BOLD}${FG}[ MAIN CATEGORIES ]${RESET} ${DIM}  SUBCATEGORIES ${RESET}"
                        list=$(get_category_view)
                    else
                        full_h="${DIM}  MAIN CATEGORIES  ${RESET}${BOLD}${FG}[ SUBCATEGORIES ]${RESET}"
                        list=$(get_subcategory_view)
                    fi
                    res=$(echo "$list" | fzf --ansi --height=99% --reverse --border \
                        --header="$full_h" --prompt="Filter by: " \
                        --bind "right:become(echo NEXT)" \
                        --bind "left:become(echo PREV)")
                    if [ "$res" = 'NEXT' ]; then
                        sub_idx=1
                    elif [ "$res" = 'PREV' ]; then
                        sub_idx=0
                    elif [ -z "$res" ]; then
                        echo "SUB:ALL"
                        break
                    else
                        clean_res=$(echo "$res" | sed 's/^[^ ]* //; s/ ([0-9]*)$//' | xargs)
                        echo "SUB:$clean_res"
                        break
                    fi
                done
             )
             if [[ "$selection" == SUB:* ]]; then
                SUB_FILTER=${selection#SUB:}
                [[ -z "$SUB_FILTER" ]] && SUB_FILTER="ALL"
             fi
        fi
    elif [[ "$selection" == SUB:* ]]; then
        SUB_FILTER=${selection#SUB:}
        [[ -z "$SUB_FILTER" ]] && SUB_FILTER="ALL"
    elif [[ "$selection" == RUN:* ]]; then
        cmd=${selection#RUN:}
        update_history "$(echo "$cmd" | awk '{print $1}')"
        break
    elif [[ -z "$selection" ]]; then
        exit 0
    fi
done

echo -e "\n▶ Launching '$cmd' via Fish..."
exec fish -c "$cmd"
