# 🚀 dotfiles

[![FlakeHub](https://img.shields.io/endpoint?url=https://flakehub.com/f/loganlinn/dotfiles/badge)](https://flakehub.com/flake/loganlinn/dotfiles)
[![Nix Flake](https://img.shields.io/badge/nix-flake-blue?logo=nixos)](https://nixos.org)
[![Built with Home Manager](https://img.shields.io/badge/built%20with-home--manager-orange)](https://nix-community.github.io/home-manager/)

> **throw more dots** ✨

*A comprehensive, cross-platform dotfiles configuration powered by Nix flakes*

[![](./moredots.gif)](https://knowyourmeme.com/memes/50-dkp-minus-onyxia-wipe)

## 🌟 Features

- **🎯 Cross-Platform**: Supports NixOS, macOS (nix-darwin), and Windows
- **⚡ Nix Flakes**: Reproducible, declarative configuration management
- **🏠 Home Manager**: User environment management with dotfiles
- **🎨 Rich Terminal**: Configured with Wezterm, Zsh, Starship, and more
- **💻 Development Ready**: Pre-configured for multiple languages and tools
- **🔧 Modular Design**: Easy to customize and extend

## 🏗️ Structure

```
├── config/          # Application configurations
├── darwin/          # macOS-specific modules
├── nixos/           # NixOS configurations
├── home-manager/    # User environment configs
├── nix/             # Nix modules and packages
└── windows/         # Windows configurations
```

## 🚀 Quick Start

### Prerequisites
- [Nix](https://nixos.org/download.html) with flakes enabled
- [Just](https://github.com/casey/just) (optional, for convenience)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/loganlinn/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Switch to configuration**
   ```bash
   # For NixOS
   sudo nixos-rebuild switch --flake .

   # For macOS
   darwin-rebuild switch --flake .

   # For home-manager only
   home-manager switch --flake .
   ```

3. **Or use Just for convenience**
   ```bash
   just switch
   ```

## 🛠️ Key Components

### Desktop Environments
- **i3wm** - Tiling window manager with custom keybindings
- **AwesomeWM** - Dynamic window manager with Lua configuration
- **Hyprland** - Modern Wayland compositor

### Terminal & Shell
- **Wezterm** - GPU-accelerated terminal with rich features
- **Zsh** - Enhanced shell with completions and plugins
- **Starship** - Fast, customizable prompt

### Development Tools
- **Neovim** - Configured with LSP, treesitter, and plugins
- **Git** - With aliases, hooks, and integrations
- **Docker/Podman** - Container development
- **Languages**: Rust, Go, Node.js, Python, Nix, and more

### Applications
- **Firefox** - Web browser with custom settings
- **VS Code** - IDE with extensions and settings
- **Kitty/Alacritty** - Alternative terminal emulators

## 🎨 Theming

Multiple color schemes available:
- Dracula
- Nord
- One Dark
- Tokyo Night
- Catppuccin

## 📱 Platform-Specific Features

### NixOS
- Full system configuration
- Desktop environment setup
- Hardware-specific configurations

### macOS
- Homebrew integration
- macOS system preferences
- Aerospace window management

### Windows
- PowerShell configuration
- Windows Terminal settings
- Winget package management

## 🔧 Customization

1. **Fork the repository**
2. **Modify configurations** in respective directories
3. **Test changes** with `nix flake check`
4. **Apply changes** with switch commands

### Adding New Packages
```nix
# In home-manager configuration
home.packages = with pkgs; [
  your-package-here
];
```

## 📋 Available Commands

Use `just` for common operations:

```bash
just help          # Show available commands
just switch         # Apply configuration
just clean          # Clean build artifacts
just snapshot       # Create git snapshot
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📚 Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix-Darwin](https://github.com/LnL7/nix-darwin)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*✨ Powered by Nix Flakes • Built with ❤️*
