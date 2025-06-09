#!/bin/bash

# 🍷 Wine Prefix Automation - Universal Installer
# Easy installation for all Linux distributions

set -e

SCRIPT_NAME="wine-prefix-automation"
INSTALL_DIR="/usr/local/bin"
DESKTOP_DIR="/usr/local/share/applications"
DOC_DIR="/usr/local/share/doc/wine-prefix-automation"
ICON_DIR="/usr/local/share/icons/hicolor/48x48/apps"
VERSION="1.0.0"

# Enhanced colors and formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Emojis for better visual feedback
CHECK="✅"
CROSS="❌"
INFO="ℹ️"
WARN="⚠️"
ROCKET="🚀"
WINE="🍷"
GEAR="⚙️"

print_header() {
    clear
    echo -e "${BOLD}${MAGENTA}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║           🍷 Wine Prefix Automation Installer 🍷             ║"
    echo "║                                                              ║"
    echo "║     Easy Wine prefix creation and management tool            ║"
    echo "║                    Version $VERSION                          ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo
}

print_status() {
    echo -e "${BLUE}${INFO} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK} ${BOLD}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARN} ${BOLD}$1${NC}"
}

print_error() {
    echo -e "${RED}${CROSS} ${BOLD}$1${NC}"
}

print_step() {
    echo -e "${CYAN}${GEAR} ${BOLD}Step $1:${NC} $2"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run with administrator privileges"
        echo
        echo -e "${YELLOW}Please run: ${BOLD}sudo bash install.sh${NC}"
        echo
        exit 1
    fi
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        DISTRO="$ID"
        DISTRO_NAME="$NAME"
        VERSION_ID="$VERSION_ID"
    elif [[ -f /etc/redhat-release ]]; then
        DISTRO="rhel"
        DISTRO_NAME="Red Hat Enterprise Linux"
    elif [[ -f /etc/debian_version ]]; then
        DISTRO="debian"
        DISTRO_NAME="Debian"
    else
        DISTRO="unknown"
        DISTRO_NAME="Unknown Linux"
    fi
}

get_package_manager() {
    case "$DISTRO" in
        "arch"|"manjaro"|"endeavouros")
            PKG_MANAGER="pacman"
            PKG_INSTALL="pacman -S --noconfirm"
            PKG_UPDATE="pacman -Sy"
            ;;
        "ubuntu"|"debian"|"linuxmint"|"pop"|"elementary")
            PKG_MANAGER="apt"
            PKG_INSTALL="apt install -y"
            PKG_UPDATE="apt update"
            ;;
        "fedora"|"rhel"|"centos"|"rocky"|"almalinux")
            PKG_MANAGER="dnf"
            PKG_INSTALL="dnf install -y"
            PKG_UPDATE="dnf check-update || true"
            ;;
        "opensuse"|"opensuse-leap"|"opensuse-tumbleweed")
            PKG_MANAGER="zypper"
            PKG_INSTALL="zypper install -y"
            PKG_UPDATE="zypper refresh"
            ;;
        *)
            PKG_MANAGER="unknown"
            ;;
    esac
}

welcome_screen() {
    print_header
    echo -e "Welcome to the ${BOLD}Wine Prefix Automation${NC} installer!"
    echo
    echo "This tool will help you:"
    echo -e "  ${CHECK} Create and manage Wine prefixes easily"
    echo -e "  ${CHECK} Automatically detect Wine versions"
    echo -e "  ${CHECK} Install Windows components with winetricks"
    echo -e "  ${CHECK} Organize your Windows applications"
    echo
    echo -e "${BOLD}Detected System:${NC} $DISTRO_NAME"
    echo -e "${BOLD}Package Manager:${NC} $PKG_MANAGER"
    echo
    
    read -p "Press Enter to continue with installation, or Ctrl+C to cancel..."
    echo
}

check_and_install_dependencies() {
    print_step "1" "Checking system dependencies"
    
    local missing_deps=()
    local available_deps=()
    
    # Check each dependency
    deps=("wine" "zenity" "git")
    for dep in "${deps[@]}"; do
        if command -v "$dep" &> /dev/null; then
            available_deps+=("$dep")
            echo -e "  ${CHECK} $dep - installed"
        else
            missing_deps+=("$dep")
            echo -e "  ${CROSS} $dep - missing"
        fi
    done
    
    echo
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        print_success "All dependencies are already installed!"
        return 0
    fi
    
    print_warning "Missing dependencies: ${missing_deps[*]}"
    echo
    
    if [[ "$PKG_MANAGER" == "unknown" ]]; then
        print_error "Cannot auto-install dependencies - unknown package manager"
        echo -e "${YELLOW}Please manually install: ${missing_deps[*]}${NC}"
        echo
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
        return 1
    fi
    
    echo -e "I can automatically install missing dependencies using ${BOLD}$PKG_MANAGER${NC}"
    echo -e "Command: ${CYAN}sudo $PKG_INSTALL ${missing_deps[*]}${NC}"
    echo
    
    read -p "Install missing dependencies automatically? (Y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        print_warning "Skipping dependency installation"
        echo -e "${YELLOW}You'll need to install these manually:${NC}"
        case "$PKG_MANAGER" in
            "pacman") echo -e "  ${BOLD}sudo pacman -S ${missing_deps[*]}${NC}" ;;
            "apt") echo -e "  ${BOLD}sudo apt install ${missing_deps[*]}${NC}" ;;
            "dnf") echo -e "  ${BOLD}sudo dnf install ${missing_deps[*]}${NC}" ;;
            "zypper") echo -e "  ${BOLD}sudo zypper install ${missing_deps[*]}${NC}" ;;
        esac
        echo
        read -p "Continue with installation anyway? (y/N): " -n 1 -r
        echo
        [[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
        return 1
    fi
    
    print_status "Installing dependencies..."
    
    # Update package database
    echo -e "${CYAN}Updating package database...${NC}"
    if ! eval "$PKG_UPDATE"; then
        print_warning "Failed to update package database, continuing anyway..."
    fi
    
    # Install missing packages
    echo -e "${CYAN}Installing: ${missing_deps[*]}...${NC}"
    if eval "$PKG_INSTALL ${missing_deps[*]}"; then
        print_success "Dependencies installed successfully!"
        echo
        
        # Verify installation
        print_status "Verifying installation..."
        local failed_deps=()
        for dep in "${missing_deps[@]}"; do
            if command -v "$dep" &> /dev/null; then
                echo -e "  ${CHECK} $dep - now available"
            else
                echo -e "  ${CROSS} $dep - still missing"
                failed_deps+=("$dep")
            fi
        done
        
        if [ ${#failed_deps[@]} -ne 0 ]; then
            print_error "Some dependencies failed to install: ${failed_deps[*]}"
            return 1
        fi
    else
        print_error "Failed to install dependencies"
        return 1
    fi
    
    echo
    return 0
}

install_application() {
    print_step "2" "Installing Wine Prefix Automation"
    
    # Create directories with proper permissions
    echo -e "${CYAN}Creating installation directories...${NC}"
    mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" "$DOC_DIR" "$ICON_DIR"
    
    # Install main script
    echo -e "${CYAN}Installing main script...${NC}"
    if cp "src/wine-prefix-automation.sh" "$INSTALL_DIR/$SCRIPT_NAME" && chmod +x "$INSTALL_DIR/$SCRIPT_NAME"; then
        echo -e "  ${CHECK} Script installed to $INSTALL_DIR/$SCRIPT_NAME"
    else
        print_error "Failed to install main script"
        exit 1
    fi
    
    # Install desktop entry
    echo -e "${CYAN}Installing desktop integration...${NC}"
    if cp "src/wine-prefix-automation.desktop" "$DESKTOP_DIR/"; then
        echo -e "  ${CHECK} Desktop entry installed"
    else
        print_warning "Failed to install desktop entry"
    fi
    
    # Install icon
    echo -e "${CYAN}Installing application icon...${NC}"
    if cp "src/icon.png" "$ICON_DIR/wine-prefix-automation.png"; then
        echo -e "  ${CHECK} Icon installed"
    else
        print_warning "Failed to install icon"
    fi
    
    # Update desktop database if possible
    if command -v update-desktop-database &> /dev/null; then
        echo -e "${CYAN}Updating desktop database...${NC}"
        update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
        echo -e "  ${CHECK} Desktop database updated"
    fi
    
    echo
    print_success "Wine Prefix Automation installed successfully!"
}

uninstall_application() {
    print_header
    echo -e "${BOLD}${RED}Uninstalling Wine Prefix Automation${NC}"
    echo
    
    # Check if installed
    if [[ ! -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        print_warning "Wine Prefix Automation doesn't appear to be installed"
        echo
        exit 0
    fi
    
    echo "This will remove:"
    echo -e "  ${CROSS} Main script: $INSTALL_DIR/$SCRIPT_NAME"
    echo -e "  ${CROSS} Desktop entry: $DESKTOP_DIR/wine-prefix-automation.desktop"
    echo -e "  ${CROSS} Application icon: $ICON_DIR/wine-prefix-automation.png"
    echo
    echo -e "${YELLOW}Note: Your wine prefixes in ~/wineprefixes/ will NOT be removed${NC}"
    echo
    
    read -p "Are you sure you want to uninstall? (y/N): " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Uninstallation cancelled"
        exit 0
    fi
    
    echo
    print_status "Removing Wine Prefix Automation..."
    
    # Remove files
    rm -f "$INSTALL_DIR/$SCRIPT_NAME" && echo -e "  ${CHECK} Removed main script"
    rm -f "$DESKTOP_DIR/wine-prefix-automation.desktop" && echo -e "  ${CHECK} Removed desktop entry"
    rm -f "$ICON_DIR/wine-prefix-automation.png" && echo -e "  ${CHECK} Removed application icon"
    rm -rf "$DOC_DIR" && echo -e "  ${CHECK} Removed documentation"
    
    # Update desktop database
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
        echo -e "  ${CHECK} Updated desktop database"
    fi
    
    echo
    print_success "Wine Prefix Automation has been completely removed"
    echo -e "${CYAN}Thank you for using Wine Prefix Automation!${NC}"
    echo
}

post_install_info() {
    print_header
    echo -e "${BOLD}${GREEN}🎉 Installation Complete! 🎉${NC}"
    echo
    echo -e "${BOLD}Wine Prefix Automation${NC} is now ready to use!"
    echo
    echo -e "${BOLD}How to run:${NC}"
    echo -e "  ${ROCKET} Command line: ${CYAN}wine-prefix-automation${NC}"
    echo -e "  ${ROCKET} GUI: Find ${BOLD}'Wine Prefix Automation'${NC} in your applications menu"
    echo -e "  ${ROCKET} Category: System → Utilities"
    echo
    echo -e "${BOLD}What it does:${NC}"
    echo -e "  ${WINE} Creates organized Wine prefixes in ${CYAN}~/wineprefixes/${NC}"
    echo -e "  ${GEAR} Automatically detects Wine versions (system, Lutris, etc.)"
    echo -e "  ${CHECK} Installs Windows components via winetricks"
    echo -e "  ${INFO} Provides easy GUI for Wine configuration"
    echo
    echo -e "${BOLD}Quick start:${NC}"
    echo -e "  1. Run: ${CYAN}wine-prefix-automation${NC}"
    echo -e "  2. Select your Wine version"
    echo -e "  3. Enter a name for your application/game"
    echo -e "  4. Configure Wine settings"
    echo -e "  5. Optionally install Windows components"
    echo
    echo -e "${BOLD}Enjoy using Wine Prefix Automation! 🍷${NC}"
    echo
    
    read -p "Press Enter to exit..."
}

show_help() {
    print_header
    echo -e "${BOLD}Wine Prefix Automation - Universal Installer${NC}"
    echo
    echo -e "${BOLD}Usage:${NC}"
    echo -e "  ${CYAN}sudo bash install.sh${NC} [OPTION]"
    echo
    echo -e "${BOLD}Options:${NC}"
    echo -e "  ${GREEN}install${NC}     Install Wine Prefix Automation (default)"
    echo -e "  ${RED}uninstall${NC}   Remove Wine Prefix Automation"
    echo -e "  ${BLUE}help${NC}        Show this help message"
    echo
    echo -e "${BOLD}Examples:${NC}"
    echo -e "  ${CYAN}sudo bash install.sh${NC}           # Install with auto-dependency handling"
    echo -e "  ${CYAN}sudo bash install.sh install${NC}    # Same as above"
    echo -e "  ${CYAN}sudo bash install.sh uninstall${NC}  # Remove the application"
    echo
    echo -e "${BOLD}Requirements:${NC}"
    echo -e "  ${CHECK} Linux distribution with package manager (pacman, apt, dnf, zypper)"
    echo -e "  ${CHECK} Administrator privileges (sudo)"
    echo -e "  ${CHECK} Internet connection (for dependency installation)"
    echo
    echo -e "${BOLD}Supported Distributions:${NC}"
    echo -e "  ${CHECK} Arch Linux, Manjaro, EndeavourOS"
    echo -e "  ${CHECK} Ubuntu, Debian, Linux Mint, Pop!_OS"
    echo -e "  ${CHECK} Fedora, RHEL, CentOS, Rocky Linux"
    echo -e "  ${CHECK} openSUSE Leap, openSUSE Tumbleweed"
    echo
}

# Main installation logic
main_install() {
    check_root
    detect_distro
    get_package_manager
    welcome_screen
    
    if check_and_install_dependencies; then
        install_application
        post_install_info
    else
        echo
        print_warning "Installation completed with warnings"
        echo -e "${YELLOW}Some dependencies may be missing. The application might not work correctly.${NC}"
        echo
        read -p "Press Enter to continue..."
    fi
}

# Main logic
case "${1:-install}" in
    install)
        main_install
        ;;
    uninstall)
        check_root
        uninstall_application
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_header
        print_error "Unknown option: $1"
        echo
        show_help
        exit 1
        ;;
esac

