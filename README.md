<!-- markdownlint-disable MD031 -->

# Config

Config for git, tmux, cargo, helix, vs code, etc.

- [Requirements](#requirements)
  - [Requirements on Linux](#requirements-on-linux)
  - [Requirements on macOS](#requirements-on-macos)
- [Set up config](#set-up-config)
  - [Set up config on Linux](#set-up-config-on-linux)
  - [Set up config on macOS](#set-up-config-on-macos)
- [Set up terminal](#set-up-terminal)
- [Set up Helix](#set-up-helix)
- [Set up VS Code](#set-up-vs-code)

## Requirements

- `xclip`: use xclip in tmux
- `meld`: use meld as diff and merge tool in git
- `git-delta`: use delta instead of less as default pager in git for `git diff`,
  `git show`, etc.
- `fzf`: fuzzy finder

``` bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # Install rustup

cargo install git-delta --locked # syntax-highlighting pager for diffs
cargo install fd-find --locked # fd as alternative for find
cargo install skim --locked # fuzzy finder
cargo install zoxide --locked # z and zi as alternative for cd
cargo install alacritty --locked # terminal emulator
cargo install --git https://github.com/astral-sh/uv uv # package manager for python
```

### Requirements on Linux

``` bash
sudo apt install -y tmux xclip meld fzf
```

### Requirements on macOS

``` bash
brew install bash tmux xclip fzf helix
brew install --cask meld
brew install --cask vscodium
brew install visual-studio-code
```

Useful applications:

``` bash
brew install --cask libreoffice # Install Libre Office
brew install --cask caffeine # prevent mac to go to sleep
brew install --cask rectangle # window management tool to snap and resize windows
brew install --cask alt-tab # Alt+Tab style of switching between windows
```

## Set up config

### Set up config on Linux

Clone the repo into the home directory.

``` bash
# bash
rm "$HOME/.bash_aliases"
ln -sv "$HOME/config/shell/bash/.bash_aliases" "$HOME"

rm "$HOME/.bashrc"
ln -sv "$HOME/config/shell/bash/.bashrc" "$HOME"

rm "$HOME/.profile"
ln -sv "$HOME/config/shell/bash/.profile" "$HOME"

# skim
ln -sv "$HOME/config/skim" "$HOME/.skim"

# zoxide
ln -sv "$HOME/config/zoxide" "$HOME/.zoxide"

# git
rm "$HOME/.gitconfig"
ln -sv "$HOME/config/git/.gitconfig" "$HOME"

# tmux
rm "$HOME/.tmux.conf"
ln -sv "$HOME/config/tmux/.tmux.conf" "$HOME"

# yazi
ln -sv "$HOME/config/yazi/theme.toml" "$HOME/.config/yazi"

# cargo
rm "$HOME/.cargo/config.toml"
ln -sv "$HOME/config/cargo/config.toml" "$HOME/.cargo/config.toml"

# helix
mkdir "$HOME/.config/helix"
ln -sv "$HOME/config/helix/config.toml" "$HOME/.config/helix"
ln -sv "$HOME/config/helix/languages.toml" "$HOME/.config/helix"

# zed
rm "$HOME/.config/zed/settings.json"
ln -sv "$HOME/config/zed/settings.json" "$HOME/.config/zed"

# vs code
rm "$HOME/.config/Code/User/settings.json"
rm "$HOME/.config/Code/User/keybindings.json"
rm "$HOME/.config/Code/User/snippets.json"
ln -sv "$HOME/config/vscode/settings.json" "$HOME/.config/Code/User/settings.json"
ln -sv "$HOME/config/vscode/keybindings.json" "$HOME/.config/Code/User/keybindings.json"
ln -sv "$HOME/config/vscode/snippets" "$HOME/.config/Code/User/snippets"
```

### Set up config on macOS

``` bash
# bash
chsh -s /bin/bash # Make bash default shell
echo $SHELL # Show current shell

rm "$HOME/.bash_aliases"
ln -sv "$HOME/config/shell/bash/.bash_aliases" "$HOME"

rm "$HOME/.bashrc"
ln -sv "$HOME/config/shell/bash/.bashrc" "$HOME"

rm "$HOME/.profile"
ln -sv "$HOME/config/shell/bash/.profile" "$HOME/.profile"

# zsh
rm "$HOME/.zshrc"
ln -sv "$HOME/config/shell/zsh/.zshrc" "$HOME"

rm "$HOME/.inputrc"
ln -sv "$HOME/config/shell/zsh/.inputrc" "$HOME"

# vs code
rm "$HOME/Library/Application Support/Code/User/settings.json"
rm "$HOME/Library/Application Support/Code/User/keybindings.json"
rm "$HOME/Library/Application Support/Code/User/snippets.json"
ln -sv "$HOME/config/vscode/settings.json" "$HOME/Library/Application Support/Code/User/settings.json"
ln -sv "$HOME/config/vscode/keybindings.json" "$HOME/Library/Application Support/Code/User/keybindings.json"
ln -sv "$HOME/config/vscode/snippets" "$HOME/Library/Application Support/Code/User/snippets"

# vc codium
rm "$HOME/Library/Application Support/VSCodium/User/settings.json"
rm "$HOME/Library/Application Support/VSCodium/User/keybindings.json"
rm "$HOME/Library/Application Support/VSCodium/User/snippets.json"
ln -sv "$HOME/config/vscode/settings.json" "$HOME/Library/Application Support/VSCodium/User/settings.json"
ln -sv "$HOME/config/vscode/keybindings.json" "$HOME/Library/Application Support/VSCodium/User/keybindings.json"
ln -sv "$HOME/config/vscode/snippets" "$HOME/Library/Application Support/VSCodium/User/snippets"
```

## Set up terminal

``` bash
# Export profile
dconf dump /org/gnome/terminal/ > gnome_terminal/profiles.txt

# Import profile
dconf load /org/gnome/terminal/ < gnome_terminal/profiles.txt
```

## Set up Helix

``` bash
git clone https://github.com/helix-editor/helix
cd helix
cargo install --path helix-term --locked
ln -Ts $PWD/runtime ~/.config/helix/runtime
rustup component add rust-analyzer # Install language server

hx --health # Check installation
hx --health rust # Check configuration for rust
```

## Set up VS Code

``` bash
# Export extensions
code --list-extensions > vscode/extensions.txt

# Install extensions
xargs -n 1 code --install-extension < "$HOME/config/vscode/extensions/rust.txt"

# Update extensions
code --update-extensions
```
