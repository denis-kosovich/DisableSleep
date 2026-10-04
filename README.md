# Disable Sleep

A small macOS menu bar app that toggles `pmset -a disablesleep` on and off, with a
clear open/closed-eye icon showing the current state.

## Why

Running `sudo pmset -a disablesleep 1` manually works, but this machine is managed
by CyberArk EPM, which has no standing admin/sudo rights to grant — any `sudo` call
triggers CyberArk's own browser-based approval flow instead of a normal password
prompt. This app just wraps that same `sudo pmset` call behind a menu bar toggle, so
you get the approval prompt and a visible on/off state without touching Terminal.

## Requirements

- macOS 12+
- Xcode Command Line Tools (for the Swift toolchain): `xcode-select --install`

## Build and install

```bash
./build.sh
```

This script:

1. Builds a release binary with Swift Package Manager.
2. Assembles `build/DisableSleep.app`.
3. Installs it to `~/Applications/DisableSleep.app` (replacing any previous copy,
   quitting it first if it's running).
4. Installs and loads a per-user LaunchAgent
   (`~/Library/LaunchAgents/com.dkosovich.disablesleep.plist`) so the app starts
   automatically at login.
5. Launches the app.

Re-run `./build.sh` any time after changing the source to rebuild, reinstall, and
relaunch in one step.

## Usage

Click the eye icon in the menu bar:

- **Closed eye** — sleep is enabled (normal macOS behavior).
- **Open eye** — sleep is disabled.

Toggling runs `sudo pmset -a disablesleep <0|1>`. On this machine that triggers a
CyberArk EPM browser approval; approve it there to complete the toggle.

## Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.dkosovich.disablesleep.plist
rm ~/Library/LaunchAgents/com.dkosovich.disablesleep.plist
rm -rf ~/Applications/DisableSleep.app
```
