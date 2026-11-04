# dotfiles

Cross-platform dotfiles, managed with [GNU stow](https://www.gnu.org/software/stow/).
Each top-level directory is a stow *package* mirroring paths relative to `$HOME`,
so you install only what applies to the machine at hand.

Vim and Emacs configs live in their own repos ([vim](https://github.com/kborling/vim),
emacs.d) — this repo covers everything else.

## Packages

| Package | Contents | Applies to |
|---------|----------|------------|
| `shell` | `.bashrc`, `.bash_profile`, `.inputrc` | Linux, macOS, Windows (git-bash) |
| `git` | `.gitconfig`, `.config/git/ignore` | everywhere |
| `claude` | `.claude/CLAUDE.md` (global instructions for Claude Code: Org documents, working inside Emacs) | everywhere |
| `ssh` | `.ssh/config` (agent/keychain settings; hosts stay in untracked `~/.ssh/config.local`) | everywhere |
| `kitty` | kitty.conf + fleury/uwu/acme themes | Linux, macOS |
| `lisp` | `.sbclrc` (quicklisp init) | Linux, macOS |
| `stumpwm` | `.stumpwmrc`, `.stumpwm.d/` lisp (fonts, theme colors) | Linux |
| `bin` | `theme` (desktop-wide theme switcher), `dmenu-themed`, `emacs-askpass` | Linux (`emacs-askpass`: everywhere) |
| `x11` | `.Xresources`, `.xinitrc` | Linux |
| `dunst` | notification daemon (light/dark variants) | Linux |
| `polybar` | bar configs (light/dark variants) | Linux |
| `gestures` | `libinput-gestures.conf` (3/4-finger workspace swipes) | Linux |
| `redshift` | night light | Linux |
| `xsettingsd` | GTK font/DPI for a bare WM | Linux |
| `wallpapers` | theme-matched wallpapers (used by `bin/theme`) | Linux |

## Install

### Linux

```sh
git clone git@github.com:kborling/dotfiles.git ~/dotfiles
sudo xbps-install stow        # apt/dnf/pacman equivalent elsewhere
cd ~/dotfiles
stow --no-folding */          # everything, or name packages: stow shell git kitty
```

`--no-folding` symlinks individual files instead of whole directories — required
so unmanaged content can coexist (e.g. `~/.stumpwm.d/stumpwm-contrib` is a clone,
not tracked here; `~/.config/dunst/dunstrc` is a switchable symlink, i.e. state).

Stow refuses to overwrite existing real files. On a machine with pre-existing
configs, back them up first or adopt them into the repo: `stow --adopt <pkg>`
(then review `git diff` — adopt moves the *machine's* version into the repo).

### macOS

```sh
brew install stow
cd ~/dotfiles && stow --no-folding shell git claude kitty lisp
```

### Windows

No stow / no reliable symlinks. Two files matter and both support includes:

```sh
# git: layer the shared config under any machine-local settings
git config --global include.path ~/dotfiles/git/.gitconfig

# git-bash: source the shared bashrc from ~/.bashrc
echo '. ~/dotfiles/shell/.bashrc' >> ~/.bashrc

# Claude Code: import the shared CLAUDE.md (back up any existing one first)
echo '@~/dotfiles/claude/.claude/CLAUDE.md' > ~/.claude/CLAUDE.md
```

## Theme system

`fleury` (dark) / `uwu` (dark) / `acme` (light), switched desktop-wide by
`bin/theme` (`theme cycle|toggle|<name>`). It updates kitty (live), the
wallpaper, Emacs, and the StumpWM mode-line/palette, and records the choice in
`~/.config/current-theme`, which `dmenu-themed` reads at launch. Bound in
StumpWM to `C-t t` (cycle) and friends; see `.stumpwmrc`.

## Notes

- `dunst`/`polybar` light/dark selection is a local symlink (`dunstrc` →
  `dunstrc-{light,dark}`), deliberately untracked — create it once per machine.
- Machine bootstrap (package installs, StumpWM/Emacs source builds) lives in the
  separate `void-setup` repo; this repo is configs only.
