# usb-auto-open

USB 저장장치가 꽂히면 자동으로 Finder에서 해당 볼륨을 연다. macOS에는 외장 USB용
자동 열기 설정이 없어서(예전 CD/DVD 옵션의 잔재만 존재) Hammerspoon으로 처리한다.

## 동작
- 볼륨이 마운트되면 `diskutil info`로 `Protocol:` 확인
- `USB`일 때만 `open`으로 Finder에서 연다

## 필터 기준
`diskutil`의 `Protocol` 값은 디스크가 붙은 물리 버스다.

| 연결 | Protocol |
|------|----------|
| USB 메모리·외장드라이브 | `USB` ← 대상 |
| Thunderbolt SSD | `Thunderbolt` |
| 내장 SSD | `Apple Fabric` / `PCI-Express` |
| `.dmg` | `Disk Image` |
| 네트워크 공유 | 물리 디스크 아님 → 안 걸림 |

주의: USB-C 외장 SSD도 버스가 USB면 잡힌다. 즉 "USB 버스로 연결된 모든 저장장치"가 대상.

## 설치
`usb-auto-open.lua` 내용을 `~/.hammerspoon/init.lua`에 붙여넣고 Reload Config.
