# eject-hotkey

`⌘⌥E` 전역 단축키로 꺼내기 가능한 모든 외장 볼륨을 한 번에 eject 한다. Finder에서
드라이브 찾아 제거 버튼 누르는 번거로움을 없앤다.

macOS에서 "그냥 뽑기"는 안전하게 만들 수 없다 — eject가 곧 캐시 flush + 마운트 해제라
건너뛰면 데이터 손상 위험과 "제대로 꺼내지 않았습니다" 경고가 뜬다. 그래서 이 방식은
꺼내기 자체를 단축키 한 방으로 줄이는 것이다.

## 동작
- `⌘⌥E`를 누르면 `hs.fs.volume.allVolumes()`를 훑어 `NSURLVolumeIsEjectableKey == true`인
  볼륨을 모두 `diskutil eject`
- 내장 SSD는 ejectable이 아니라 절대 안 건드림
- **즉시 인지**: 누른 순간 `Pop` 소리 + "⏏︎ 꺼내는 중…" 알림. 블로킹되는 `diskutil eject`는
  알림이 먼저 그려지도록 다음 틱(`doAfter 0.1`)에 실행한다.
- **결과 피드백**: eject 후 알림 교체
  - 성공: "⏏︎ 꺼냄: … / 이제 안전하게 뽑으세요"
  - 사용 중이라 실패(`diskutil eject` status=false): `Basso` 소리 + 실패한 볼륨 표시
  - 대상 없음: 안내

## 설치
`eject-hotkey.lua` 내용을 `~/.hammerspoon/init.lua`에 붙여넣고 Reload Config.
전역 단축키라 어느 앱에서든 먹는다(Hammerspoon 실행 + 접근성 권한 필요).
다른 앱과 충돌하면 `{"cmd", "alt"}, "e"`를 원하는 키로 바꾼다.
