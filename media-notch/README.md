# media-notch

노치를 실시간 음악 위젯으로. 노치에 붙은 검은 패널이 재생 중인 곡(제목·가수·진행바·재생상태)을
보여주고, 마우스를 올리면 노치가 커지며 앨범아트·시간·이전/재생·정지/다음 컨트롤이 있는
전체 플레이어로 확장된다.

## 동작
- **항상 미니바** (노치에 붙음): 제목·가수·진행바 + 맨 우측 재생/정지 표시
- **호버 시 확장** — 패널이 커지며 전체 플레이어로 모핑, 벗어나면 축소(둘 다 애니메이션)
- **멀티소스** 자동 감지(재생 중인 걸 우선): Spotify·Apple Music = 네이티브 AppleScript,
  YouTube Music = Chrome PWA DOM
- **컨트롤**: 이전 / 재생·정지 / 다음
- **📌 핀**: 마우스를 떼도 확장 고정
- **부드러운 마퀴**: 긴 제목/가수는 스크롤, 끝에서 ~2초 멈춘 뒤 처음으로
- **메뉴바 `♪` 토글**: 클릭 한 번으로 이 위젯만 on/off

## 전제
- 노치 맥북(패널이 주 디스플레이 상단 중앙에 고정).
- **YouTube Music만**: 일반 Chrome 창에서 **보기 → 개발자 → Apple Events의 JavaScript 허용** 켜기.
- macOS 15.4+는 시스템 Now Playing(MediaRemote)을 서드파티가 못 읽어서 소스별로 직접 읽는다.

## 설치
`media-notch.lua` 내용을 `~/.hammerspoon/init.lua`에 붙여넣고 Reload Config. 접근성(+ 입력 모니터링) 권한 필요.

> 이 기능만 따로 쓰는 전용 레포: https://github.com/Hamsang13/how-to-make-the-notch-useful
