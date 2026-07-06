-- 노치 아래 항상 미니바(제목·가수·진행바), 노치 호버 시 전체 팝업(앨범아트+시간+제어)으로 확장.
-- 멀티소스: Spotify / Apple Music(음악) = 네이티브 AppleScript, YouTube Music = Chrome PWA DOM.
-- 전제(YT Music만): Chrome "보기>개발자>Apple Events의 JavaScript 허용" 켜짐.
_media = _media or {}
for _, k in ipairs({ "dataT", "poll", "anim", "scrollT" }) do if _media[k] then _media[k]:stop() end end
_media.scrollPx, _media.scrollPhase, _media.scrollHold, _media.lastTrack = 0, "start", 0, nil
for _, k in ipairs({ "bar", "pop", "panel" }) do if _media[k] then _media[k]:delete() end end
_media.bar, _media.pop, _media.panel, _media.state, _media.expanded, _media.out = nil, nil, nil, nil, false, 0
_media.pinned = false

-- YT Music DOM에서 탭구분 문자열 반환(JS 안엔 큰따옴표 금지)
local YT_JS = "(function(){var pb=document.querySelector('ytmusic-player-bar');var t=(pb&&pb.querySelector('.title'))?pb.querySelector('.title').textContent:'';var b=(pb&&pb.querySelector('.byline'))?pb.querySelector('.byline').textContent:'';var im=document.querySelector('#song-image img');var a=im?im.src:'';var v=document.querySelector('video');var ti=document.querySelector('.time-info');var cur=0,tot=0;function s(x){var p=(x||'').trim().split(':');return p.length===2?(parseInt(p[0])*60+parseInt(p[1])):0;}if(ti){var mm=ti.textContent.split('/');cur=s(mm[0]);tot=s(mm[1]);}if(!tot&&v)tot=Math.round(v.duration||0);if(!cur&&v)cur=Math.round(v.currentTime||0);var T=String.fromCharCode(9);return ['ytm',t,b,cur,tot,(v&&v.paused)?1:0,a].join(T);})()"

-- Spotify는 설치돼 있을 때만 블록 포함(미설치면 tell 블록이 컴파일 자체가 안 돼 전체 파싱 실패).
local SPOTIFY_BLOCK = ""
local spPath = hs.application.pathForBundleID("com.spotify.client")
if spPath and spPath ~= "" and hs.fs.attributes(spPath) then
  SPOTIFY_BLOCK = [[
if application "Spotify" is running then
  tell application "Spotify"
    if player state is not stopped then
      try
        set ct to current track
        set p to "1"
        if player state is playing then set p to "0"
        set pos to 0
        try
          set pos to (player position)
        end try
        set dur to 0
        try
          set dur to (duration of ct)
        end try
        set out to out & "spotify" & TAB & (name of ct) & TAB & (artist of ct) & TAB & (round pos) & TAB & (round (dur / 1000)) & TAB & p & TAB & (artwork url of ct) & LF
      end try
    end if
  end tell
end if
]]
end

-- 정지 아닌(재생/일시정지) 소스를 모두 줄단위로 모음. Lua에서 재생 중인 걸 우선 선택.
local MEDIA_SCRIPT = [[set TAB to (ASCII character 9)
set LF to (ASCII character 10)
set out to ""
]] .. SPOTIFY_BLOCK .. [[
if application "Music" is running then
  tell application "Music"
    if player state is not stopped then
      try
        set ct to current track
        set p to "1"
        if player state is playing then set p to "0"
        set pos to 0
        try
          set pos to (player position)
        end try
        set dur to 0
        try
          set dur to (duration of ct)
        end try
        set out to out & "music" & TAB & (name of ct) & TAB & (artist of ct) & TAB & (round pos) & TAB & (round dur) & TAB & p & TAB & "" & LF
      end try
    end if
  end tell
end if
if application "Google Chrome" is running then
  set gotYT to false
  tell application "Google Chrome"
    repeat with w in windows
      if gotYT then exit repeat
      repeat with t in tabs of w
        if (URL of t) contains "music.youtube.com" then
          set out to out & (execute t javascript "]] .. YT_JS .. [[") & LF
          set gotYT to true
          exit repeat
        end if
      end repeat
    end repeat
  end tell
end if
if out is "" then return "NONE"
return out
]]

local function parseState(out)
  if not out or out == "" or out:match("^NONE") then return nil end
  local best, firstAny  -- 재생 중(best) 우선, 없으면 첫 후보
  for line in out:gmatch("[^\r\n]+") do
    if line ~= "" and line ~= "NONE" then
      local f = {}
      for s in (line .. "\t"):gmatch("(.-)\t") do f[#f + 1] = s end
      if #f >= 6 and not (f[2] == "" and f[3] == "") then
        local c = { source = f[1], t = f[2] or "", b = f[3] or "", ct = tonumber(f[4]) or 0, du = tonumber(f[5]) or 0, paused = (f[6] == "1"), art = f[7] or "" }
        firstAny = firstAny or c
        if not c.paused and not best then best = c end
      end
    end
  end
  return best or firstAny
end

-- 앨범아트: YT는 URL 크기 키워 선명하게(다른 소스 URL은 그대로). URL 바뀔 때만 재다운로드.
local artUrl, artImg
local function getArt(url)
  if not url or url == "" then return nil end
  local big = url:gsub("=w%d+%-h%d+.-$", "=w240-h240")
  if big ~= artUrl then artUrl = big; artImg = hs.image.imageFromURL(big) end
  return artImg
end

local function fmt(sec)
  sec = math.max(0, math.floor(sec or 0))
  return string.format("%d:%02d", math.floor(sec / 60), sec % 60)
end

-- 긴 텍스트 자동 스크롤: clip 창 안에서 텍스트를 픽셀 단위로 이동. 창보다 짧으면 안 움직임.
local function textW(s, size) return hs.drawing.getTextDrawingSize(hs.styledtext.new(s or "", { font = { size = size } })).w end
-- els에 clip+text+resetClip 3요소 추가, 스크롤 디스크립터 반환
local function appendScroll(els, wx, wy, ww, wh, text, size, color)
  local tW = textW(text, size)
  local maxS = math.max(0, tW - ww + 2)
  local fw = tW + 40
  els[#els + 1] = { type = "rectangle", action = "clip", frame = { x = wx, y = wy - 1, w = ww, h = wh + 2 } }
  els[#els + 1] = { type = "text", text = text, textColor = color, textSize = size, frame = { x = wx - math.min(_media.scrollPx or 0, maxS), y = wy, w = fw, h = wh } }
  local d = { idx = #els, wx = wx, wy = wy, fw = fw, wh = wh, maxS = maxS }
  els[#els + 1] = { type = "resetClip" }
  return d
end

local function geo()
  local s = hs.screen.primaryScreen()
  local f = s:fullFrame()
  return f, (s:frame().y - f.y)
end
-- 하나의 패널이 노치에 붙어 크기만 커졌다/작아짐(축소=미니, 확장=전체). 둘 다 최상단 붙음.
local COL_W, EXP_W = 250, 380
local function colFrame() local f, mb = geo(); return { x = f.x + f.w / 2 - COL_W / 2, y = f.y, w = COL_W, h = mb + 34 } end
local function expFrame() local f, mb = geo(); return { x = f.x + f.w / 2 - EXP_W / 2, y = f.y, w = EXP_W, h = mb + 118 } end

-- 검은 배경: 위 둥근 모서리는 화면 밖(-16)으로 밀어 각지게(노치와 연결), 아래만 둥글게.
local function bgEl(w, h) return { type = "rectangle", action = "fill", frame = { x = 0, y = -16, w = w, h = h + 16 }, roundedRectRadii = { xRadius = 16, yRadius = 16 }, fillColor = { black = 1, alpha = 1 } } end

-- 축소: 좌측 제목/가수, 우측 진행바
local function renderMini(st)
  local _, mb = geo()
  local top, px = mb + 4, 130
  local ppX = COL_W - 22          -- 맨 우측 재생/정지 표시 중앙
  local pw = ppX - 12 - px        -- 진행바는 그 앞까지
  local ratio = (st.du > 0) and math.min(1, st.ct / st.du) or 0
  local tw = px - 22
  local els = { bgEl(COL_W, mb + 34) }
  local dt = appendScroll(els, 14, top, tw, 15, st.t, 13, { white = 1 })
  local db = appendScroll(els, 14, top + 14, tw, 13, st.b, 11, { white = 0.6 })
  els[#els + 1] = { type = "rectangle", action = "fill", frame = { x = px, y = top + 12, w = pw, h = 3 }, roundedRectRadii = { xRadius = 2, yRadius = 2 }, fillColor = { white = 0.28 } }
  els[#els + 1] = { type = "rectangle", action = "fill", frame = { x = px, y = top + 12, w = pw * ratio, h = 3 }, roundedRectRadii = { xRadius = 2, yRadius = 2 }, fillColor = { white = 0.9 } }
  els[#els + 1] = { type = "text", text = st.paused and "▶" or "⏸", textColor = { white = 0.85 }, textSize = 12, frame = { x = ppX - 10, y = top + 2, w = 20, h = 20 }, textAlignment = "center" }
  _media.panel:replaceElements(els)
  _media.mq = { title = dt, artist = db }
end

-- 확장: 앨범아트 + 제목/가수 + 진행바/시간 + 이전/재생·정지/다음
local function renderFull(st, img)
  local _, mb = geo()
  local top = mb + 8
  local colX, colW = 112, EXP_W - 112 - 40  -- 우상단 핀 자리 확보
  local cx = colX + colW / 2
  local ratio = (st.du > 0) and math.min(1, st.ct / st.du) or 0
  local els = { bgEl(EXP_W, mb + 118) }
  els[#els + 1] = img and { type = "image", image = img, frame = { x = 16, y = top, w = 80, h = 80 } }
      or { type = "rectangle", action = "fill", frame = { x = 16, y = top, w = 80, h = 80 }, roundedRectRadii = { xRadius = 8, yRadius = 8 }, fillColor = { white = 0.18 } }
  local dt = appendScroll(els, colX, top, colW, 22, st.t, 16, { white = 1 })
  local db = appendScroll(els, colX, top + 24, colW, 18, st.b, 13, { white = 0.62 })
  local rest = {
    { type = "rectangle", action = "fill", frame = { x = colX, y = top + 50, w = colW, h = 4 }, roundedRectRadii = { xRadius = 2, yRadius = 2 }, fillColor = { white = 0.25 } },
    { type = "rectangle", action = "fill", frame = { x = colX, y = top + 50, w = colW * ratio, h = 4 }, roundedRectRadii = { xRadius = 2, yRadius = 2 }, fillColor = { white = 0.95 } },
    { type = "text", text = fmt(st.ct), textColor = { white = 0.55 }, textSize = 10, frame = { x = colX, y = top + 57, w = 60, h = 14 } },
    { type = "text", text = fmt(st.du), textColor = { white = 0.55 }, textSize = 10, frame = { x = colX + colW - 60, y = top + 57, w = 60, h = 14 }, textAlignment = "right" },
    { type = "circle", center = { x = cx - 46, y = top + 88 }, radius = 15, action = "fill", fillColor = { white = 0.13 }, id = "prev", trackMouseUp = true },
    { type = "circle", center = { x = cx, y = top + 88 }, radius = 17, action = "fill", fillColor = { white = 0.16 }, id = "pp", trackMouseUp = true },
    { type = "circle", center = { x = cx + 46, y = top + 88 }, radius = 15, action = "fill", fillColor = { white = 0.13 }, id = "next", trackMouseUp = true },
    { type = "text", text = "⏮", textColor = { white = 0.9 }, textSize = 16, frame = { x = cx - 61, y = top + 78, w = 30, h = 22 }, textAlignment = "center" },
    { type = "text", text = st.paused and "▶" or "⏸", textColor = { white = 1 }, textSize = 16, frame = { x = cx - 15, y = top + 78, w = 30, h = 22 }, textAlignment = "center" },
    { type = "text", text = "⏭", textColor = { white = 0.9 }, textSize = 16, frame = { x = cx + 31, y = top + 78, w = 30, h = 22 }, textAlignment = "center" },
    { type = "circle", center = { x = EXP_W - 22, y = top + 10 }, radius = 12, action = "fill", fillColor = { alpha = 0.01 }, id = "pin", trackMouseUp = true },
  }
  for _, e in ipairs(rest) do els[#els + 1] = e end
  local pinX, pinY = EXP_W - 22, top + 10
  if _media.pinned then
    -- 박힌 핀: 위에서 본 핀 머리(라디얼 그라데이션 점, 중앙 밝고 바깥 링 어둡게)
    els[#els + 1] = { type = "circle", center = { x = pinX, y = pinY }, radius = 6, action = "fill",
      fillGradient = "radial", fillGradientCenter = { x = -0.3, y = -0.3 },
      fillGradientColors = { { red = 1, green = 0.36, blue = 0.32, alpha = 1 }, { red = 0.6, green = 0.09, blue = 0.08, alpha = 1 } } }
  else
    els[#els + 1] = { type = "text", text = "📌", textColor = { white = 0.6 }, textSize = 12, frame = { x = pinX - 11, y = top + 1, w = 22, h = 18 }, textAlignment = "center" }
  end
  _media.panel:replaceElements(els)
  _media.mq = { title = dt, artist = db }
end

-- 크기 모핑(노치가 커졌다/작아지는 연결감). bg를 매 프레임 채워 아래 둥근 모서리 유지.
local function morph(toExpanded)
  if _media.anim then _media.anim:stop() end
  if toExpanded and _media.state then renderFull(_media.state, getArt(_media.state.art)) end
  local start = _media.panel:frame()
  local target = toExpanded and expFrame() or colFrame()
  local steps, i = (toExpanded and 9 or 5), 0  -- 축소는 더 빠르게
  _media.anim = hs.timer.doEvery(0.016, function()
    i = i + 1
    local e = 1 - (1 - i / steps) ^ 2
    local w = start.w + (target.w - start.w) * e
    local h = start.h + (target.h - start.h) * e
    local f = geo()
    _media.panel:frame({ x = f.x + f.w / 2 - w / 2, y = f.y, w = w, h = h })
    _media.panel:elementAttribute(1, "frame", { x = 0, y = -16, w = w, h = h + 16 })
    if i >= steps then
      _media.anim:stop(); _media.anim = nil
      if not toExpanded and _media.state then renderMini(_media.state) end
    end
  end)
end

-- 소스별 제어(비동기)
local function control(action)
  local src = _media.state and _media.state.source
  local script
  if src == "spotify" then
    script = 'tell application "Spotify" to ' .. ({ prev = "previous track", pp = "playpause", next = "next track" })[action]
  elseif src == "music" then
    script = 'tell application "Music" to ' .. ({ prev = "back track", pp = "playpause", next = "next track" })[action]
  else
    local sel = ({ prev = ".previous-button", pp = "#play-pause-button", next = ".next-button" })[action]
    local js = "(document.querySelector('" .. sel .. "')||{click:function(){}}).click()"
    script = 'tell application "Google Chrome"\nrepeat with w in windows\nrepeat with t in tabs of w\nif (URL of t) contains "music.youtube.com" then\nexecute t javascript "' .. js .. '"\nreturn\nend if\nend repeat\nend repeat\nend tell'
  end
  hs.task.new("/usr/bin/osascript", function() hs.timer.doAfter(0.2, _media.readNow) end, { "-e", script }):start()
end

local function onClick(_, msg, id)
  if msg ~= "mouseUp" then return end
  if id == "pin" then
    _media.pinned = not _media.pinned
    if _media.state then renderFull(_media.state, getArt(_media.state.art)) end
  elseif id == "prev" or id == "pp" or id == "next" then
    control(id)
  end
end

local hadMedia = false
local function readNow()
  hs.task.new("/usr/bin/osascript", function(_, out)
    if not _media.panel then return end  -- 정지됨: 삭제된 패널 건드리지 않기
    local st = parseState(out)
    _media.state = st
    local has = st ~= nil
    if has then  -- 곡 바뀌면 스크롤 처음으로
      local key = st.t .. "|" .. st.b
      if _media.lastTrack ~= key then _media.lastTrack = key; _media.scrollPx, _media.scrollPhase, _media.scrollHold = 0, "start", 0 end
    end
    if has ~= hadMedia then
      hadMedia = has
      if has then _media.panel:show(0.2) else _media.panel:hide(0.2) end
    end
    if has and not _media.anim then  -- 애니메이션 중엔 재렌더 안 함
      if _media.expanded then renderFull(st, getArt(st.art)) else renderMini(st) end
    end
  end, { "-e", MEDIA_SCRIPT }):start()
end
_media.readNow = readNow

local function poll()
  local p = hs.mouse.absolutePosition()
  local f, mb = geo()
  local inNotch = (p.y <= f.y + math.max(mb, 26)) and (math.abs(p.x - (f.x + f.w / 2)) <= 130)
  local inPanel = false
  if _media.panel and _media.panel:isShowing() then
    local fr = _media.panel:frame()
    inPanel = p.x >= fr.x - 6 and p.x <= fr.x + fr.w + 6 and p.y >= fr.y and p.y <= fr.y + fr.h + 6
  end
  local want = (inNotch or inPanel or _media.pinned) and _media.state ~= nil
  if want then
    _media.out = 0
    if not _media.expanded then _media.expanded = true; morph(true) end
  elseif _media.expanded then
    _media.out = _media.out + 1
    if _media.out >= 1 then _media.expanded = false; morph(false) end  -- 거의 즉시 축소
  end
end

-- 긴 제목/가수 자동 스크롤(표시 중 & 애니메이션 아닐 때만)
local function scrollTick()
  if not _media.state or not _media.panel or not _media.panel:isShowing() or _media.anim then return end
  local mq = _media.mq
  if not mq then return end
  local omax = math.max(mq.title.maxS, mq.artist.maxS)
  if omax <= 0 then return end  -- 창 안에 다 들어오면 스크롤 안 함
  local ph = _media.scrollPhase or "start"
  _media.scrollHold = _media.scrollHold or 0
  if ph == "start" then  -- 시작 ~0.6s 멈춤
    _media.scrollHold = _media.scrollHold + 1
    if _media.scrollHold >= 20 then _media.scrollPhase, _media.scrollHold = "run", 0 end
  elseif ph == "run" then
    _media.scrollPx = (_media.scrollPx or 0) + 1.4
    if _media.scrollPx >= omax then _media.scrollPx, _media.scrollPhase, _media.scrollHold = omax, "end", 0 end
  else  -- end: 끝에서 ~2s 멈춤 후 처음으로 리셋
    _media.scrollHold = _media.scrollHold + 1
    if _media.scrollHold >= 67 then _media.scrollPx, _media.scrollPhase, _media.scrollHold = 0, "start", 0 end
  end
  local px = _media.scrollPx or 0
  pcall(function()
    local t, b = mq.title, mq.artist
    _media.panel:elementAttribute(t.idx, "frame", { x = t.wx - math.min(px, t.maxS), y = t.wy, w = t.fw, h = t.wh })
    _media.panel:elementAttribute(b.idx, "frame", { x = b.wx - math.min(px, b.maxS), y = b.wy, w = b.fw, h = b.wh })
  end)
end

-- 위젯 시작/정지(메뉴바 토글용)
local function startWidget()
  if _media.panel then return end
  hadMedia = false
  _media.state, _media.expanded, _media.pinned, _media.out = nil, false, false, 0
  -- 패널은 메뉴바(노치) 위에 그려야 해서 높은 레벨(floating은 메뉴바 아래로 밀림)
  _media.panel = hs.canvas.new(colFrame()); _media.panel:level(hs.canvas.windowLevels.screenSaver); _media.panel:mouseCallback(onClick)
  _media.panel:topLeft({ x = colFrame().x, y = colFrame().y })
  readNow()
  local tick = 0
  _media.dataT = hs.timer.doEvery(0.5, function()  -- 확장 시 0.5s, 축소 시 1s
    tick = tick + 1
    if _media.expanded or tick % 2 == 0 then readNow() end
  end)
  _media.poll = hs.timer.doEvery(0.04, poll)          -- 호버 반응 즉각
  _media.scrollT = hs.timer.doEvery(0.03, scrollTick) -- 부드러운 스크롤
  _media.enabled = true
end

local function stopWidget()
  for _, k in ipairs({ "dataT", "poll", "scrollT", "anim" }) do if _media[k] then _media[k]:stop(); _media[k] = nil end end
  if _media.panel then _media.panel:delete(); _media.panel = nil end
  _media.enabled = false
end

-- 메뉴바 토글 아이콘(이 위젯만 on/off)
if _media.menubar then _media.menubar:delete() end
_media.menubar = hs.menubar.new()
local function refreshBar()
  _media.menubar:setTitle(hs.styledtext.new("♪", { color = { white = 1, alpha = _media.enabled and 1 or 0.35 }, font = { size = 15 } }))
  _media.menubar:setTooltip("노치 미디어 위젯: " .. (_media.enabled and "켜짐" or "꺼짐"))
end
_media.menubar:setClickCallback(function()  -- 클릭 한 번에 바로 토글
  if _media.enabled then stopWidget() else startWidget() end
  refreshBar()
end)

startWidget()
refreshBar()
