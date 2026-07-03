-- ⌘⌥E: 모든 외장(꺼내기 가능) 볼륨 eject + 소리/성공·실패 피드백
local sndOk = hs.sound.getByName("Glass")    -- 성공
local sndNone = hs.sound.getByName("Tink")   -- 대상 없음
local sndFail = hs.sound.getByName("Basso")  -- 실패(사용 중)
hs.hotkey.bind({"cmd", "alt"}, "e", function()
  local ok, fail = {}, {}
  for path, info in pairs(hs.fs.volume.allVolumes()) do
    if info["NSURLVolumeIsEjectableKey"] == true then
      local name = path:match("[^/]+$") or path
      local _, status = hs.execute('diskutil eject ' .. ('%q'):format(path))
      if status then ok[#ok + 1] = name else fail[#fail + 1] = name end
    end
  end
  if #ok == 0 and #fail == 0 then
    sndNone:play()
    hs.alert.show("꺼낼 외장 볼륨이 없어요")
  elseif #fail == 0 then
    sndOk:play()
    hs.alert.show("⏏︎ 꺼냄: " .. table.concat(ok, ", ") .. "\n이제 안전하게 뽑으세요")
  else
    sndFail:play()
    hs.alert.show("⚠️ 사용 중이라 실패: " .. table.concat(fail, ", ")
      .. (#ok > 0 and ("\n꺼냄: " .. table.concat(ok, ", ")) or ""))
  end
end)
