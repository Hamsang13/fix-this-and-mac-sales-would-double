-- ⌘⌥E: 모든 외장(꺼내기 가능) 볼륨 eject.
-- 누른 즉시 Pop 소리로 인지시키고, 결과는 우상단 토스트로 표시.
local sndPress = hs.sound.getByName("Pop")   -- 눌린 즉시
local sndFail = hs.sound.getByName("Basso")  -- 실패(사용 중)
-- 우상단 토스트 (hs.alert는 중앙 고정이라 위치를 못 옮겨 canvas로 직접 그림)
local function toast(text)
  local pad = 14
  local styled = hs.styledtext.new(text, { font = { size = 14 }, color = { white = 1 } })
  local ts = hs.drawing.getTextDrawingSize(styled)
  local w, h = math.ceil(ts.w) + pad * 2, math.ceil(ts.h) + pad * 2  -- 줄바꿈 없음, 긴 목록은 길어짐
  local sf = hs.screen.mainScreen():frame()
  local c = hs.canvas.new({ x = sf.x + sf.w - w - 16, y = sf.y + 16, w = w, h = h })
  c:appendElements(
    { type = "rectangle", action = "fill", roundedRectRadii = { xRadius = 10, yRadius = 10 },
      fillColor = { black = 1, alpha = 0.82 } },
    { type = "text", text = styled, frame = { x = pad, y = pad, w = w - pad * 2, h = h - pad * 2 } }
  )
  c:show()
  hs.timer.doAfter(3, function() c:delete(0.4) end)
end
hs.hotkey.bind({"cmd", "alt"}, "e", function()
  sndPress:play()
  hs.timer.doAfter(0, function()  -- 블로킹 eject를 다음 틱으로 넘겨 소리가 먼저 나게
    local ok, fail = {}, {}
    for path, info in pairs(hs.fs.volume.allVolumes()) do
      if info["NSURLVolumeIsEjectableKey"] == true then
        local name = path:match("[^/]+$") or path
        local _, status = hs.execute('diskutil eject ' .. ('%q'):format(path))
        if status then ok[#ok + 1] = name else fail[#fail + 1] = name end
      end
    end
    if #ok == 0 and #fail == 0 then
      toast("꺼낼 외장 볼륨이 없어요")
    elseif #fail == 0 then
      toast("⏏︎ 꺼냄: " .. table.concat(ok, ", ") .. " — 안전하게 뽑으세요")
    else
      sndFail:play()
      toast("⚠️ 사용 중이라 실패: " .. table.concat(fail, ", ")
        .. (#ok > 0 and ("  (꺼냄: " .. table.concat(ok, ", ") .. ")") or ""))
    end
  end)
end)
