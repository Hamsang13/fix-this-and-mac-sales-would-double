# fix-this-and-mac-sales-would-double

> Small macOS annoyances that Apple never fixed — solved in a few lines of [Hammerspoon](https://www.hammerspoon.org/).
> 애플이 몇 년째 안 고치는 macOS의 자잘한 불편들 — [Hammerspoon](https://www.hammerspoon.org/) 몇 줄로 해결.

**⭐ If at least 2 of these are useful to you, a star would mean a lot. Thanks!**
**⭐ 여기서 2개 이상 마음에 드셨다면 별 하나 눌러주시면 정말 감사하겠습니다!**

---

## What's inside · 기능

| Folder · 폴더 | English | 한국어 |
|------|---------|--------|
| [`airpods-volume-restore`](airpods-volume-restore/) | Restores your volume when AirPods connect/handoff (macOS resets it to ~50%) | 에어팟 연결/핸드오프 시 볼륨이 50%로 리셋되는 버그 → 마지막 볼륨 복원 |
| [`usb-auto-open`](usb-auto-open/) | Opens a USB drive in Finder automatically when plugged in | USB 저장장치 꽂으면 Finder로 자동 열기 |
| [`eject-hotkey`](eject-hotkey/) | `⌘⌥E` ejects all external volumes at once | `⌘⌥E`로 모든 외장 볼륨 한 번에 꺼내기 |
| [`hangul-fast-toggle`](hangul-fast-toggle/) | Removes the Korean/English input-switch delay | 한/영 전환 딜레이 제거 |

## Install · 설치

1. Install Hammerspoon, launch it, grant Accessibility permission.
   Hammerspoon 설치 후 실행, 접근성 권한 허용:
   ```sh
   brew install --cask hammerspoon
   ```
2. Copy the `.lua` of the features you want into `~/.hammerspoon/init.lua`
   (or drop the folders into `~/.hammerspoon/` and `require` them).
   쓰고 싶은 기능의 `.lua`를 `~/.hammerspoon/init.lua`에 붙여넣기 (또는 폴더를 두고 `require`).
3. Menu-bar hammer icon → **Reload Config**.
   메뉴바 망치 아이콘 → **Reload Config**.

Each folder's README has details and tuning knobs. · 각 폴더 README에 세부 동작·튜닝 방법이 있다.

## Required macOS settings per feature · 기능별 필요한 macOS 설정

### Common · 공통
- **Hammerspoon** installed + running; add to Login Items so it auto-starts after reboot.
  Hammerspoon 설치 + 실행, 로그인 아이템 추가(재부팅 후 자동 실행).
- **Accessibility** permission: System Settings → Privacy & Security → Accessibility → check Hammerspoon.
  접근성 권한: 시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용 → Hammerspoon 체크.
- Key-intercepting features (`hangul-fast-toggle`) may also need **Input Monitoring**.
  키 입력을 가로채는 기능은 **입력 모니터링** 권한도 필요할 수 있음.

### airpods-volume-restore
- No extra setup. Accessibility permission is enough to control volume.
  추가 설정 없음. 접근성 권한만 있으면 볼륨 제어 가능.

### usb-auto-open
- No extra setup. `diskutil`/`open` are built into macOS; non-USB volumes are filtered out.
  추가 설정 없음. `diskutil`·`open`은 기본 내장, USB 외 볼륨은 자동 제외.

### eject-hotkey
- Global hotkey → needs Accessibility. Default `⌘⌥E`; change the key in the `.lua` if it clashes.
  전역 단축키라 접근성 권한 필요. 기본 `⌘⌥E`, 충돌 시 `.lua`에서 키 변경.

### hangul-fast-toggle (most setup · 설정 제일 많음)
1. **Register input sources · 입력 소스 등록**: add `ABC` and `2-Set Korean` in
   System Settings → Keyboard → Input Sources. (Edit `KO`/`EN` in the `.lua` if your IDs differ.)
   시스템 설정 → 키보드 → 입력 소스에 `ABC` + `2벌식` 추가.
2. **Remap trigger key · 트리거 키 리매핑** (Right Command → F18):
   ```sh
   hidutil property --set '{"UserKeyMapping":[
     {"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x70000006D}
   ]}'
   ```
3. **Persist across reboot · 재부팅 후 유지** — `hidutil` mappings reset on reboot. Install the
   included LaunchAgent so it re-applies at login · 아래 LaunchAgent로 로그인 시 자동 적용:
   ```sh
   cp hangul-fast-toggle/com.local.rightcmd-to-f18.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.local.rightcmd-to-f18.plist
   ```
4. eventtap needs **Accessibility** (and possibly **Input Monitoring**).
   eventtap이라 접근성(+ 경우에 따라 입력 모니터링) 권한 필요.

> Why F18? macOS doesn't treat Right Command as a native Korean/English key, so we remap it to
> F18 and let Hammerspoon catch F18 and switch the input source directly.
> 왜 F18을 거치나: macOS는 우측 Command를 네이티브 한/영 키로 안 써서, F18로 바꾼 뒤
> Hammerspoon이 받아 입력 소스를 직접 전환한다.

---

**⭐ Found 2+ of these useful? Drop a star — much appreciated!**
**⭐ 2개 이상 도움이 되셨다면 별 하나 부탁드려요. 감사합니다!**
