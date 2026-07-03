-- ⌘⌥E: 모든 외장(꺼내기 가능) 볼륨 eject
hs.hotkey.bind({"cmd", "alt"}, "e", function()
  local names = {}
  for path, info in pairs(hs.fs.volume.allVolumes()) do
    if info["NSURLVolumeIsEjectableKey"] == true then
      hs.execute('diskutil eject ' .. ('%q'):format(path))
      names[#names + 1] = path:match("[^/]+$") or path
    end
  end
  hs.alert.show(#names > 0 and ("꺼냄: " .. table.concat(names, ", ")) or "외장 볼륨 없음")
end)
