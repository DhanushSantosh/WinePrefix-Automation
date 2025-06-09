#!/bin/bash

PREFIX_BASE="$HOME/wineprefixes"
WINETRICKS_PATH="$(command -v winetricks)"
LUTRIS_DIR="$HOME/.local/share/lutris/runners/wine"

error() { zenity --error --text="$1" --title="Error"; exit 1; }

# === Zenity installation check ===
check_zenity() {
    if ! command -v zenity &>/dev/null; then
        echo "Zenity is not installed."

        read -rp "❓ Zenity is required for GUI. Install it now? (y/n): " choice
        case "$choice" in
            y|Y )
                if command -v pacman &>/dev/null; then
                    sudo pacman -S --noconfirm zenity
                elif command -v apt &>/dev/null; then
                    sudo apt update && sudo apt install -y zenity
                elif command -v dnf &>/dev/null; then
                    sudo dnf install -y zenity
                elif command -v zypper &>/dev/null; then
                    sudo zypper install -y zenity
                else
                    echo "❌ Could not detect supported package manager."
                    exit 1
                fi
                ;;
            * )
                echo "Zenity is required to run this script. Exiting."
                exit 1
                ;;
        esac
    fi
}

# === Find Wine Versions ===
find_wine_versions() {
    WINE_VERSION_OPTIONS=()

    # Lutris Versions
    if [[ -d "$LUTRIS_DIR" ]]; then
        for dir in "$LUTRIS_DIR"/*; do
            [[ -x "$dir/bin/wine" ]] || continue
            name="Lutris: $(basename "$dir")"
            WINE_VERSION_OPTIONS+=("$name" "$dir")
        done
    fi

    # System/External Versions
    SEARCH_PATHS=(
        "/opt"
        "/usr/local"
        "$HOME"
        "$HOME/apps"
        "$HOME/.wine-*"
        "$HOME/wine-*"
    )

    for base in "${SEARCH_PATHS[@]}"; do
        for dir in $base; do
            [[ -d "$dir" && -x "$dir/bin/wine" ]] || continue
            version=$("$dir/bin/wine" --version 2>/dev/null)
            [[ -z "$version" ]] && continue
            name="System: $version"
            WINE_VERSION_OPTIONS+=("$name" "$dir")
        done
    done

    # System-installed Wine in PATH
    SYS_WINE_PATH=$(command -v wine 2>/dev/null)
    if [[ -x "$SYS_WINE_PATH" ]]; then
        SYS_WINE_DIR=$(dirname "$(dirname "$SYS_WINE_PATH")")
        version=$("$SYS_WINE_PATH" --version 2>/dev/null)
        name="System: $version"
        WINE_VERSION_OPTIONS+=("$name" "$SYS_WINE_DIR")
    fi

    if [ ${#WINE_VERSION_OPTIONS[@]} -eq 0 ]; then
        error "❌ No Wine versions found."
    fi
}

# === Wine Version Picker ===
select_wine_gui() {
    find_wine_versions
    WINE_SELECTED_PATH=$(zenity --list \
        --title="Select Wine Version" \
        --width=600 --height=400 \
        --text="Select a Wine version for your prefix:" \
        --column="Version" --column="Path" \
        "${WINE_VERSION_OPTIONS[@]}" \
        --print-column=2)

    [[ -z "$WINE_SELECTED_PATH" ]] && error "No Wine version selected."
    WINE_BIN="$WINE_SELECTED_PATH/bin/wine"
    WINECFG_BIN="$WINE_SELECTED_PATH/bin/winecfg"
}

# === Ask Game Name ===
get_game_name() {
    GAME_NAME=$(zenity --entry --title="Game Name" --text="Enter game/prefix name:")
    [[ -z "$GAME_NAME" ]] && error "Game name is required."
    GAME_NAME_SAFE=$(echo "$GAME_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
    PREFIX_PATH="$PREFIX_BASE/$GAME_NAME_SAFE"
}

# === Create Wine Prefix ===
create_prefix() {
    mkdir -p "$PREFIX_PATH" || error "Failed to create prefix folder."
    zenity --info --text="Creating Wine prefix at: $PREFIX_PATH"
    WINEPREFIX="$PREFIX_PATH" "$WINECFG_BIN"
    zenity --notification --text="✅ Wine prefix created: $PREFIX_PATH"
}

# === Winetricks Option ===
run_winetricks() {
    (
        echo "33"; sleep 1
        echo "66"; sleep 1
        echo "100"; sleep 1
    ) | zenity --progress --title="Please wait..." \
        --text="Waiting 3 seconds before winetricks..." --percentage=0 --no-cancel

    zenity --question --text="Do you want to install winetricks packages?" || return

    # Check if winetricks is installed
    WINETRICKS_PATH="$(command -v winetricks)"
    if [[ -z "$WINETRICKS_PATH" ]]; then
        zenity --question --text="winetricks is not installed.\nInstall latest version locally?" || return

        mkdir -p "$HOME/.local/bin"
        git clone https://github.com/Winetricks/winetricks.git "$HOME/.local/share/winetricks-latest" || {
            error "Failed to clone winetricks repository."
        }

        ln -sf "$HOME/.local/share/winetricks-latest/src/winetricks" "$HOME/.local/bin/winetricks"
        chmod +x "$HOME/.local/bin/winetricks"
        export PATH="$HOME/.local/bin:$PATH"

        WINETRICKS_PATH="$HOME/.local/bin/winetricks"

        zenity --info --text="✅ Installed latest winetricks locally."
    fi

    # Ask user for packages
    TRICKS=$(zenity --entry \
    --title="Winetricks Packages" \
    --text="Enter packages (space-separated): d3dx9 corefonts directplay")

    [[ -n "$TRICKS" ]] && {
        zenity --info --text="Installing: $TRICKS"
        WINEPREFIX="$PREFIX_PATH" "$WINE_BIN" "$WINETRICKS_PATH" $TRICKS
    }
}

# === Run All ===
check_zenity
select_wine_gui
get_game_name
create_prefix
run_winetricks

zenity --info --text="✅ Done!\nPrefix: $PREFIX_PATH\nWine: $(basename "$WINE_SELECTED_PATH")"

