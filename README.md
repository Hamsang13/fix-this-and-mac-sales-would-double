# hammerspoon-tweaks

[Hammerspoon](https://www.hammerspoon.org/)으로 만든 macOS 자잘한 자동화 모음. 기능별 폴더.

## 기능

| 폴더 | 하는 일 |
|------|---------|
| [`airpods-volume-restore`](airpods-volume-restore/) | 에어팟 연결 시 볼륨이 50%로 리셋되는 버그 → 마지막 볼륨 복원 |
| [`usb-auto-open`](usb-auto-open/) | USB 저장장치 꽂으면 Finder로 자동 열기 |
| [`eject-hotkey`](eject-hotkey/) | `⌘⌥E`로 모든 외장 볼륨 한 번에 꺼내기 |
| [`hangul-fast-toggle`](hangul-fast-toggle/) | 한/영 전환 딜레이 제거 (느린 시스템 단축키 우회) |

## 설치

1. Hammerspoon 설치 후 실행, 접근성 권한 허용:
   ```sh
   brew install --cask hammerspoon
   ```
2. 쓰고 싶은 기능의 `.lua` 내용을 `~/.hammerspoon/init.lua`에 붙여넣기
   (또는 폴더를 `~/.hammerspoon/`에 두고 `require`).
3. 메뉴바 망치 아이콘 → **Reload Config**.

각 폴더 README에 세부 동작·튜닝 방법이 있다.

## 기능별 필요한 macOS 설정

### 공통 (모든 기능)
- **Hammerspoon 설치 + 실행**, 로그인 아이템에 추가(재부팅 후 자동 실행).
- **접근성 권한**: 시스템 설정 → 개인정보 보호 및 보안 → 손쉬운 사용 → Hammerspoon 체크.
- 키 입력을 가로채는 기능(`hangul-fast-toggle`)은 **입력 모니터링** 권한도 필요할 수 있음
  (같은 설정 화면 → 입력 모니터링 → Hammerspoon).

### airpods-volume-restore
- 추가 설정 없음. 접근성 권한만 있으면 볼륨 제어 가능.
- 입력 소스/키보드 설정과 무관.

### usb-auto-open
- 추가 설정 없음. `diskutil`·`open`은 macOS 기본 내장.
- USB 외 볼륨은 자동으로 걸러짐(`Protocol: USB` 필터).

### eject-hotkey
- 전역 단축키라 **접근성 권한** 필요(공통에 포함).
- 기본 키 `⌘⌥E`. 다른 앱과 충돌하면 `.lua`에서 키 변경.

### hangul-fast-toggle (설정 제일 많음)
1. **입력 소스 등록**: 시스템 설정 → 키보드 → 텍스트 입력 → 입력 소스에
   `ABC`(영문)와 `2벌식`(한국어)을 추가. (소스 ID가 다르면 `.lua`의 `KO`/`EN` 수정)
2. **트리거 키 리매핑** (우측 Command → F18):
   ```sh
   hidutil property --set '{"UserKeyMapping":[
     {"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x70000006D}
   ]}'
   ```
3. **재부팅 후에도 유지** — `hidutil`은 재부팅 시 초기화된다. 아래 LaunchAgent로 로그인 시 자동 적용:

   `~/Library/LaunchAgents/com.local.rightcmd-to-f18.plist`
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
     <key>Label</key><string>com.local.rightcmd-to-f18</string>
     <key>ProgramArguments</key>
     <array>
       <string>/usr/bin/hidutil</string>
       <string>property</string>
       <string>--set</string>
       <string>{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x70000006D}]}</string>
     </array>
     <key>RunAtLoad</key><true/>
   </dict>
   </plist>
   ```
   ```sh
   launchctl load ~/Library/LaunchAgents/com.local.rightcmd-to-f18.plist
   ```
4. eventtap이라 **접근성**(+ 경우에 따라 **입력 모니터링**) 권한 필요.

> 왜 F18을 거치나: macOS는 우측 Command를 네이티브 한/영 키로 쓰지 않는다. 그래서
> 우Cmd를 F18로 바꾼 뒤 Hammerspoon이 F18을 받아 입력 소스를 직접 전환한다.
