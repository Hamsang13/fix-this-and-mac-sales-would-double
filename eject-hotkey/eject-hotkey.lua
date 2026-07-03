-- ⌘⌥E: 모든 외장(꺼내기 가능) 볼륨 eject.
-- 누른 즉시 소리+"꺼내는 중…"으로 인지시키고, 블로킹 eject는 다음 틱에 실행 → 결과 표시.
local sndPress = hs.sound.getByName("Pop")   -- 눌린 즉시
local sndFail = hs.sound.getByName("Basso")  -- 실패(사용 중)
hs.hotkey.bind({"cmd", "alt"}, "e", function()
  sndPress:play()
  hs.alert.show("⏏︎ 꺼내는 중…", 2)
  hs.timer.doAfter(0.1, function()  -- "꺼내는 중" 알림이 먼저 그려지도록 지연
    local ok, fail = {}, {}
    for path, info in pairs(hs.fs.volume.allVolumes()) do
      if info["NSURLVolumeIsEjectableKey"] == true then
        local name = path:match("[^/]+$") or path
        local _, status = hs.execute('diskutil eject ' .. ('%q'):format(path))
        if status then ok[#ok + 1] = name else fail[#fail + 1] = name end
      end
    end
    hs.alert.closeAll()
    if #ok == 0 and #fail == 0 then
      hs.alert.show("꺼낼 외장 볼륨이 없어요")
    elseif #fail == 0 then
      hs.alert.show("⏏︎ 꺼냄: " .. table.concat(ok, ", ") .. "\n이제 안전하게 뽑으세요")
    else
      sndFail:play()
      hs.alert.show("⚠️ 사용 중이라 실패: " .. table.concat(fail, ", ")
        .. (#ok > 0 and ("\n꺼냄: " .. table.concat(ok, ", ")) or ""))
    end
  end)
end)
