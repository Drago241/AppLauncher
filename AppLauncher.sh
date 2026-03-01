#!/usr/bin/env bash

FISH_FUNCTIONS_DIR="$HOME/.config/fish/functions"
FAVORITES_FILE="$HOME/.config/fish/launcher_favorites.txt"
HISTORY_FILE="$HOME/.config/fish/launcher_history.txt"
UPDATE_CACHE="/tmp/launcher_update_cache"
GITHUB_TOKEN="<...>"

touch "$FAVORITES_FILE" "$HISTORY_FILE"
mkdir -p "$UPDATE_CACHE"

GUI_EDITOR="nemo"
PREVIEW_POSITION="bottom"
PREVIEW_SIZE="70%"
PIPE=" │ "
POINTER=""

RESET=$(tput sgr0); BOLD=$(tput bold); DIM=$(tput dim)
FG=$(tput setaf 7); ACCENT=$(tput setaf 4); GOLD=$(tput setaf 3)
BLUE=$(tput setaf 4); GREEN=$(tput setaf 2); YELLOW=$(tput setaf 3); RED=$(tput setaf 1)

export FZF_DEFAULT_OPTS="
--color=fg:7,bg:0,hl:4
--color=fg+:7,bg+:8,hl+:4
--color=info:4,prompt:4,pointer:4,spinner:4
#--pointer='$POINTER' --marker='➲ '
"

declare -A ALIASES=(
    ["anydesk"]="AnyDesk" ["applauncher"]="Application Launcher (TUI)" ["appimageupdate"]="AppImageUpdater" ["boxes"]="GNOME Boxes" ["browser"]="Browser TUI" ["crt"]="Cool Retro Term" ["cull"]="Cull" ["couik"]="Couik" ["dolphin-emu"]="Dolphin Emulator" ["duckstation"]="DuckStation" ["eden"]="Eden Emulator" ["fresh"]="Fresh Editor" ["ghostty"]="Ghostty Terminal" ["kando-appimage"]="Kando" ["localsend"]="LocalSend" ["melonds"]="MelonDS" ["mgba"]="mGBA" ["onlyoffice"]="ONLYOFFICE" ["opera-browser"]="Opera Browser" ["polybar-appimage"]="Polybar" ["ppsspp"]="PPSSPP" ["ryujinx"]="Ryujinx" ["stacer"]="Stacer" ["tanuki3ds"]="Tanuki3DS" ["valvefm"]="ValveFM" ["walc"]="WALC" ["warp"]="Warp Terminal" ["waveterm"]="Wave Terminal" ["wezterm"]="WezTerm" ["wps-office"]="WPS Office" ["youtube-music"]="YouTube Music" ["zen-browser"]="Zen Browser" ["ani-cli"]="Ani CLI" ["autotile"]="AutoTile" ["bash2048"]="2048" ["bashventure"]="Bashventure" ["brogue"]="Brogue CE" ["bookokrat"]="Bookokrat" ["demitile"]="Demitile" ["minesweeper"]="Minesweeper" ["rovr"]="ROVR" ["rondo"]="Rondo" ["shtris"]="Shtris" ["snake"]="Snake (ascii)" ["snake-main"]="Snake" ["surge"]="Surge" ["termclock"]="TermClock" ["tetris"]="Tetris" ["astroterm"]="AstroTerm" ["bluetuith"]="Bluetuith" ["bt"]="Better Tree File Manager" ["carbonyl"]="Carbonyl" ["chess-tui"]="Chess TUI" ["clidle"]="Clidle (wordle)" ["clipse"]="Clipse (clipboard)" ["cloudflare-speed-cli"]="Cloudflare Speed Test CLI" ["cortile"]="Cortile" ["crunchycleaner"]="CrunchyCleaner" ["deletor"]="Deletor" ["dawn"]="Dawn" ["diskonaut"]="Diskonaut" ["dooit"]="Dooit" ["doxx"]="Doxx:Document Viewer" ["draw"]="Draw" ["dua"]="Disk Usage Analyzer (dua)" ["duf"]="Disk Usage/Free Utility (duf)" ["edex-ui"]="eDEX-UI" ["eilmeldung"]="TUI RSS Reader" ["fastfetch"]="Fastfetch" ["gambit"]="Gambit" ["gdu"]="Go Disk Usage (gdu)" ["glow"]="Glow Markdown Viewer" ["goful"]="Goful" ["gopher64"]="Gopher64" ["helm"]="Helm" ["hazelnut"]="Hazelnut" ["hazelnutd"]="Hazelnut Deamon" ["hydrotodo"]="HydroTodo" ["image2term"]="Image2Term" ["jif"]="Jif" ["jolt"]="Jolt" ["kbt"]="Keyboard Tester" ["kitty"]="Kitty Terminal" ["kitten"]="Kitten (plug-ins)" ["launchers-cinnamon"]="Launchers (Cinnamon)" ["launchers-folder"]="Launchers Folder" ["launchers-xfce"]="Launchers (XFCE)" ["mcdu"]="MCDU" ["nnn-emoji"]="nnn File Manager (emoji plugin)" ["occt"]="OCCT" ["omm"]="OMM" ["outside"]="Outside" ["pass-cli"]="Pass CLI" ["pomo"]="Pomo Timer" ["portal"]="Portal" ["pixel-index"]="Pixel Index" ["sampler"]="Sampler" ["smassh"]="Smassh" ["sonicradio"]="Sonic Radio" ["sudoku"]="Sudoku" ["spf"]="Super File Manager" ["tt"]="Task Timer" ["taskwire"]="Taskwire" ["termeverything"]="TermEverything" ["termusic"]="Termusic" ["tetro"]="Tetro" ["tetrigo"]="Tetrigo" ["termusic-server"]="Termusic Server" ["todo-linux"]="Todo Linux" ["tran"]="Tran" ["ttyper"]="TTYper" ["ttyd"]="TTYD" ["tjournal"]="TUI-Journal" ["tuime"]="Tuime" ["tuios"]="TUI OS" ["typioca"]="Typioca" ["typtea"]="Typtea" ["viu"]="VIU Media (anime)" ["weathr"]="Weather TUI" ["wifi-tui"]="WiFi TUI" ["wiki-tui"]="Wiki TUI" ["wiper"]="Wiper" ["wtfutil"]="WTF" ["xleak"]="XLeak:Sheet Viewer" ["xfce4-night-mode"]="XFCE4 Theme Switcher" ["xytz"]="XYTZ" ["xplr"]="Xplr File Manager" ["yazi"]="Yazi File Manager" ["yt-x"]="YT-X" ["youtube-tui"]="YouTube TUI" ["zellij"]="Zellij" ["zentile"]="Zentile")

APPIMAGES=("anydesk" "appimageupdate" "boxes" "crt" "dolphin-emu" "duckstation" "eden" "ghostty" "kando-appimage" "localsend" "melonds" "mgba" "onlyoffice" "opera-browser" "polybar-appimage" "ppsspp" "ryujinx" "stacer" "tanuki3ds" "walc" "warp" "waveterm" "wezterm" "wps-office" "youtube-music" "zen-browser" "edex-ui")
SCRIPTS=("ani-cli" "autotile" "bash2048" "bashventure" "brogue" "demitile" "minesweeper" "shtris" "snake" "snake-main" "termclock" "tetris" "image2term" "launchers-folder" "launchers-cinnamon" "launchers-xfce")
LINUX_EXECUTABLES=("astroterm" "bluetuith" "bt" "carbonyl" "chess-tui" "clidle" "clipse" "cloudflare-speed-cli" "cortile" "crunchycleaner" "deletor" "diskonaut" "dooit" "doxx" "draw" "dua" "duf" "fastfetch" "gambit" "gdu" "glow" "goful" "gopher64" "helm" "hydrotodo" "jif" "jolt" "kbt" "nnn-emoji" "occt" "omm" "outside" "pass-cli" "pomo" "portal" "sampler" "smassh" "sonicradio" "sudoku" "spf" "tt" "taskwire" "termeverything" "termusic" "termusic-server" "todo-linux" "tran" "ttyper" "ttyd" "tjournal" "tuime" "tuios" "typioca" "typtea" "viu" "wifi-tui" "wiki-tui" "wiper" "wtfutil" "xleak" "xplr" "yazi" "youtube-tui" "zellij" "zentile" "kitty" "kitten" "eilmeldung" "weathr" "valvefm" "couik" "browser" "pixel-index" "xytz" "rovr" "tetro" "cull" "fresh" "hazelnut" "hazelnutd" "surge" "yt-x" "bookokrat" "dawn" "rondo" "xfce4-night-mode" "tetrigo" "mcdu")

EMULATION=("boxes" "dolphin-emu" "duckstation" "eden" "gopher64" "melonds" "mgba" "ppsspp" "ryujinx" "tanuki3ds")
GAMES=("bash2048" "bashventure" "brogue" "chess-tui" "clidle" "gambit" "minesweeper" "shtris" "snake" "snake-main" "sudoku" "tetris" "tetro" "tetrigo")
FILE_MANAGERS=("goful" "yazi" "nnn-emoji" "spf" "xplr" "bt" "rovr" "hazelnut" "hazelnutd" "mcdu")
DISKSPACE_VISUALIZERS=("dua" "duf" "diskonaut" "gdu" "cull")
FILE_TRANSFER=("portal" "tran" "localsend")
FILE_VIEWERS=("glow" "xleak" "doxx" "jif" "bookokrat")
MEDIA=("carbonyl" "termeverything" "sonicradio" "termusic" "valvefm" "termusic-server" "youtube-tui" "viu" "ani-cli" "youtube-music" "browser" "pixel-index" "xytz" "yt-x")
MULTIPLEXERS=("cortile" "tuios" "zentile" "zellij" "demitile" "autotile")
SYSTEM_CLEANERS=("crunchycleaner" "deletor" "wiper")
SYSTEMTOOLS_AND_INFORMATION=("fastfetch" "pass-cli" "sampler" "wifi-tui" "wtfutil" "bluetuith" "clipse" "cloudflare-speed-cli" "jolt" "kbt" "occt" "taskwire" "stacer")
TIMERS_AND_CLOCKS=("pomo" "helm" "tuime" "termclock")
TODO_LISTS=("omm" "hydrotodo" "dooit" "tjournal" "todo-linux" "tt" "dawn" "rondo")
TYPINGSPEED_TESTS=("typtea" "smassh" "ttyper" "typioca" "couik")
TERMINALS=("crt" "ghostty" "warp" "waveterm" "wezterm" "kitty" "edex-ui")
WEB_BROWSERS=("opera-browser" "zen-browser")
OFFICE_SUITES=("onlyoffice" "wps-office")
LAUNCHERS=("" "" "" "")
MISCELLANEOUS=("anydesk" "appimageupdate" "kando-appimage" "polybar-appimage" "walc" "draw" "astroterm" "wiki-tui" "ttyd" "kitten" "image2term" "launchers-folder" "launchers-cinnamon" "launchers-xfce" "eilmeldung" "weathr" "outside" "fresh" "surge" "xfce4-night-mode")

ARRAY_DEFS=$(declare -p APPIMAGES SCRIPTS LINUX_EXECUTABLES EMULATION GAMES FILE_MANAGERS DISKSPACE_VISUALIZERS FILE_TRANSFER FILE_VIEWERS MEDIA MULTIPLEXERS SYSTEM_CLEANERS SYSTEMTOOLS_AND_INFORMATION TIMERS_AND_CLOCKS TODO_LISTS TYPINGSPEED_TESTS TERMINALS WEB_BROWSERS OFFICE_SUITES MISCELLANEOUS)

in_group() {
    local name="$1"; shift
    local group=("$@")
    for item in "${group[@]}"; do [[ "$item" == "$name" ]] && return 0; done
    return 1
}

category_of() {
    local name="$1"
    if in_group "$name" "${APPIMAGES[@]}"; then echo "AppImages"
    elif in_group "$name" "${SCRIPTS[@]}"; then echo "Scripts"
    elif in_group "$name" "${LINUX_EXECUTABLES[@]}"; then echo "Linux Executables"
    else echo "Other"; fi
}

subcategory_of() {
    local name="$1"
    if in_group "$name" "${EMULATION[@]}"; then echo "Emulation"
    elif in_group "$name" "${GAMES[@]}"; then echo "Games"
    elif in_group "$name" "${FILE_MANAGERS[@]}"; then echo "File Managers"
    elif in_group "$name" "${DISKSPACE_VISUALIZERS[@]}"; then echo "Disk-Space Visualizers"
    elif in_group "$name" "${FILE_TRANSFER[@]}"; then echo "File Transfer"
    elif in_group "$name" "${FILE_VIEWERS[@]}"; then echo "File Viewer"
    elif in_group "$name" "${MEDIA[@]}"; then echo "Media"
    elif in_group "$name" "${MISCELLANEOUS[@]}"; then echo "Miscellaneous"
    elif in_group "$name" "${MULTIPLEXERS[@]}"; then echo "Multiplexers"
    elif in_group "$name" "${SYSTEM_CLEANERS[@]}"; then echo "System Cleaners"
    elif in_group "$name" "${SYSTEMTOOLS_AND_INFORMATION[@]}"; then echo "System Tools & Information"
    elif in_group "$name" "${TIMERS_AND_CLOCKS[@]}"; then echo "Timers & Clocks"
    elif in_group "$name" "${TODO_LISTS[@]}"; then echo "ToDo Lists"
    elif in_group "$name" "${TYPINGSPEED_TESTS[@]}"; then echo "Typing-Speed Tests"
    elif in_group "$name" "${TERMINALS[@]}"; then echo "Terminals"
    elif in_group "$name" "${WEB_BROWSERS[@]}"; then echo "Web Browsers"
    elif in_group "$name" "${OFFICE_SUITES[@]}"; then echo "Office Suites"
    elif in_group "$name" "${LAUNCHERS[@]}"; then echo "Launchers"
    else echo "General"; fi
}

display_name_of() { [[ -n "${ALIASES[$1]}" ]] && echo "${ALIASES[$1]}" || echo "$1"; }
is_fav() { grep -q "^$1$" "$FAVORITES_FILE"; }

str_repeat() {
    local char="$1"
    local count="$2"
    [[ "$count" -gt 0 ]] && printf "%${count}s" | tr ' ' "$char"
}

get_status_label() {
    local link="$1"
    local remote_ver="$2"
    local status_raw="$3"
    
    if [[ "$status_raw" == "UPDATE_AVAIL" ]]; then
        echo "${BOLD}${YELLOW}󱄋 Update Available!${RESET}"
    elif [[ "$link" == *"github.com"* && "$remote_ver" == "N/A" && "$status_raw" != "PENDING" ]]; then
        echo "${DIM}󰜺 No Release Found${RESET}"
    elif [[ "$status_raw" == "UPDATED" ]]; then
        echo "${BOLD}${GREEN}󰄬 Up to Date${RESET}"
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
        
        local hashes_str=$(str_repeat '#' "$hashes")
        local spaces_str=$(str_repeat ' ' "$spaces")
        
        printf "\r\033[K${ACCENT}${BOLD}Progress:${RESET} [%s${RESET}%s] %3d%% (%d/%d)" "$hashes_str" "$spaces_str" "$percent" "$completed" "$total"
            
        if [[ "$completed" -ge "$total" ]]; then break; fi
        sleep 0.1
    done
    printf "\n"
    rm -rf "$temp_dir"
}

get_category_view() {
    eval "$ARRAY_DEFS"
    local all_files=$(find "$FISH_FUNCTIONS_DIR" -maxdepth 1 -type f -name "*.fish" -exec basename {} .fish \;)
    local other_count=0
    for f in $all_files; do [[ $(category_of "$f") == "Other" ]] && ((other_count++)); done
    printf "󰗈 %-30s (%d)\n" "AppImages" "${#APPIMAGES[@]}"
    printf "󰈙 %-30s (%d)\n" "Scripts" "${#SCRIPTS[@]}"
    printf "󰆍 %-30s (%d)\n" "Linux Executables" "${#LINUX_EXECUTABLES[@]}"
    printf "󰚗 %-30s (%d)\n" "Other" "$other_count"
}

get_subcategory_view() {
    eval "$ARRAY_DEFS"
    local all_files=$(find "$FISH_FUNCTIONS_DIR" -maxdepth 1 -type f -name "*.fish" -exec basename {} .fish \;)
    local general_count=0
    for f in $all_files; do [[ $(subcategory_of "$f") == "General" ]] && ((general_count++)); done
    local sub_cats=(
        "|Disk-Space Visualizers|DISKSPACE_VISUALIZERS" "󰘚|Emulation|EMULATION"
        "|File Managers|FILE_MANAGERS" "󰇚|File Transfer|FILE_TRANSFER"
        "|File Viewer|FILE_VIEWERS" "󱎓|Games|GAMES" "|Media|MEDIA"
        "|Miscellaneous|MISCELLANEOUS" "󰖯|Multiplexers|MULTIPLEXERS"
        "󰃢|System Cleaners|SYSTEM_CLEANERS" "󰒓|System Tools & Information|SYSTEMTOOLS_AND_INFORMATION"
        "󰥔|Timers & Clocks|TIMERS_AND_CLOCKS" "󰏫|ToDo Lists|TODO_LISTS"
        "󰌌|Typing-Speed Tests|TYPINGSPEED_TESTS" "󰞷|Terminals|TERMINALS"
        "󰖟|Web Browsers|WEB_BROWSERS" "󰏆|Office Suites|OFFICE_SUITES"
    )
    for entry in "${sub_cats[@]}"; do
        IFS="|" read -r icon name var <<< "$entry"
        local -n current_arr=$var
        printf "%s %-30s (%d)\n" "$icon" "$name" "${#current_arr[@]}"
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
                
                status=$(get_status_label "$link" "$remote_ver" "$status_raw")
                
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

export -f in_group category_of subcategory_of display_name_of is_fav get_category_view get_subcategory_view get_status_label check_update show_update_list scan_all_updates_with_progress str_repeat
export FISH_FUNCTIONS_DIR FAVORITES_FILE HISTORY_FILE PIPE RESET BOLD DIM ACCENT GOLD GITHUB_TOKEN BLUE GREEN YELLOW RED UPDATE_CACHE APPIMAGES SCRIPTS LINUX_EXECUTABLES EMULATION GAMES FILE_MANAGERS DISKSPACE_VISUALIZERS FILE_TRANSFER FILE_VIEWERS MEDIA MULTIPLEXERS SYSTEM_CLEANERS SYSTEMTOOLS_AND_INFORMATION TIMERS_AND_CLOCKS TODO_LISTS TYPINGSPEED_TESTS TERMINALS WEB_BROWSERS OFFICE_SUITES LAUNCHERS MISCELLANEOUS FG GUI_EDITOR ARRAY_DEFS

HELP_TEXT="
  ${BOLD}${ACCENT}── LAUNCHER HELP ───────────────────────────${RESET} 

  ${BOLD}CORE COMMANDS${RESET}
  ${ACCENT}Enter${RESET}           Launch selected application
  ${ACCENT}Alt/Ctrl + a${RESET}    Launch with custom arguments
  ${ACCENT}Ctrl + f${RESET}        Toggle Favorite (★)
  ${ACCENT}Ctrl + e${RESET}        Edit fish function file
  ${ACCENT}Ctrl + h${RESET}        Toggle app-specific help (Preview)
  ${ACCENT}q${RESET}               Exit help (.fish help)
  ${ACCENT}Tab on Recent${RESET}   Toggle Recent (󰄉 Apps vs 󰁫 Files)
  ${ACCENT}Tab on All${RESET}      Switch Category (All)
  ${ACCENT}Tab on Updates${RESET}  Open Update List Summary
  ${ACCENT}Ctrl + c${RESET}        Back / Exit
  ${ACCENT}Ctrl + r${RESET}        Reset Filters / Application
  ${ACCENT}Ctrl + /${RESET}        Show this help menu

  ${BOLD}NAVIGATION${RESET}
  ${ACCENT}Ctrl + n/p${RESET}      Move Down / Move Up
  ${ACCENT}Esc / ^c${RESET}        Quit Launcher
  ${ACCENT}Left/Right${RESET}      Switch Tabs (All / Recent / Favs / Updates)
  
  ${BOLD}INFO${RESET}
  Category and Subcategory data is parsed from 
  the script internal logic groups.
  ${ACCENT}────────────────────────────────────────────${RESET}
"

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
            update_icon="${YELLOW}󱄋${RESET}"
        fi
        
        printf " %s %s %3d ${PIPE}%-*s${PIPE}%-*s${PIPE}${DIM}%-*s${RESET}${PIPE}${DIM}%-*s${RESET}\n" \
          "$fav_mark" "$update_icon" "$counter" "$W_APP" "$app" "$W_CMD" "$fn" "$W_CAT" "$cat" "$W_SUB" "$sub"
        ((counter++))
    done
}
export -f build_menu

update_history() {
    local cmd_name="$1"
    (echo "$cmd_name"; grep -v "^$cmd_name$" "$HISTORY_FILE") | head -n 10 > "$HISTORY_FILE.tmp"
    mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}

MODES=("ALL" "REC" "FAV" "UPD")
TAB_NAMES=(" 󰄬 ALL " " 󰄉 RECENT " " 󰓏 FAVORITES " " 󰚰 UPDATES ")
IDX=0
SUB_FILTER="ALL"
REC_TYPE="APP" 

rm -f /tmp/launcher_help

PENDING_UPDATES=$(find "$UPDATE_CACHE" -name "*.status" -exec grep -l "UPDATE_AVAIL" {} + 2>/dev/null | wc -l)

while true; do
    rm -f /tmp/launcher_help
    
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
    PREVIEW_CMD='
        real_fn=$(echo {} | awk -F "│" "{print \$3}" | xargs)
        
        if [[ -f "/tmp/launcher_help" ]]; then
            echo -e "'$BOLD$ACCENT' 󰋖 Help for $real_fn'$RESET'\n"
            fish -c "if type $real_fn >/dev/null 2>&1; $real_fn -h || $real_fn --help; else echo \"'$DIM'No help text found.'$RESET'\"; end"
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
            
            status_text=$(get_status_label "$link" "$remote_ver" "$status_raw")
            
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
    '

    selection=$(build_menu "$CURRENT_MODE" "$SUB_FILTER" "$REC_TYPE" | fzf \
        --ansi \
        --header="$HEADER_BAR"$'\n'"$COLUMN_HEADER" \
        --prompt="󰍉 Search: " \
        --reverse --border --height=100% \
        --preview-window="$WIN_OPTS" \
        --preview "$PREVIEW_CMD" \
        --bind "right:become(echo 'NEXT_MODE')" \
        --bind "left:become(echo 'PREV_MODE')" \
        --bind "tab:become(echo 'TOGGLE_TAB')" \
        --bind "ctrl-r:become(echo 'RESET_FILTER')" \
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
