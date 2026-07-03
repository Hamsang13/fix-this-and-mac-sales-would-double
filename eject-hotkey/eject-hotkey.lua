-- ⌘⌥E: 모든 외장(꺼내기 가능) 볼륨 eject.
-- 누른 즉시 Pop 소리로 인지시키고, 결과는 우상단 macOS 알림(hs.notify)으로 표시.
local sndPress = hs.sound.getByName("Pop")   -- 눌린 즉시
local sndFail = hs.sound.getByName("Basso")  -- 실패(사용 중)
local function notify(title, text)
  hs.notify.new({ title = title, informativeText = text, withdrawAfter = 4 }):send()
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
      notify("⏏︎ 꺼내기", "꺼낼 외장 볼륨이 없어요")
    elseif #fail == 0 then
      notify("⏏︎ 꺼냄 완료 — 안전하게 뽑으세요", table.concat(ok, ", "))
    else
      sndFail:play()
      notify("⚠️ 사용 중이라 실패", table.concat(fail, ", ")
        .. (#ok > 0 and ("  (꺼냄: " .. table.concat(ok, ", ") .. ")") or ""))
    end
  end)
end)
