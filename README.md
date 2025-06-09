# 🍷 Wine Prefix Automation

> A user-friendly GUI tool for creating and managing Wine prefixes with ease.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.linux.org/)
[![Made with: Bash](https://img.shields.io/badge/Made%20with-Bash-green.svg)](https://www.gnu.org/software/bash/)

## 📖 Overview

Wine Prefix Automation simplifies the process of creating and managing Wine prefixes through an intuitive graphical interface. Perfect for gamers and users who need to run Windows applications on Linux.

### ✨ Key Features

- 🖥️ **User-Friendly GUI**: Simple, intuitive Zenity-based interface
- 🎮 **Smart Wine Detection**: Automatically finds system Wine, Lutris, and custom installations
- 🔧 **Winetricks Integration**: Built-in winetricks management
- 📁 **Organized Prefixes**: Clean prefix management in `~/wineprefixes/`
- 🐧 **Cross-Distribution**: Works on all major Linux distributions

## 🚀 Installation

### Arch Linux (Recommended for Arch-based systems)

```bash
# Clone the repository
git clone https://github.com/DhanushSantosh/WinePrefix-Automation.git
cd WinePrefix-Automation/archlinux

# Build and install the package
makepkg -si
```

### Universal Installation (Other Distributions)

```bash
# Clone the repository
git clone https://github.com/DhanushSantosh/WinePrefix-Automation.git
cd WinePrefix-Automation/universal

# Show all installation options
sudo bash install.sh --help

# Basic installation
sudo bash install.sh

# Available options:
#   install     Install Wine Prefix Automation (default)
#   uninstall   Remove Wine Prefix Automation
#   help        Show all installation options
```

The installer supports the following operations:

- `install` (default): Installs with auto-dependency handling
- `uninstall`: Safely removes the application
- `help`: Shows detailed installation options

## 📋 Dependencies

Required packages:

- `wine`: Windows compatibility layer
- `zenity`: GUI dialog toolkit
- `git`: Version control system (for winetricks installation)

### OPTIONAL : Package Installation by Distribution

#### Dependencies are automatically installed (if not, use the commands below according to your distro)

```bash
# Arch Linux / Manjaro
sudo pacman -S wine zenity git

# Ubuntu / Debian / Linux Mint
sudo apt update && sudo apt install wine zenity git

# Fedora
sudo dnf install wine zenity git

# openSUSE
sudo zypper install wine zenity git
```

## 🎮 Usage

### Starting the Application

Choose one of these methods:

1. Run in terminal: `wine-prefix-automation`
2. Launch from application menu: **Wine Prefix Automation**
3. Click the desktop icon (if available)

### Creating a New Prefix

1. Select your preferred Wine version
2. Enter a name for your prefix
3. Configure Wine settings
4. Optionally install Windows components via winetricks

## 📁 File Structure

#### For verification purposes

```
/usr/bin/wine-prefix-automation           # Main executable (Arch)

/usr/local/bin/wine-prefix-automation     # Main executable (Universal)

~/wineprefixes/                          # Wine prefix storage
└── game-name/                           # Individual prefix folders
    ├── drive_c/                         # Windows C: drive
    └── user.reg                         # Registry files
```

## 🔧 Configuration

### Default Locations

- **Prefixes**: `~/wineprefixes/`
- **Wine Versions**: System-wide and Lutris installations
- **Winetricks**: Auto-downloads if not present

### Environment Variables

```bash
WINEPREFIX="~/wineprefixes/game-name"  # Custom prefix location
WINEARCH="win64"                       # Architecture (win32/win64)
```

## 🗑️ Uninstallation

### Arch Linux

```bash
sudo pacman -R wine-prefix-automation
```

### Universal Installation

```bash
cd wine-prefix-automation/universal
sudo bash install.sh uninstall
```

## 🔍 Troubleshooting

### Common Issues

#### ❌ No Wine Versions Found

- Verify Wine installation: `wine --version`
- Check PATH: `which wine`
- Install Wine if missing

#### ❌ Zenity Missing

```bash
# Arch Linux
sudo pacman -S zenity

# Ubuntu/Debian
sudo apt install zenity
```

#### ❌ Winetricks Problems

- Run manually: `winetricks --gui`
- Check internet connection
- Verify Git installation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

## 📞 Support

- 📑 [Issue Tracker](https://github.com/DhanushSantosh/WinePrefix-Automation/issues)
- 📧 Email: dhanushsantoshs05@gmail.com

---

<p align="center">
Made with ❤️ for the Linux Gaming Community
</p>
