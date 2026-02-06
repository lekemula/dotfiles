# AGENTS.md

## Project Overview

This repository contains user-specific configuration files (dotfiles) for tools like zsh, vim, tmux, and other utilities. It is designed to facilitate the setup of a customized development environment.

## Key Components

### Shell Configuration
- **.zshrc**: Main configuration file for zsh, includes plugin management and environment variable setup.
- **aliases.zsh**: Custom aliases for commonly used commands.
- **macos.zsh**: macOS-specific configurations.
- **environment.zsh**: Defines environment variables.
- **custom.zsh**: Additional customizations loaded after other configurations.
- **.p10k.zsh**: Powerlevel10k theme configuration for zsh.
- **.fzf.zsh**: FZF (Fuzzy Finder) configuration and key bindings.

### Installation Scripts
- **install.sh**: Script to set up the dotfiles and create necessary symlinks.
- **update.zsh**: Script for updating the dotfiles and configurations.

### Editor Configuration
- **.vimrc**: Configuration file for Vim editor.

### Other Utilities
- **lazygit.yml**: Configuration for lazygit, a Git UI.
- **lazydocker.yml**: Configuration for lazydocker, a Docker UI.
- **btop.conf**: Configuration for btop, a system monitoring tool.
- **RectangleConfig.json**: Configuration for Rectangle, a window management tool.
- **com.googlecode.iterm2.plist**: Configuration for iTerm2 terminal emulator.

## Usage Guide
1. Clone the repository to your home directory.
2. Run `install.sh` to set up symlinks for the dotfiles.
3. Customize the configuration files as needed.

## Maintenance Notes
- Regularly update the `update.zsh` script to ensure compatibility with new tools and configurations.
- Keep the `aliases.zsh` file up to date with frequently used commands.

## Contact
For any issues or questions, refer to the README.md file or contact the repository owner.

