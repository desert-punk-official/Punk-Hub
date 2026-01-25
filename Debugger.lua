--========================================
-- Punk X Debugger
-- COMPLETE CODE - READY TO USE
--========================================

-- Services
local LogService = game:GetService("LogService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- Config
local LOG_FILE_NAME = "Punk-X-Files/PunkX_Logs.txt"
local MAX_LOGS = 1000

-- Forward Declarations
local ExcludeBtn, PinBtn, ExportBtn, ThemeBtn, HistoryBtn, HighlightBtn
local refreshVirtualScroll, applyTheme

-- State
local isMinimized = false
local isFilterActive = true
local autoScrollEnabled = true
local showTimestamps = true
local showLineNumbers = true
local logCount = 0
local logHistory = {}
local virtualLogData = {}
local groupedLogs = {}
local userHasScrolled = false
local expandedGroups = {}
local pinnedSearchTerms = {}
local excludePatterns = {}
local currentTheme = "dark"
local fontSize = 14
local useRegex = false
local searchHistory = {}
local selectedLogKey = nil
local actionBarVisible = false
local currentHighlights = {}
local highlightConnections = {} -- Stores events for auto-updating
local isHighlighting = false

-- Type filters
local typeFilters = { INFO = true, WARN = true, ERROR = true }

-- Performance
local searchDebounce = nil
local fps = 0
local memoryUsage = 0
local ping = 0
local logRateCounter = 0

--========================================
-- THEME SYSTEM
--========================================
local themes = {
    dark = { bg = Color3.fromRGB(20, 20, 20), logBg1 = Color3.fromRGB(35, 35, 35), logBg2 = Color3.fromRGB(45, 45, 45), selected = Color3.fromRGB(65, 65, 65), text = Color3.new(1, 1, 1), search = Color3.fromRGB(50, 50, 50) },
    light = { bg = Color3.fromRGB(240, 240, 240), logBg1 = Color3.fromRGB(255, 255, 255), logBg2 = Color3.fromRGB(250, 250, 250), selected = Color3.fromRGB(220, 220, 220), text = Color3.new(0, 0, 0), search = Color3.fromRGB(230, 230, 230) },
    blue = { bg = Color3.fromRGB(15, 25, 35), logBg1 = Color3.fromRGB(25, 35, 50), logBg2 = Color3.fromRGB(30, 45, 60), selected = Color3.fromRGB(50, 70, 90), text = Color3.fromRGB(200, 220, 255), search = Color3.fromRGB(35, 50, 70) }
}

--========================================
-- GUI SETUP
--========================================

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomLogViewer"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

-- MAIN FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0.8, 0, 0.7, 0)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Active = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

-- Toast Container
local ToastContainer = Instance.new("Frame")
ToastContainer.Size = UDim2.new(1, 0, 1, 0)
ToastContainer.BackgroundTransparency = 1
ToastContainer.ZIndex = 500
ToastContainer.Parent = MainFrame

local function showToast(text, color)
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(0, 0, 0, 25)
    t.AutomaticSize = Enum.AutomaticSize.X
    t.Position = UDim2.new(0.5, 0, 0.9, 0)
    t.AnchorPoint = Vector2.new(0.5, 1)
    t.BackgroundColor3 = color or Color3.fromRGB(40, 40, 40)
    t.Text = "  " .. text .. "  "
    t.TextColor3 = Color3.new(1, 1, 1)
    t.Font = Enum.Font.GothamBold
    t.TextSize = 12
    t.Parent = ToastContainer
    Instance.new("UICorner", t).CornerRadius = UDim.new(0, 6)
    t.Position = UDim2.new(0.5, 0, 0.95, 0)
    TweenService:Create(t, TweenInfo.new(0.3), {Position = UDim2.new(0.5, 0, 0.9, 0)}):Play()
    task.delay(1.5, function() local tw = TweenService:Create(t, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}); tw:Play(); tw.Completed:Connect(function() t:Destroy() end) end)
end

-- Stats Bar
local StatsBar = Instance.new("TextLabel")
StatsBar.Size = UDim2.new(1, -20, 0.06, 0)
StatsBar.Position = UDim2.new(0, 10, 0, 0)
StatsBar.BackgroundTransparency = 1
StatsBar.Text = "FPS: 0 | Mem: 0 | Logs: 0"
StatsBar.TextColor3 = Color3.new(1, 1, 1)
StatsBar.TextXAlignment = Enum.TextXAlignment.Left
StatsBar.Font = Enum.Font.GothamBold
StatsBar.TextSize = 12
StatsBar.Parent = MainFrame

-- Title Bar
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, -40, 0.06, 0)
TitleBar.Position = UDim2.new(0, 0, 0.06, 0)
TitleBar.BackgroundTransparency = 1
TitleBar.Text = "  Punk X Debugger"
TitleBar.TextColor3 = Color3.fromRGB(100, 200, 255)
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Font = Enum.Font.GothamBold
TitleBar.TextSize = 16
TitleBar.Parent = MainFrame

-- Performance Loop
local lastUpdate = tick()
local frameCount = 0
RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastUpdate >= 1 then
        fps = frameCount
        frameCount = 0
        lastUpdate = now
        memoryUsage = math.floor(Stats:GetTotalMemoryUsageMb())
        local player = Players.LocalPlayer
        if player then ping = math.floor(player:GetNetworkPing() * 1000) end
        local width = MainFrame.AbsoluteSize.X
        if width < 450 then StatsBar.Text = string.format("FPS:%d | Mem:%d | P:%d | L:%d", fps, memoryUsage, ping, #virtualLogData)
        else StatsBar.Text = string.format("FPS: %d | Memory: %d MB | Ping: %dms | Logs: %d", fps, memoryUsage, ping, #virtualLogData) end
    end
end)

-- Main Frame Drag
local dragging, dragInput, dragStart, startPos
local function updateDrag(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = MainFrame.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
TitleBar.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
UserInputService.InputChanged:Connect(function(input) if input == dragInput and dragging then updateDrag(input) end end)

-- Search Box
local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(0.86, -5, 0.05, 0)
SearchBox.Position = UDim2.new(0.02, 0, 0.13, 0)
SearchBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SearchBox.PlaceholderText = "Search logs... (Regex: OFF)"
SearchBox.Text = ""
SearchBox.ClearTextOnFocus = false
SearchBox.TextColor3 = Color3.new(1, 1, 1)
SearchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
SearchBox.Font = Enum.Font.Gotham
SearchBox.TextSize = 12
SearchBox.TextXAlignment = Enum.TextXAlignment.Left
SearchBox.Parent = MainFrame
Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)
local SearchPadding = Instance.new("UIPadding", SearchBox); SearchPadding.PaddingLeft = UDim.new(0, 8)

-- Eye Button
HighlightBtn = Instance.new("TextButton")
HighlightBtn.Size = UDim2.new(0.08, 0, 0.05, 0)
HighlightBtn.Position = UDim2.new(0.9, 0, 0.13, 0)
HighlightBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HighlightBtn.Text = "👁️"
HighlightBtn.TextColor3 = Color3.new(1, 1, 1)
HighlightBtn.TextSize = 14
HighlightBtn.Parent = MainFrame
Instance.new("UICorner", HighlightBtn).CornerRadius = UDim.new(0, 6)

-- Scroll Frame
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Position = UDim2.new(0.02, 0, 0.19, 0)
ScrollFrame.Size = UDim2.new(0.96, 0, 0.51, 0)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4
ScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.Parent = MainFrame
Instance.new("UICorner", ScrollFrame)
local UIListLayout = Instance.new("UIListLayout"); UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder; UIListLayout.Parent = ScrollFrame

-- Resize Handle
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Size = UDim2.new(0, 30, 0, 30)
ResizeHandle.Position = UDim2.new(1, -30, 1, -30)
ResizeHandle.BackgroundTransparency = 1
ResizeHandle.Text = "↗"
ResizeHandle.TextColor3 = Color3.fromRGB(180, 180, 180)
ResizeHandle.Font = Enum.Font.GothamBold
ResizeHandle.TextSize = 18
ResizeHandle.ZIndex = 10
ResizeHandle.Parent = MainFrame
local resizing = false
ResizeHandle.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = true end end)
UserInputService.InputChanged:Connect(function(input) if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local mousePos = input.Position; local framePos = MainFrame.AbsolutePosition; MainFrame.Size = UDim2.new(0, math.max(300, mousePos.X - framePos.X), 0, math.max(180, mousePos.Y - framePos.Y)) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end end)

-- Toggle Button
local ToggleButton = Instance.new("ImageButton")
ToggleButton.Name = "DebugToggle"
ToggleButton.Size = UDim2.new(0, 45, 0, 45)
ToggleButton.Position = UDim2.new(0, 10, 0.5, -22)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.BackgroundTransparency = 0.3
ToggleButton.BorderSizePixel = 0
ToggleButton.Image = "rbxthumb://type=Asset&id=121884098955130&w=420&h=420"
ToggleButton.ScaleType = Enum.ScaleType.Fit
ToggleButton.Parent = ScreenGui
Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
ToggleButton.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

-- TOGGLE DRAG LOGIC (Restored)
local toggleDragging, toggleDragStart, toggleStartPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = ToggleButton.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then toggleDragging = false end end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - toggleDragStart
        ToggleButton.Position = UDim2.new(toggleStartPos.X.Scale, toggleStartPos.X.Offset + delta.X, toggleStartPos.Y.Scale, toggleStartPos.Y.Offset + delta.Y)
    end
end)

-- Helpers
local function sanitize(t) return t:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;") end
local function escapePattern(t) return t:gsub("([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1") end
local function isSpam(msg) msg = msg:lower(); return msg:find("invocation queue exhausted") or msg:find("discarded event") or msg:find("did you forget to implement onclientevent") end
local function isExcluded(msg) if not msg then return false end; msg = tostring(msg):lower(); for _, pattern in ipairs(excludePatterns) do if msg:find(pattern:lower(), 1, true) then return true end end; return false end
local function isPinned(msg) if #pinnedSearchTerms == 0 then return false end; msg = tostring(msg):lower(); for _, term in ipairs(pinnedSearchTerms) do if msg:find(term:lower(), 1, true) then return true end end; return false end
local function highlightText(text, searchTerm)
    if searchTerm == "" then return sanitize(text) end
    local sanitizedText = sanitize(text)
    if useRegex then local s, r = pcall(function() return sanitizedText:gsub("(" .. searchTerm .. ")", '<font color="rgb(255,255,0)"><b>%1</b></font>') end); if s then return r end end
    local result, lastPos, lowerText, lowerSearch, startPos = "", 1, text:lower(), searchTerm:lower(), 1
    while true do
        local foundStart, foundEnd = lowerText:find(escapePattern(lowerSearch), startPos, true)
        if not foundStart then break end
        result = result .. sanitize(text:sub(lastPos, foundStart - 1)) .. '<font color="rgb(255,255,0)"><b>' .. sanitize(text:sub(foundStart, foundEnd)) .. '</b></font>'
        lastPos, startPos = foundEnd + 1, foundEnd + 1
    end
    return result .. sanitize(text:sub(lastPos))
end

-- Function Definitions
applyTheme = function(name)
    local t = themes[name] or themes.dark
    MainFrame.BackgroundColor3 = t.bg
    ScrollFrame.BackgroundColor3 = t.bg
    SearchBox.BackgroundColor3 = t.search
    SearchBox.TextColor3 = t.text
    currentTheme = name
    if refreshVirtualScroll then refreshVirtualScroll() end
end

-- Logging & Export
pcall(function() if writefile then writefile(LOG_FILE_NAME, "-- Session Start --\n") end end)
local function saveLog(text) pcall(function() if appendfile then appendfile(LOG_FILE_NAME, text .. "\n") elseif writefile and readfile then local c = ""; pcall(function() c = readfile(LOG_FILE_NAME) end); writefile(LOG_FILE_NAME, c .. text .. "\n") end end) end
local function exportToJSON() local data = { session = os.date("%Y-%m-%d %H:%M:%S"), logs = {} }; for _, log in ipairs(virtualLogData) do table.insert(data.logs, { index = log.index, time = log.time, type = log.type, message = log.message, count = log.count }) end; pcall(function() if writefile then writefile("PunkX_Logs.json", HttpService:JSONEncode(data)) end end) end
local function exportToCSV() local csv = "Index,Time,Type,Message,Count\n"; for _, log in ipairs(virtualLogData) do csv = csv .. string.format('%d,"%s","%s","%s",%d\n', log.index, log.time, log.type, log.message:gsub('"', '""'), log.count) end; pcall(function() if writefile then writefile("PunkX_Logs.csv", csv) end end) end

-- Add Log
local function getLogKey(message, messageType) return string.format("%s|%s", tostring(messageType), message) end
local function addLog(message, messageType)
    logRateCounter = logRateCounter + 1
    if isExcluded(message) then return end
    local logKey = getLogKey(message, messageType)
    if groupedLogs[logKey] then
        groupedLogs[logKey].count = groupedLogs[logKey].count + 1
        groupedLogs[logKey].lastTime = os.date("%X")
        groupedLogs[logKey].isPinned = isPinned(message)
        task.spawn(function() task.wait(0.05); refreshVirtualScroll() end)
        return
    end
    logCount = logCount + 1
    local color, prefix, logType = Color3.fromRGB(220, 220, 220), "[INFO]", "INFO"
    if messageType == Enum.MessageType.MessageWarning then color, prefix, logType = Color3.fromRGB(255, 200, 0), "[WARN]", "WARN"
    elseif messageType == Enum.MessageType.MessageError then color, prefix, logType = Color3.fromRGB(255, 80, 80), "[ERR]", "ERROR" end
    local time = os.date("%X"); local full = string.format("[%s] %s %s", time, prefix, message)
    local logData = { index = logCount, time = time, prefix = prefix, message = message, full = full, color = color, type = logType, isSpam = isSpam(message), count = 1, key = logKey, isPinned = isPinned(message), isExpanded = false }
    table.insert(virtualLogData, logData); groupedLogs[logKey] = logData; table.insert(logHistory, full); saveLog(full)
    if #virtualLogData > MAX_LOGS then local removed = table.remove(virtualLogData, 1); groupedLogs[removed.key] = nil end
    refreshVirtualScroll()
    if autoScrollEnabled then task.spawn(function() task.wait(0.15); ScrollFrame.CanvasPosition = Vector2.new(0, ScrollFrame.CanvasSize.Y.Offset) end) end
end

-- Refresh Scroll
refreshVirtualScroll = function()
    local term, visibleLogs, theme = SearchBox.Text, {}, themes[currentTheme] or themes.dark
    for _, logData in ipairs(virtualLogData) do if logData.isPinned then table.insert(visibleLogs, logData) end end
    for _, logData in ipairs(virtualLogData) do
        if not logData.isPinned then
            local show = true
            if not typeFilters[logData.type] then show = false end
            if show and isFilterActive and logData.isSpam then show = false end
            if show and isExcluded(logData.message) then show = false end
            if show and term ~= "" then
                if useRegex then local s = pcall(function() return logData.full:find(term) end); if not s then show = false end
                else if not logData.full:lower():find(escapePattern(term:lower()), 1, true) then show = false end end
            end
            if show then table.insert(visibleLogs, logData) end
        end
    end
    for _, child in ipairs(ScrollFrame:GetChildren()) do if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("Frame") then child:Destroy() end end
    
    for i, logData in ipairs(visibleLogs) do
        local baseOrder = i * 2
        local isGrouped = logData.count > 1
        local element = Instance.new("TextButton")
        element.LayoutOrder = baseOrder
        element.Size = UDim2.new(1, 0, 0, 0)
        element.AutomaticSize = Enum.AutomaticSize.Y
        element.TextWrapped = true; element.RichText = true; element.Font = Enum.Font.Code; element.TextSize = fontSize; element.TextXAlignment = Enum.TextXAlignment.Left; element.TextYAlignment = Enum.TextYAlignment.Top; element.Parent = ScrollFrame
        local pad = Instance.new("UIPadding", element); pad.PaddingLeft = UDim.new(0, 6); pad.PaddingRight = UDim.new(0, 6); pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4)
        local displayText = (logData.isPinned and "📌 " or "") .. (isGrouped and (expandedGroups[logData.key] and "▼ " or "▶ ") or "") .. (showLineNumbers and string.format("[%d] ", logData.index) or "") .. (showTimestamps and string.format("[%s] ", logData.time) or "") .. string.format("%s %s", logData.prefix, logData.message) .. (logData.count > 1 and string.format(" <b>(x%d)</b>", logData.count) or "")
        element.Text = highlightText(displayText, term)
        element.TextColor3 = logData.color
        element.BackgroundColor3 = (selectedLogKey == logData.key) and theme.selected or ((i % 2 == 0) and theme.logBg2 or theme.logBg1)
        
        element.MouseButton1Click:Connect(function()
            if isGrouped then
                expandedGroups[logData.key] = not expandedGroups[logData.key]
                selectedLogKey = (selectedLogKey == logData.key) and nil or logData.key 
                actionBarVisible = (selectedLogKey ~= nil)
            else
                selectedLogKey = (selectedLogKey == logData.key) and nil or logData.key
                actionBarVisible = (selectedLogKey ~= nil)
            end
            refreshVirtualScroll()
        end)
        
        if selectedLogKey == logData.key and actionBarVisible then
            local actionBar = Instance.new("Frame")
            actionBar.LayoutOrder = baseOrder + 1; actionBar.Size = UDim2.new(1, 0, 0, 35); actionBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35); actionBar.BorderSizePixel = 0; actionBar.Parent = ScrollFrame
            Instance.new("UICorner", actionBar).CornerRadius = UDim.new(0, 4)
            local function mkActionBtn(txt, icon, x, callback)
                local b = Instance.new("TextButton", actionBar); b.Size = UDim2.new(0.25, 0, 1, 0); b.Position = UDim2.new(x, 0, 0, 0); b.BackgroundColor3 = Color3.fromRGB(55, 55, 55); b.BackgroundTransparency = 1; b.Text = icon .. " " .. txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold; b.TextSize = 10
                b.MouseButton1Click:Connect(function() callback(); if txt ~= "Close" then selectedLogKey = nil; actionBarVisible = false end; refreshVirtualScroll() end)
            end
            mkActionBtn("Pin", "📌", 0.0, function() 
                local p = logData.message
                if not table.find(pinnedSearchTerms, p) then table.insert(pinnedSearchTerms, p) end
                for _, l in ipairs(virtualLogData) do if l.message == p then l.isPinned = true end end
                showToast("📌 Pinned (x"..logData.count..")") 
            end)
            mkActionBtn("Exclude", "🚫", 0.25, function() 
                local p = logData.message
                if not table.find(excludePatterns, p) then table.insert(excludePatterns, p); if ExcludeBtn then ExcludeBtn.Text = "Exclude (" .. #excludePatterns .. ")" end end
                showToast("🚫 Excluded (x"..logData.count..")")
            end)
            mkActionBtn("Copy", "📋", 0.50, function() 
                local textToCopy = logData.full
                if logData.count > 1 then textToCopy = textToCopy .. " (Occurred " .. logData.count .. " times)" end
                pcall(function() if setclipboard then setclipboard(textToCopy) elseif toclipboard then toclipboard(textToCopy) end end) 
                showToast("📋 Copied")
            end)
            mkActionBtn("Close", "X", 0.75, function() selectedLogKey = nil; actionBarVisible = false end)
        end
        if isGrouped and expandedGroups[logData.key] then
            local detail = Instance.new("TextLabel"); detail.LayoutOrder = baseOrder + 1; detail.Size = UDim2.new(1, 0, 0, 0); detail.AutomaticSize = Enum.AutomaticSize.Y
            detail.Text = string.format("  └─ Occurred %d times\n  └─ Last: %s", logData.count, logData.lastTime); detail.TextColor3 = Color3.fromRGB(180, 180, 180); detail.BackgroundColor3 = Color3.fromRGB(30, 30, 30); detail.Font = Enum.Font.Code; detail.TextSize = fontSize - 2; detail.TextXAlignment = Enum.TextXAlignment.Left; detail.Parent = ScrollFrame
            local dp = Instance.new("UIPadding", detail); dp.PaddingLeft = UDim.new(0, 20); dp.PaddingTop = UDim.new(0, 2); dp.PaddingBottom = UDim.new(0, 4)
        end
    end
    RunService.Heartbeat:Wait()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    if searchDebounce then task.cancel(searchDebounce) end
    searchDebounce = task.delay(0.3, function() local t = SearchBox.Text; if t ~= "" and not table.find(searchHistory, t) then table.insert(searchHistory, 1, t); if #searchHistory > 10 then table.remove(searchHistory) end end; refreshVirtualScroll() end)
end)

task.spawn(function()
    local ok, h = pcall(LogService.GetLogHistory, LogService)
    if ok then addLog("--- DEBUGGER LOADED ---", Enum.MessageType.MessageInfo); for _, v in ipairs(h) do addLog(v.message, v.messageType) end; addLog("--- LIVE LOGS BEGIN ---", Enum.MessageType.MessageInfo) end
end)
LogService.MessageOut:Connect(addLog)

-- Buttons Setup
local btnColors = { default = Color3.fromRGB(45, 45, 45), hover = Color3.fromRGB(60, 60, 60), active = Color3.fromRGB(70, 70, 70), accentInfo = Color3.fromRGB(70, 130, 220), accentWarn = Color3.fromRGB(220, 160, 50), accentError = Color3.fromRGB(220, 70, 70), accentSuccess = Color3.fromRGB(70, 180, 90), accentNeutral = Color3.fromRGB(100, 100, 100) }
local FilterRow = Instance.new("Frame", MainFrame); FilterRow.Size = UDim2.new(0.96, 0, 0.05, 0); FilterRow.Position = UDim2.new(0.02, 0, 0.71, 0); FilterRow.BackgroundTransparency = 1
local BtnFrame = Instance.new("Frame", MainFrame); BtnFrame.Size = UDim2.new(0.96, 0, 0.05, 0); BtnFrame.Position = UDim2.new(0.02, 0, 0.78, 0); BtnFrame.BackgroundTransparency = 1
local AdvRow = Instance.new("Frame", MainFrame); AdvRow.Size = UDim2.new(0.96, 0, 0.05, 0); AdvRow.Position = UDim2.new(0.02, 0, 0.85, 0); AdvRow.BackgroundTransparency = 1

local function mkBtn(parent, txt, accent, x, w)
    w = w or 0.15; local b = Instance.new("TextButton", parent); b.Size = UDim2.new(w, -4, 1, 0); b.Position = UDim2.new(x, 0, 0, 0); b.BackgroundColor3 = btnColors.default; b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamBold; b.TextSize = 11; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4); b:SetAttribute("AccentColor", accent)
    b.MouseEnter:Connect(function() if b.BackgroundColor3 == btnColors.default then b.BackgroundColor3 = btnColors.hover end end)
    b.MouseLeave:Connect(function() if b.BackgroundColor3 == btnColors.hover then b.BackgroundColor3 = btnColors.default end end)
    return b
end

local InfoBtn = mkBtn(FilterRow, "INFO", "accentInfo", 0, 0.16); local WarnBtn = mkBtn(FilterRow, "WARN", "accentWarn", 0.16, 0.16); local ErrorBtn = mkBtn(FilterRow, "ERROR", "accentError", 0.32, 0.16); local TimestampBtn = mkBtn(FilterRow, "Time", "accentNeutral", 0.48, 0.13); local LineNumBtn = mkBtn(FilterRow, "Line", "accentNeutral", 0.61, 0.13); local RegexBtn = mkBtn(FilterRow, "Regex", "accentNeutral", 0.74, 0.13); local FontBtn = mkBtn(FilterRow, "A"..fontSize, "accentNeutral", 0.87, 0.13)
local Copy = mkBtn(BtnFrame, "Copy", "accentInfo", 0, 0.166); local Clear = mkBtn(BtnFrame, "Clear", "accentError", 0.166, 0.166); local Filter = mkBtn(BtnFrame, "Filter", "accentSuccess", 0.333, 0.166); local AutoScroll = mkBtn(BtnFrame, "Scroll", "accentNeutral", 0.500, 0.166); ExportBtn = mkBtn(BtnFrame, "Export", "accentInfo", 0.666, 0.166); ThemeBtn = mkBtn(BtnFrame, "Theme", "accentNeutral", 0.833, 0.166)
PinBtn = mkBtn(AdvRow, "Pin", "accentWarn", 0, 0.25); ExcludeBtn = mkBtn(AdvRow, "Exclude", "accentError", 0.25, 0.25); HistoryBtn = mkBtn(AdvRow, "History", "accentSuccess", 0.50, 0.25); local Close = mkBtn(AdvRow, "Close", "accentError", 0.75, 0.25)

local allButtons = { InfoBtn, WarnBtn, ErrorBtn, TimestampBtn, LineNumBtn, RegexBtn, FontBtn, Copy, Clear, Filter, AutoScroll, ExportBtn, ThemeBtn, PinBtn, ExcludeBtn, HistoryBtn, Close }
local function updateButtonSizes(w) local s = (w >= 500) and 11 or (w >= 400 and 9 or 7); for _, b in ipairs(allButtons) do b.TextSize = s end; TitleBar.TextSize = math.max(12, s + 4) end
updateButtonSizes(MainFrame.AbsoluteSize.X)

-- Logic Handlers
local function setAct(b, a) b.BackgroundColor3 = a and (btnColors[b:GetAttribute("AccentColor")] or btnColors.active) or btnColors.default end
InfoBtn.MouseButton1Click:Connect(function() typeFilters.INFO = not typeFilters.INFO; setAct(InfoBtn, typeFilters.INFO); refreshVirtualScroll() end)
WarnBtn.MouseButton1Click:Connect(function() typeFilters.WARN = not typeFilters.WARN; setAct(WarnBtn, typeFilters.WARN); refreshVirtualScroll() end)
ErrorBtn.MouseButton1Click:Connect(function() typeFilters.ERROR = not typeFilters.ERROR; setAct(ErrorBtn, typeFilters.ERROR); refreshVirtualScroll() end)
TimestampBtn.MouseButton1Click:Connect(function() showTimestamps = not showTimestamps; setAct(TimestampBtn, showTimestamps); refreshVirtualScroll() end)
LineNumBtn.MouseButton1Click:Connect(function() showLineNumbers = not showLineNumbers; setAct(LineNumBtn, showLineNumbers); refreshVirtualScroll() end)
RegexBtn.MouseButton1Click:Connect(function() useRegex = not useRegex; setAct(RegexBtn, useRegex); SearchBox.PlaceholderText = useRegex and "Search... (Regex)" or "Search logs..."; refreshVirtualScroll() end)
FontBtn.MouseButton1Click:Connect(function() fontSize = fontSize + 2; if fontSize > 18 then fontSize = 10 end; FontBtn.Text = "A"..fontSize; refreshVirtualScroll() end)
Filter.MouseButton1Click:Connect(function() isFilterActive = not isFilterActive; setAct(Filter, isFilterActive); refreshVirtualScroll() end)
AutoScroll.MouseButton1Click:Connect(function() autoScrollEnabled = not autoScrollEnabled; setAct(AutoScroll, autoScrollEnabled); if autoScrollEnabled then userHasScrolled=false; task.wait(0.1); ScrollFrame.CanvasPosition=Vector2.new(0,9e9); task.wait(0.2); autoScrollEnabled=false; setAct(AutoScroll,false) end end)
Clear.MouseButton1Click:Connect(function() virtualLogData={}; groupedLogs={}; logHistory={}; logCount=0; expandedGroups={}; refreshVirtualScroll() end)
Copy.MouseButton1Click:Connect(function() local t=table.concat(logHistory,"\n"); pcall(function() if setclipboard then setclipboard(t) elseif toclipboard then toclipboard(t) end end); Copy.Text="✓"; Copy.BackgroundColor3=btnColors.accentSuccess; task.wait(1); Copy.Text="Copy"; Copy.BackgroundColor3=btnColors.default end)
PinBtn.MouseButton1Click:Connect(function() local t=SearchBox.Text; if t=="" then return end; local f=table.find(pinnedSearchTerms,t); if f then table.remove(pinnedSearchTerms,f); PinBtn.Text="Unpinned" else table.insert(pinnedSearchTerms,t); PinBtn.Text="Pinned!" end; pcall(function() for _,l in ipairs(virtualLogData) do l.isPinned=isPinned(l.message) end end); refreshVirtualScroll(); task.wait(1.5); PinBtn.Text="Pin" end)
Close.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- FIXED DYNAMIC HIGHLIGHTER
local function addHighlight(obj)
    if #currentHighlights >= 30 then return end
    local h = Instance.new("Highlight")
    h.Adornee = obj
    h.FillColor = Color3.fromRGB(255, 255, 0)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    h.FillTransparency = 0.5
    h.Parent = obj
    table.insert(currentHighlights, h)
    HighlightBtn.Text = "✓"..#currentHighlights
end

HighlightBtn.MouseButton1Click:Connect(function()
    -- Reset
    for _, h in ipairs(currentHighlights) do h:Destroy() end; currentHighlights = {}
    for _, c in ipairs(highlightConnections) do c:Disconnect() end; highlightConnections = {}
    
    if isHighlighting then isHighlighting = false; HighlightBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); HighlightBtn.Text="👁️"; return end
    local term = SearchBox.Text; if term == "" then return end
    
    isHighlighting = true; HighlightBtn.BackgroundColor3 = btnColors.accentWarn
    
    if term:lower() == "players" then
        -- Players Mode
        local function setupChar(char) if char then addHighlight(char) end end
        local function setupPlayer(p)
            if p.Character then setupChar(p.Character) end
            local c = p.CharacterAdded:Connect(setupChar)
            table.insert(highlightConnections, c)
        end
        for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
        local c = Players.PlayerAdded:Connect(setupPlayer)
        table.insert(highlightConnections, c)
    else
        -- Parts Mode (Search & Listen)
        -- Initial Scan
        for _, v in ipairs(workspace:GetDescendants()) do
            if (v:IsA("BasePart") or v:IsA("Model")) and v.Name:lower():find(term:lower(), 1, true) then
                local target = v
                if v.Name == "HumanoidRootPart" or v.Name == "Head" then if v.Parent and v.Parent:IsA("Model") then target = v.Parent end end
                addHighlight(target)
            end
        end
        -- Auto-Update listener
        local c = workspace.DescendantAdded:Connect(function(v)
            if #currentHighlights >= 30 then return end
            if (v:IsA("BasePart") or v:IsA("Model")) and v.Name:lower():find(term:lower(), 1, true) then
                local target = v
                if v.Name == "HumanoidRootPart" or v.Name == "Head" then if v.Parent and v.Parent:IsA("Model") then target = v.Parent end end
                addHighlight(target)
            end
        end)
        table.insert(highlightConnections, c)
    end
end)

-- EXPORT (Fixed Toggle)
local exportMenuOpen, exportMenuRef = false, nil
ExportBtn.MouseButton1Click:Connect(function()
    if exportMenuOpen then if exportMenuRef and exportMenuRef.Parent then exportMenuRef:Destroy() end; exportMenuOpen=false; return end
    exportMenuOpen = true; local menu = Instance.new("Frame", MainFrame); exportMenuRef = menu; menu.Size = UDim2.new(0.2, 0, 0.15, 0); menu.Position = UDim2.new(0.64, 0, 0.63, 0); menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40); menu.BorderSizePixel = 0; menu.ZIndex = 300; Instance.new("UICorner", menu)
    local function mk(txt, y, cb) local b = Instance.new("TextButton", menu); b.Size = UDim2.new(0.9, 0, 0.28, 0); b.Position = UDim2.new(0.05, 0, y, 0); b.BackgroundColor3 = Color3.fromRGB(60, 60, 60); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.ZIndex = 301; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() cb(); if menu.Parent then menu:Destroy() end; exportMenuOpen=false end) end
    mk(".txt", 0.05, function() saveLog("== EXPORT =="); ExportBtn.Text="✓ TXT" end); mk(".json", 0.36, function() exportToJSON(); ExportBtn.Text="✓ JSON" end); mk(".csv", 0.67, function() exportToCSV(); ExportBtn.Text="✓ CSV" end)
    task.delay(4, function() if menu and menu.Parent then menu:Destroy(); if exportMenuRef==menu then exportMenuOpen=false end end end); task.wait(1); ExportBtn.Text="Export"
end)

-- THEME (Fixed Toggle + Scope)
local themeMenuOpen, themeMenuRef = false, nil
ThemeBtn.MouseButton1Click:Connect(function()
    if themeMenuOpen then if themeMenuRef and themeMenuRef.Parent then themeMenuRef:Destroy() end; themeMenuOpen=false; return end
    themeMenuOpen = true; local menu = Instance.new("Frame", MainFrame); themeMenuRef = menu; menu.Size = UDim2.new(0.15, 0, 0.15, 0); menu.Position = UDim2.new(0.8, 0, 0.63, 0); menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40); menu.BorderSizePixel = 0; menu.ZIndex = 300; Instance.new("UICorner", menu)
    local function mk(txt, y, val) local b = Instance.new("TextButton", menu); b.Size = UDim2.new(0.9, 0, 0.28, 0); b.Position = UDim2.new(0.05, 0, y, 0); b.BackgroundColor3 = Color3.fromRGB(60, 60, 60); b.Text = txt; b.TextColor3 = Color3.new(1,1,1); b.ZIndex = 301; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() applyTheme(val); if menu.Parent then menu:Destroy() end; themeMenuOpen=false end) end
    mk("Dark", 0.05, "dark"); mk("Light", 0.36, "light"); mk("Blue", 0.67, "blue")
    task.delay(5, function() if menu and menu.Parent then menu:Destroy(); if themeMenuRef==menu then themeMenuOpen=false end end end)
end)

-- HISTORY (Fixed Toggle)
local historyMenuOpen, historyMenuRef = false, nil
HistoryBtn.MouseButton1Click:Connect(function()
    if historyMenuOpen then if historyMenuRef and historyMenuRef.Parent then historyMenuRef:Destroy() end; historyMenuOpen=false; return end
    if #searchHistory == 0 then return end
    historyMenuOpen = true; local menu = Instance.new("ScrollingFrame", MainFrame); historyMenuRef = menu; menu.Size = UDim2.new(0.3, 0, 0.25, 0); menu.Position = UDim2.new(0.42, 0, 0.57, 0); menu.BackgroundColor3 = Color3.fromRGB(40, 40, 40); menu.BorderSizePixel = 0; menu.ZIndex = 300; menu.AutomaticCanvasSize = Enum.AutomaticSize.Y; Instance.new("UICorner", menu); local layout = Instance.new("UIListLayout", menu); layout.SortOrder = Enum.SortOrder.LayoutOrder
    for i, term in ipairs(searchHistory) do local b = Instance.new("TextButton", menu); b.Size = UDim2.new(1, -10, 0, 30); b.BackgroundColor3 = Color3.fromRGB(60, 60, 60); b.Text = term; b.TextColor3 = Color3.new(1,1,1); b.ZIndex = 301; Instance.new("UICorner", b); b.MouseButton1Click:Connect(function() SearchBox.Text = term; if menu.Parent then menu:Destroy() end; historyMenuOpen=false end) end
    task.delay(8, function() if menu and menu.Parent then menu:Destroy(); if historyMenuRef==menu then historyMenuOpen=false end end end)
end)

-- EXCLUDE (Toggle + Scroll + Fixed)
local excludeMenuOpen, excludeMenuRef = false, nil
ExcludeBtn.MouseButton1Click:Connect(function()
    if excludeMenuOpen then if excludeMenuRef and excludeMenuRef.Parent then excludeMenuRef:Destroy() end; excludeMenuOpen=false; return end
    local t = SearchBox.Text
    if t == "" then
        if #excludePatterns == 0 then return end
        excludeMenuOpen = true; local m = Instance.new("ScrollingFrame", MainFrame); excludeMenuRef = m; m.Size = UDim2.new(0.35, 0, 0.3, 0); m.Position = UDim2.new(0.168, 0, 0.52, 0); m.BackgroundColor3 = Color3.fromRGB(40, 40, 40); m.BorderSizePixel = 0; m.ZIndex = 200; m.AutomaticCanvasSize = Enum.AutomaticSize.Y; m.CanvasSize = UDim2.new(0, 0, 0, 0); Instance.new("UICorner", m); local l = Instance.new("UIListLayout", m); l.SortOrder = Enum.SortOrder.LayoutOrder; l.Padding = UDim.new(0, 2)
        for i, p in ipairs(excludePatterns) do
            local f = Instance.new("Frame", m); f.Size = UDim2.new(1, -6, 0, 30); f.BackgroundColor3 = Color3.fromRGB(50, 50, 50); f.ZIndex = 201; f.LayoutOrder = i; Instance.new("UICorner", f)
            local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(0, 24, 0, 24); btn.AnchorPoint = Vector2.new(1, 0.5); btn.Position = UDim2.new(1, -4, 0.5, 0); btn.BackgroundColor3 = btnColors.accentError; btn.Text = "X"; btn.TextColor3 = Color3.new(1, 1, 1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 10; btn.ZIndex = 203; Instance.new("UICorner", btn)
            btn.MouseButton1Click:Connect(function() table.remove(excludePatterns, i); ExcludeBtn.Text = (#excludePatterns>0) and "Exclude ("..#excludePatterns..")" or "Exclude"; if m.Parent then m:Destroy() end; excludeMenuOpen=false; refreshVirtualScroll() end)
            local scrollText = Instance.new("ScrollingFrame", f); scrollText.Size = UDim2.new(1, -35, 1, 0); scrollText.BackgroundTransparency = 1; scrollText.ScrollingDirection = Enum.ScrollingDirection.X; scrollText.CanvasSize = UDim2.new(0, 0, 0, 0); scrollText.AutomaticCanvasSize = Enum.AutomaticSize.X; scrollText.ScrollBarThickness = 2; scrollText.ZIndex = 202
            local txt = Instance.new("TextLabel", scrollText); txt.Size = UDim2.new(0, 0, 1, 0); txt.AutomaticSize = Enum.AutomaticSize.X; txt.BackgroundTransparency = 1; txt.Text = "  " .. p; txt.TextColor3 = Color3.new(1, 1, 1); txt.Font = Enum.Font.Gotham; txt.TextSize = 10; txt.TextXAlignment = Enum.TextXAlignment.Left; txt.ZIndex = 202
        end
        task.delay(10, function() if m and m.Parent then m:Destroy(); if excludeMenuRef == m then excludeMenuOpen = false end end end)
        return
    end
    if table.find(excludePatterns, t) then return end
    table.insert(excludePatterns, t); ExcludeBtn.Text = "✓ Added"; refreshVirtualScroll(); task.wait(1.5); ExcludeBtn.Text = "Exclude ("..#excludePatterns..")"
end)

-- Init
refreshVirtualScroll(); setAct(InfoBtn, typeFilters.INFO); setAct(WarnBtn, typeFilters.WARN); setAct(ErrorBtn, typeFilters.ERROR); setAct(TimestampBtn, showTimestamps); setAct(LineNumBtn, showLineNumbers); setAct(RegexBtn, useRegex); setAct(Filter, isFilterActive)
print("Punk X Debugger")
