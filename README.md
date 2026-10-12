# macOS dotfiles

Personal macOS configuration, managed with a bare Git repository at
`$HOME/.dotfiles` and `$HOME` as its working tree.

## Current snapshot

Updated September 15, 2026 from the running Mac.

- `Brewfile`: Homebrew packages, apps, VS Code extensions, and supported Go,
  Cargo, uv, and npm tools.
- `mac-setup/applications.json`: inventory of app bundles in `/Applications`
  and `~/Applications`, including apps installed outside Homebrew.
- `mac-setup/raycast-extensions.json`: installed Raycast extension inventory.
- `mac-setup/tracked-files.txt`: configuration files included in this snapshot.
- Shell and developer settings: Zsh, Git, tmux, SSH connection settings, mise,
  Neovim, Ghostty, Zed, VS Code, and Claude Code.
- Additional app settings include Karabiner, Neru, Yazi, eza, lazygit,
  television, posting, and OpenCode.

This saves setup files and installation inventories. App documents, account
sessions, credentials, browser profiles, and a complete macOS preferences image
are not included. Package inventories are not version lockfiles: a new install
will use the versions available at restore time.

## Set up a new Mac

### 1. Install prerequisites

Install Xcode Command Line Tools:

```sh
xcode-select --install
```

Install Homebrew using the instructions at <https://brew.sh>. For Apple Silicon:

```sh
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Set up GitHub access with a new SSH key or 1Password SSH agent. SSH private keys
and login credentials are not stored here.

### 2. Restore the configuration

```sh
git clone --bare git@github.com:DominusDeMachina/dotfiles.git "$HOME/.dotfiles"
alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
dotfiles checkout
```

If Git reports existing files that would be overwritten, back up the named files
before retrying checkout. Check the restored SSH configuration before reconnecting
to GitHub. Some settings contain paths for `/Users/gennadiyfurduy`; adjust those
if the new Mac uses a different account name.

### 3. Install apps and tools

```sh
brew bundle install --file="$HOME/Brewfile"
cd "$HOME"
mise install
```

The mise configuration manages Node, Python, Ruby, and language tools. The
Brewfile includes Zulu JDK 21. For React Native development, install full Xcode
and the required simulators, then configure Android SDKs in Android Studio.

Review `mac-setup/applications.json` and install any remaining apps manually.
Use `mac-setup/raycast-extensions.json` to reinstall Raycast extensions; extension
preferences and account connections need to be set up separately.

### 4. Sign in and finish setup

- Sign in to 1Password and enable its CLI/SSH integrations as needed.
- Reauthenticate GitHub CLI (`gh auth login`), Google Cloud, and other tools.
- Configure or regenerate 1Password shell plugins used by `.zshrc`.
- Sign in to apps and restore their data through their normal backup/sync tools.
- Grant macOS accessibility and input-monitoring permissions to keyboard tools.
- Reload the shell with `source "$HOME/.zshrc"`.

## Refresh the backup

The `brew()` function in `.zshrc` refreshes `Brewfile` after install, uninstall,
and tap commands. It does not commit or upload files. Automatic Git syncing is
not installed on this Mac as of this snapshot.

```sh
brew bundle dump --force --file="$HOME/Brewfile"
dotfiles status
```

Homebrew's current dump omitted two installed packages from third-party taps.
This snapshot explicitly includes both:

```ruby
brew "jesseduffield/lazydocker/lazydocker"
brew "wix-incubator/brew/applesimutils"
```

After a future dump, check that those entries are present if the packages remain
installed. Then stage tracked changes and explicitly add any new settings files:

```sh
dotfiles add -u
# Example for a new configuration:
# dotfiles add "$HOME/.config/example/config.toml"
dotfiles diff --cached --stat
dotfiles diff --cached | gitleaks stdin --redact --no-banner
dotfiles commit -m "refresh Mac configuration and installed apps"
dotfiles push origin main
```

Review the staged changes before committing. Keep credential files, tokens,
private keys, logs, databases, caches, and generated application files out of the
snapshot. The September refresh removed previously tracked runtime files from
Git tracking while retaining their local copies. Existing Git history is
unchanged.
