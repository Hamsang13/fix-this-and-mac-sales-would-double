# fix-this-and-mac-sales-would-double

[English](README.md) · **한국어**

> 애플이 몇 년째 안 고치는 macOS의 자잘한 불편들 — [Hammerspoon](https://www.hammerspoon.org/) 몇 줄로 해결.

**⭐ 여기서 2개 이상 마음에 드셨다면 별 하나 눌러주시면 정말 감사하겠습니다!**

---

## 기능

| 폴더 | 하는 일 |
|------|---------|
| [`airpods-volume-restore`](airpods-volume-restore/) | 에어팟 연결/핸드오프 시 볼륨이 50%로 리셋되는 버그 → 마지막 볼륨 복원 |
| [`usb-auto-open`](usb-auto-open/) | USB 저장장치 꽂으면 Finder로 자동 열기 |
| [`eject-hotkey`](eject-hotkey/) | `⌘⌥E`로 모든 외장 볼륨 한 번에 꺼내기 |
| [`hangul-fast-toggle`](hangul-fast-toggle/) | 한/영 전환 딜레이 제거 |

## 설치

1. Hammerspoon 설치 후 실행, 접근성 권한 허용:
   ```sh
   brew install --cask hammerspoon
   ```
2. 쓰고 싶은 기능의 `.lua`를 `~/.hammerspoon/init.lua`에 붙여넣기
   (또는 폴더를 `~/.hammerspoon/`에 두고 `require`).
3. 메뉴바 망치 아이콘 → **Reload Config**.

각 폴더 README에 세부 동작·튜닝 방법이 있다.

## 기능별 필요한 macOS 설정

### 공통
- **Hammerspoon** 설치 + 실행, 로그인 아이템 추가(재부팅 후 자동 실행).
- **접근성 권한**: 시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용 → Hammerspoon 체크.
- 키 입력을 가로채는 기능(`hangul-fast-toggle`)은 **입력 모니터링** 권한도 필요할 수 있음.

### airpods-volume-restore
- 추가 설정 없음. 접근성 권한만 있으면 볼륨 제어 가능.

### usb-auto-open
- 추가 설정 없음. `diskutil`·`open`은 기본 내장, USB 외 볼륨은 자동 제외.

### eject-hotkey
- 전역 단축키라 접근성 권한 필요. 기본 `⌘⌥E`, 충돌 시 `.lua`에서 키 변경.

### hangul-fast-toggle (설정 제일 많음)
1. **입력 소스 등록**: 시스템 설정 → 키보드 → 입력 소스에 `ABC` + `2벌식` 추가.
   (소스 ID가 다르면 `.lua`의 `KO`/`EN` 수정)
2. **트리거 키 리매핑** (우측 Command → F18):
   ```sh
   hidutil property --set '{"UserKeyMapping":[
     {"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x70000006D}
   ]}'
   ```
3. **재부팅 후 유지** — `hidutil` 매핑은 재부팅 시 초기화된다. 포함된 LaunchAgent로 로그인 시 자동 적용:
   ```sh
   cp hangul-fast-toggle/com.local.rightcmd-to-f18.plist ~/Library/LaunchAgents/
   launchctl load ~/Library/LaunchAgents/com.local.rightcmd-to-f18.plist
   ```
4. eventtap이라 **접근성**(+ 경우에 따라 **입력 모니터링**) 권한 필요.

> 왜 F18을 거치나: macOS는 우측 Command를 네이티브 한/영 키로 안 써서, F18로 바꾼 뒤
> Hammerspoon이 받아 입력 소스를 직접 전환한다.

---

**⭐ 2개 이상 도움이 되셨다면 별 하나 부탁드려요. 감사합니다!**
