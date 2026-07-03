# airpods-volume-restore

에어팟(블루투스 오디오)이 연결되면 macOS가 출력 볼륨을 16단계 중 절반(약 50%)으로
리셋해버리는 오래된 버그가 있다. 이 스크립트는 에어팟으로 듣는 동안 볼륨을 기억해뒀다가,
재연결 시 macOS가 리셋한 직후 마지막 볼륨으로 되돌린다.

## 동작
- 에어팟이 기본 출력일 때 볼륨을 바꿀 때마다 `hs.settings`에 저장
- 재연결되면 1.5초 뒤(리셋 타이밍 이후) 저장값으로 복원
- 복원 중 발생하는 50% 리셋 저장은 `restoring` 플래그로 무시

## 튜닝
복원이 안 먹으면 `hs.timer.doAfter(1.5, ...)`의 `1.5`를 키운다. (macOS 리셋 타이밍 보정 knob)

## 설치
`airpods-volume-restore.lua` 내용을 `~/.hammerspoon/init.lua`에 붙여넣고 Reload Config.
