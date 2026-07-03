# hammerspoon-tweaks

[Hammerspoon](https://www.hammerspoon.org/)으로 만든 macOS 자잘한 자동화 모음. 기능별 폴더.

## 기능

| 폴더 | 하는 일 |
|------|---------|
| [`airpods-volume-restore`](airpods-volume-restore/) | 에어팟 연결 시 볼륨이 50%로 리셋되는 버그 → 마지막 볼륨 복원 |
| [`usb-auto-open`](usb-auto-open/) | USB 저장장치 꽂으면 Finder로 자동 열기 |
| [`eject-hotkey`](eject-hotkey/) | `⌘⌥E`로 모든 외장 볼륨 한 번에 꺼내기 |

## 설치

1. Hammerspoon 설치 후 실행, 접근성 권한 허용:
   ```sh
   brew install --cask hammerspoon
   ```
2. 쓰고 싶은 기능의 `.lua` 내용을 `~/.hammerspoon/init.lua`에 붙여넣기
   (또는 폴더를 `~/.hammerspoon/`에 두고 `require`).
3. 메뉴바 망치 아이콘 → **Reload Config**.

각 폴더 README에 세부 동작·튜닝 방법이 있다.
