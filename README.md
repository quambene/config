<!-- markdownlint-disable MD031 -->

# Config

Config for git, tmux, cargo, helix, etc.

- [Requirements](#requirements)
- [Set up config](#set-up-config)
- [Set up terminal](#set-up-terminal)
- [Set up Helix](#set-up-helix)

## Requirements

- `xclip`: use xclip in tmux
- `meld`: use meld as diff and merge tool in git
- `git-delta`: use delta instead of less as default pager in git for `git diff`,
  `git show`, etc.

``` bash
sudo apt install -y xclip meld
cargo install git-delta
```

## Set up config

``` bash
rm "$HOME/.bash_aliases"
ln -sv "$HOME/config/.bash_aliases" "$HOME"

rm "$HOME/.profile"
ln -sv "$HOME/config/.profile" "$HOME"

rm "$HOME/.gitconfig"
ln -sv "$HOME/config/.gitconfig" "$HOME"

rm "$HOME/.tmux.conf"
ln -sv "$HOME/config/.tmux.conf" "$HOME"

rm "$HOME/.cargo/config.toml"
ln -sv "$HOME/config/.cargo/config.toml" "$HOME/.cargo/config.toml"

mkdir "$HOME/.config/helix"
ln -sv "$HOME/config/helix/config.toml" "$HOME/.config/helix"
ln -sv "$HOME/config/helix/languages.toml" "$HOME/.config/helix"

rm "$HOME/.config/zed/settings.json"
ln -sv "$HOME/dotfiles/zed/settings.json" "$HOME/.config/zed"
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
