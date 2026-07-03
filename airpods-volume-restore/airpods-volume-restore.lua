-- 에어팟 연결/핸드오프 시 macOS가 볼륨을 50%로 리셋하는 문제 → 마지막 볼륨 복원
local KEY = "airpodsVolume"
local restoring = false
local commitTimer = nil  -- 볼륨 커밋 디바운스 타이머

local function isAirPods(dev)
  return dev ~= nil and dev:name():find("AirPods") ~= nil
end

-- 볼륨을 즉시 저장하지 않고 3초 안정 후 커밋한다.
-- 이유: 핸드오프/재연결 시 macOS의 50% 리셋 이벤트가 AUDIO 워처보다 먼저 도착해
-- 좋은 값을 덮어쓸 수 있어서. 리셋이 감지되면(scheduleRestore) 대기 커밋을 취소한다.
local function trackVolume(dev)
  dev:watcherCallback(function()
    if restoring then return end
    local v = dev:outputVolume()
    if not v then return end
    if commitTimer then commitTimer:stop() end
    commitTimer = hs.timer.doAfter(3, function()
      if not restoring then hs.settings.set(KEY, v) end
    end)
  end):watcherStart()
end

-- 에어팟이 기본 출력이 되는 순간(재연결/핸드오프) 저장값으로 복원
local function scheduleRestore(dev)
  local saved = hs.settings.get(KEY)
  if not saved then return end
  restoring = true
  if commitTimer then commitTimer:stop(); commitTimer = nil end  -- 리셋값 커밋 취소
  -- 빠르게 첫 보정(블립 최소) + 여러 번 재적용(늦게 오는 리셋도 잡음).
  -- 늦거나 리셋이 새면 시각/횟수를 늘린다.
  for _, t in ipairs({ 0.2, 0.6, 1.2 }) do
    hs.timer.doAfter(t, function()
      if isAirPods(hs.audiodevice.defaultOutputDevice()) then
        dev:setOutputVolume(saved)
      end
    end)
  end
  hs.timer.doAfter(3, function() restoring = false end)  -- 잔여 리셋 지나갈 시간
end

hs.audiodevice.watcher.setCallback(function()
  local dev = hs.audiodevice.defaultOutputDevice()
  if not isAirPods(dev) then return end
  scheduleRestore(dev)
  trackVolume(dev)
end)
hs.audiodevice.watcher.start()

-- 시작 시 이미 에어팟이 연결돼 있으면 추적 시작
if isAirPods(hs.audiodevice.defaultOutputDevice()) then
  trackVolume(hs.audiodevice.defaultOutputDevice())
end
