-- 한/영 전환 딜레이 제거.
-- macOS의 "이전 입력 소스 선택" 시스템 단축키는 수백 ms 지연이 있다.
-- F18 키를 eventtap으로 가로채 입력 소스를 직접 즉시 전환하고, 이벤트를 소비(return true)해
-- 느린 시스템 단축키를 아예 안 타게 한다.
--
-- 전제: 우측 Command → F18 하드웨어 리매핑이 되어 있어야 한다(README 참고).
--       다른 트리거 키를 쓰면 아래 F18을 그 키코드로 바꾸면 된다.
local KO = "com.apple.inputmethod.Korean.2SetKorean"
local EN = "com.apple.keylayout.ABC"
local F18 = hs.keycodes.map.f18
hangulToggleTap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
  if e:getKeyCode() ~= F18 then return false end
  local cur = hs.keycodes.currentSourceID()
  hs.keycodes.currentSourceID(cur == KO and EN or KO)
  return true
end)
hangulToggleTap:start()
