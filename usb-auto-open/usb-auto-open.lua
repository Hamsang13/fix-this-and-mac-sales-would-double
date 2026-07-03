-- USB 버스로 연결된 볼륨이 마운트되면 Finder로 열기 (dmg·네트워크·썬더볼트 제외)
hs.fs.volume.new(function(event, info)
  if event ~= hs.fs.volume.didMount or not info.path then return end
  local out = hs.execute('diskutil info ' .. ('%q'):format(info.path))
  if out and out:find('Protocol:%s*USB') then
    hs.execute('open ' .. ('%q'):format(info.path))
  end
end):start()
