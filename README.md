# fix-this-and-mac-sales-would-double

**English** · [한국어](README.ko.md)

> Small macOS annoyances that Apple never fixed — solved in a few lines of [Hammerspoon](https://www.hammerspoon.org/).

**⭐ If at least 2 of these are useful to you, a star would mean a lot. Thanks!**

---

## What's inside

| Folder | What it does |
|--------|--------------|
| [`airpods-volume-restore`](airpods-volume-restore/) | Restores your volume when AirPods connect/handoff (macOS resets it to ~50%) |
| [`usb-auto-open`](usb-auto-open/) | Opens a USB drive in Finder automatically when plugged in |
| [`eject-hotkey`](eject-hotkey/) | `⌘⌥E` ejects all external volumes at once |
| [`hangul-fast-toggle`](hangul-fast-toggle/) | Removes the Korean/English input-switch delay |
| [`media-notch`](media-notch/) | Turns the notch into a live music widget (Spotify / Apple Music / YouTube Music) |

## Install

1. Install Hammerspoon, launch it, grant Accessibility permission:
   ```sh
   brew install --cask hammerspoon
   ```
2. Copy the `.lua` of the features you want into `~/.hammerspoon/init.lua`
   (or drop the folders into `~/.hammerspoon/` and `require` them).
3. Menu-bar hammer icon → **Reload Config**.

Each folder's README has details and tuning knobs.

## Required macOS settings per feature

### Common
- **Hammerspoon** installed + running; add to Login Items so it auto-starts after reboot.
- **Accessibility** permission: System Settings → Privacy & Security → Accessibility → check Hammerspoon.
- Key-intercepting features (`hangul-fast-toggle`) may also need **Input Monitoring**.

### airpods-volume-restore
- No extra setup. Accessibility permission is enough to control volume.

### usb-auto-open
- No extra setup. `diskutil`/`open` are built into macOS; non-USB volumes are filtered out.

### eject-hotkey
- Global hotkey → needs Accessibility. Default `⌘⌥E`; change the key in the `.lua` if it clashes.

### hangul-fast-toggle (most setup)
1. **Register input sources**: add `ABC` and `2-Set Korean` in
   System Settings → Keyboard → Input Sources. (Edit `KO`/`EN` in the `.lua` if your IDs differ.)
2. **Remap trigger key** (Right Command → F18):
   ```sh
   hidutil property --set '{"UserKeyMapping":[
     {"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x70000006D}
   ]}'
   ```
3. **Persist across reboot** — `hidutil` mappings reset on reboot. Install the included
   LaunchAgent so it re-applies at login:
   ```sh
   cp hangul-fast-toggle/com.local.rightcmd-to-f18.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.local.rightcmd-to-f18.plist
   ```
4. eventtap needs **Accessibility** (and possibly **Input Monitoring**).

> Why F18? macOS doesn't treat Right Command as a native Korean/English key, so we remap it to
> F18 and let Hammerspoon catch F18 and switch the input source directly.

---

**⭐ Found 2+ of these useful? Drop a star — much appreciated!**
