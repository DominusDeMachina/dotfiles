# dotfiles

Personal dotfiles for macOS — managed with a bare Git repo.

**Stack:** Zsh + Starship · Neovim · Ghostty · nvm · pyenv · rbenv · 1Password CLI

---

## New Mac Setup

### 1. Xcode Command Line Tools

```bash
xcode-select --install
```

### 2. Homebrew

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Apple Silicon — add to PATH
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

### 3. SSH Key

```bash
ssh-keygen -t ed25519 -C "your@email.com"
eval "$(ssh-agent -s)"
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Add `~/.ssh/id_ed25519.pub` to [GitHub SSH keys](https://github.com/settings/keys).

### 4. Clone Dotfiles

```bash
git clone --bare git@github.com:DominusDeMachina/dotfiles.git $HOME/.dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout
```

> If checkout fails due to existing files:
>
> ```bash
> mkdir -p ~/.dotfiles-backup
> dotfiles checkout 2>&1 | grep "already exists" | awk '{print $1}' | \
>   xargs -I{} mv {} ~/.dotfiles-backup/{}
> dotfiles checkout
> ```

### 5. Install All Packages

```bash
brew bundle install --file=~/Brewfile
```

### 6. Reload Shell

```bash
source ~/.zshrc
```

---

## Language Runtimes

### Node (nvm)

```bash
nvm install --lts
nvm use --lts
```

> `.nvmrc` files are picked up automatically on `cd`.

### Python (pyenv)

```bash
pyenv install 3.x.x
pyenv global 3.x.x
```

### Ruby (rbenv)

```bash
rbenv install 3.x.x
rbenv global 3.x.x
```

### .NET

Already on PATH via `dotnet@8` in Brewfile.

---

## React Native

### iOS

```bash
sudo gem install cocoapods
sudo xcodebuild -license accept
```

Open Xcode → **Settings → Platforms** → install simulators.

### Android

- Open **Android Studio** → **SDK Manager** → install Android SDK
- `ANDROID_HOME` and PATH are already set in `.zshrc`
- `JAVA_HOME` points to Zulu JDK 17 (installed via Brewfile)

---

## 1Password CLI

```bash
op signin
```

Used for injecting secrets (e.g. GitHub token for Claude Code via the `clc` alias).

---

## macOS Settings

```bash
# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles YES

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Fast key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

killall Finder
```

---

## Dotfiles Maintenance

```bash
# Check status
dotfiles status

# Stage and commit a change
dotfiles add ~/.zshrc
dotfiles commit -m "update zshrc"
dotfiles push

# Update Brewfile after installing something
brew bundle dump --force --file=~/Brewfile
dotfiles add ~/Brewfile
dotfiles commit -m "update Brewfile"
dotfiles push
```

> Brewfile also regenerates automatically after `brew install/uninstall/tap` via the `brew()` wrapper in `.zshrc`.

---

## Repo Structure

```
~
├── .zshrc
├── .gitconfig
├── Brewfile
├── .ssh/
│   └── config
└── .config/
    ├── starship.toml
    ├── nvim/          # Lua
    ├── ghostty/
    ├── kanata/
    └── ...
```

# Dotfiles Auto-Sync with fswatch

## Step 1 — Install fswatch

```bash
brew install fswatch
```

## Step 2 — Create the watch script

```bash
mkdir -p ~/.local/bin
```

```bash
cat > ~/.local/bin/dotfiles-watch << 'EOF'
#!/bin/bash
fswatch -o ~/.zshrc ~/.gitconfig ~/.config/ | while read; do
  git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME add -u
  git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME diff --cached --quiet || {
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME commit -m "auto: $(date '+%Y-%m-%d %H:%M')"
    git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME push
  }
done
EOF
```

```bash
chmod +x ~/.local/bin/dotfiles-watch
```

## Step 3 — Create the launchd plist

```bash
cat > ~/Library/LaunchAgents/dotfiles.watch.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>dotfiles.watch</string>
  <key>ProgramArguments</key>
  <array>
    <string>/bin/bash</string>
    <string>$HOME/.local/bin/dotfiles-watch</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <true/>
  <key>StandardOutPath</key>
  <string>/tmp/dotfiles-watch.log</string>
  <key>StandardErrorPath</key>
  <string>/tmp/dotfiles-watch.log</string>
</dict>
</plist>
EOF
```

## Step 4 — Load it

```bash
launchctl load ~/Library/LaunchAgents/dotfiles.watch.plist
```

## Verify it's running

```bash
launchctl list | grep dotfiles
cat /tmp/dotfiles-watch.log
```

---

## Useful commands

```bash
# Stop
launchctl unload ~/Library/LaunchAgents/dotfiles.watch.plist

# Restart
launchctl unload ~/Library/LaunchAgents/dotfiles.watch.plist
launchctl load ~/Library/LaunchAgents/dotfiles.watch.plist

# Watch the log live
tail -f /tmp/dotfiles-watch.log
```
