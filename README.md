<p align="center"><img src="banner.jpg" alt="DUAL MONITOR banner: an operator at two monitors labeled Virtual-2 and Virtual-1"></p>

# kali-parallels-dual-monitors

Fixes black screens when Kali on Parallels Desktop goes full screen across two 4K monitors on a Mac. It also adds one-key switching between a roomy macOS resolution and the one Kali needs.

Write-up: [Fixing Kali Dual Monitors on Parallels for macOS](https://bltsec.com/blog/kali-parallels-dual-monitors/)

## Why

- Under X11, every monitor shares one framebuffer. On the Parallels ARM guest, `virtio-gpu` caps it at **8192** wide (`xrandr` shows `maximum 8192 x 8192`).
- Parallels hands the guest each display at its macOS **backing** resolution, which is 2× the "looks like" size for HiDPI modes.
- **The sum of backing widths must be 8192 or less**, or both screens go black:

| macOS "looks like" on 4K | Backing per display | Two side by side | Kali full screen |
|---|---|---|---|
| 2560×1440 | 5120×2880 | 10240 | Black |
| 1440 + 1080 mixed | 5120 + 3840 | 8960 | Black |
| **1920×1080** | **3840×2160** | **7680** | Works, native sharpness |

Looks-like 1920×1080 always works, but on a 27" monitor macOS feels like a 1080p screen. This repo switches between a macOS profile and a Kali profile with [displayplacer](https://github.com/jakehilborn/displayplacer) (MIT, homebrew-core) and two Raycast hotkeys.

No guest changes. Everything runs on the macOS host.

## Settings

1. **Parallels → Configure → Hardware → Graphics → Resolution:** **Best for Retina**. ("Scaled" works but text is soft.)
2. **Parallels → Configure → Options → Full Screen:** enable **Use all displays in full screen**.
3. **Kali (Xfce):** keep HiDPI mode (window scaling 2×) and set **Appearance → Fonts → Custom DPI** to taste, for example 80.

## Install

On the Mac:

```sh
git clone https://github.com/BLTSEC/kali-parallels-dual-monitors.git
cd kali-parallels-dual-monitors
./install.sh
```

It installs `displayplacer` with Homebrew if missing, `display-profile` to `~/.local/bin`, and the Raycast scripts to `~/.local/share/raycast-scripts` (override with `RAYCAST_SCRIPTS_DIR`). No root needed.

Capture both layouts, setting the monitors in **System Settings → Displays** first each time:

```sh
display-profile save kali   # both monitors at 1920x1080
display-profile save mac    # both monitors at 2560x1440
```

`save` reports whether the layout fits a Kali full-screen guest:

```text
Saved 'kali' (2 screens) to ~/.config/display-profiles/kali
Guest width 7680 <= 8192: OK for Kali full screen
```

Then in **Raycast → Settings → Extensions → + → Add Script Directory**, add `~/.local/share/raycast-scripts` and assign hotkeys to **Displays: Kali (1080)** and **Displays: Mac (1440)**.

## Use

Press the **Kali** hotkey, open the VM, enter full screen. Back in macOS, press the **Mac** hotkey.

Switch *before* entering full screen. If Kali is already full screen, leave and re-enter with **⌃⌘F**.

```sh
display-profile list          # saved profiles
display-profile check mac     # guest width for a profile
display-profile apply kali    # same as the hotkey
```

Check from Kali after entering full screen:

```sh
xrandr | grep -E '^Screen| connected'
# Screen 0: ... current 7680 x 2160, maximum 8192 x 8192
```

If the screens go black, press **⌃⌘F**, switch to the Kali profile, and re-enter. If Xfce saved an oversize layout, clear it from windowed mode with `xfconf-query -c displays -p /Default -r -R`.

Screen IDs are specific to your hardware. If a new dock or cable changes them, re-save both profiles.

## Uninstall

```sh
./install.sh uninstall
```

Saved profiles in `~/.config/display-profiles` and `displayplacer` are kept.

## Tested

MacBook Pro (Apple Silicon), Parallels Desktop with Parallels Tools 27.0.3, 2× Dell 3840×2160. Kali kernel 7.1.5 (arm64), Xfce 4.20 (X11), `virtio-gpu` with 3D acceleration. `tests/test.sh` runs `display-profile` against a fake displayplacer.

## License

MIT
