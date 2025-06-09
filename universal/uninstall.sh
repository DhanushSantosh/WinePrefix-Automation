#!/bin/bash

# 🗑️ Wine Prefix Automation - Easy Uninstaller
# Just run: bash uninstall.sh

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${RED}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║         🗑️ Wine Prefix Automation Uninstaller 🗑️             ║"
echo "║                                                              ║"
echo "║                 Safe & Easy Removal                          ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo

echo -e "${YELLOW}⚠️  This will remove Wine Prefix Automation from your system${NC}"
echo -e "${GREEN}✅ Your wine prefixes in ~/wineprefixes/ will be kept safe${NC}"
echo -e "${GREEN}✅ Only the application itself will be removed${NC}"
echo

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}❌ Please don't run this script as root!${NC}"
    echo -e "${YELLOW}Just run: ${BOLD}bash uninstall.sh${NC}"
    echo "(The script will ask for your password when needed)"
    exit 1
fi

# Check if sudo is available
if ! command -v sudo &> /dev/null; then
    echo -e "${RED}❌ sudo is required but not installed${NC}"
    echo "Please run the uninstaller manually or contact your system administrator"
    exit 1
fi

# Check if actually installed
if [[ ! -f "/usr/local/bin/wine-prefix-automation" ]]; then
    echo -e "${YELLOW}⚠️  Wine Prefix Automation doesn't appear to be installed${NC}"
    echo
    echo "Nothing to uninstall!"
    exit 0
fi

echo "🔍 Found Wine Prefix Automation installation"
echo
echo "The following will be removed:"
echo -e "  ${RED}❌${NC} /usr/local/bin/wine-prefix-automation (main program)"
echo -e "  ${RED}❌${NC} Desktop menu entry"
echo -e "  ${RED}❌${NC} Documentation files"
echo
echo -e "${GREEN}✅ Your wine prefixes will NOT be touched${NC}"
echo

read -p "Are you sure you want to uninstall Wine Prefix Automation? (y/N): " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}ℹ️  Uninstallation cancelled${NC}"
    echo "Wine Prefix Automation is still installed"
    exit 0
fi

echo
echo "🚀 Starting uninstallation..."
echo

# Run the main installer's uninstall function
if sudo bash install.sh uninstall; then
    echo
    echo -e "${GREEN}🎉 Uninstallation completed successfully!${NC}"
    echo -e "${BLUE}Wine Prefix Automation has been removed from your system${NC}"
    echo
    echo -e "${YELLOW}Your wine prefixes in ~/wineprefixes/ are still there if you need them${NC}"
else
    echo
    echo -e "${RED}❌ Uninstallation failed${NC}"
    echo "Please check the error messages above and try again"
    echo "You can also try manual removal:"
    echo -e "  ${CYAN}sudo rm /usr/local/bin/wine-prefix-automation${NC}"
    echo -e "  ${CYAN}sudo rm /usr/local/share/applications/wine-prefix-automation.desktop${NC}"
    echo -e "  ${CYAN}sudo rm /usr/local/share/icons/hicolor/48x48/apps/wine-prefix-automation.png${NC}"
    echo -e "  ${CYAN}sudo rm -rf /usr/local/share/doc/wine-prefix-automation${NC}"
    exit 1
fi

