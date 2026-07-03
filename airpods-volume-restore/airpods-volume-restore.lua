-- 에어팟 연결 시 macOS가 볼륨을 50%로 리셋하는 문제 → 마지막 볼륨 복원
local KEY = "airpodsVolume"
local restoring = false

local function isAirPods(dev)
  return dev ~= nil and dev:name():find("AirPods") ~= nil
end

-- 에어팟이 출력 장치인 동안 볼륨 변화를 기억 (복원 중에는 무시)
local function trackVolume(dev)
  dev:watcherCallback(function()
    if restoring then return end
    local v = dev:outputVolume()
    if v then hs.settings.set(KEY, v) end
  end):watcherStart()
end

hs.audiodevice.watcher.setCallback(function()
  local dev = hs.audiodevice.defaultOutputDevice()
  if not isAirPods(dev) then return end
  local saved = hs.settings.get(KEY)
  if saved then
    restoring = true
    -- 1.5s는 macOS 리셋 타이밍 보정 knob. 복원이 안 먹으면 값을 키우세요
    hs.timer.doAfter(1.5, function()
      if isAirPods(hs.audiodevice.defaultOutputDevice()) then
        dev:setOutputVolume(saved)
      end
      restoring = false
    end)
  end
  trackVolume(dev)
end)
hs.audiodevice.watcher.start()

-- 시작 시 이미 에어팟이 연결돼 있으면 추적 시작
if isAirPods(hs.audiodevice.defaultOutputDevice()) then
  trackVolume(hs.audiodevice.defaultOutputDevice())
end
