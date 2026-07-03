# hangul-fast-toggle

한/영 전환 딜레이를 없앤다.

## 문제
macOS의 **"이전/다음 입력 소스 선택"** 시스템 단축키는 반응이 굼뜨다(수백 ms 지연).
우측 Command 키를 F18로 리매핑해서 이 단축키에 걸어도 결국 느린 경로를 타서 지연이 남는다.

## 해결
F18 키다운을 Hammerspoon `eventtap`으로 가로채:
1. `hs.keycodes.currentSourceID()`로 입력 소스를 **직접 즉시 토글**
2. `return true`로 이벤트를 소비 → 느린 시스템 단축키가 발동하지 않음

시스템 단축키(`symbolichotkeys`)를 끌 필요도 없다(eventtap이 이벤트를 먼저 먹는다).

## 전제: 트리거 키 리매핑
이 스크립트는 **F18 키**를 트리거로 쓴다. 우측 Command를 F18로 보내려면 하드웨어 리매핑이 필요하다:

```sh
hidutil property --set '{"UserKeyMapping":[
  {"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x70000006D}
]}'
```
(`0x7000000E7` = 우측 Command, `0x70000006D` = F18)

주의: `hidutil` 매핑은 재부팅 시 초기화된다. 유지하려면 로그인 시 실행되는 LaunchAgent로 등록한다.

다른 키를 트리거로 쓰고 싶으면 `.lua`의 `F18`을 해당 키코드(`hs.keycodes.map.<키>`)로 바꾼다.

## 입력 소스 ID 확인
본인 환경의 소스 ID가 다르면 `KO`/`EN`을 바꾼다:
```sh
hs -c 'print(hs.keycodes.currentSourceID())'   # 각 상태에서 실행해 ID 확인
```

## 설치
`hangul-fast-toggle.lua` 내용을 `~/.hammerspoon/init.lua`에 붙여넣고 Reload Config.
eventtap이라 접근성 권한이 필요하다.
